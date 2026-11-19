"""Copies question images to Cloudflare R2 (the app reads them from IMAGE_BASE_URL, see CLAUDE.md "Şəkil mənbəyi").

Nothing is ever deleted or overwritten (unless --overwrite): an image already in R2 is skipped, so the script can be
run again safely after an interruption.

Modes:
  python upload_r2.py --from-supabase            copy EVERY image of the Supabase bucket 'question-images' to R2
  python upload_r2.py --from-supabase --dry-run  only count what would be copied
  python upload_r2.py --folder out/upload_kitab  upload every .webp/.png of a local folder (new images)
  python upload_r2.py --check                    compare Supabase and R2, list what is missing in R2

Needs (environment variables only, never commit or paste them anywhere; the keys are never printed):
  R2_ACCOUNT_ID         Cloudflare account id (R2 Overview → Account Details)
  R2_ACCESS_KEY_ID      R2 API token (Object Read & Write, this bucket only)
  R2_SECRET_ACCESS_KEY
  R2_BUCKET             default: prepaz-images-test
  SUPABASE_URL, SUPABASE_SERVICE_KEY   only for --from-supabase / --check

Requires: pip install boto3
"""
import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

SUPABASE_BUCKET = "question-images"
CONTENT_TYPES = {".webp": "image/webp", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg"}
# A corrected image is uploaded under the SAME name, so CDN/browsers must not keep it for long.
CACHE_CONTROL = "public, max-age=86400"
LIST_PAGE = 1000


def content_type(name):
    return CONTENT_TYPES.get(Path(name).suffix.lower())


def to_copy(source_names, r2_names, overwrite=False):
    """Images that must be uploaded: only image files, sorted, existing ones skipped unless overwrite."""
    images = sorted(n for n in set(source_names) if content_type(n))
    return images if overwrite else [n for n in images if n not in r2_names]


# --- Supabase (stdlib HTTP, service key) -------------------------------------------------------------------------

def _supabase_request(url, key, path, data=None, method="GET"):
    req = urllib.request.Request(
        f"{url.rstrip('/')}/storage/v1/{path}",
        data=None if data is None else json.dumps(data).encode(),
        method=method,
        headers={"Authorization": f"Bearer {key}", "apikey": key, "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.read()
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"Supabase {path}: HTTP {e.code} {e.read().decode('utf-8', 'replace')[:200]}") from None
    except urllib.error.URLError as e:
        raise RuntimeError(f"Supabase {path}: bağlantı xətası ({e.reason})") from None


def supabase_names(url, key):
    """Every file name in the bucket root (images are stored flat, without folders)."""
    names, offset = [], 0
    while True:
        rows = json.loads(_supabase_request(
            url, key, f"object/list/{SUPABASE_BUCKET}", method="POST",
            data={"prefix": "", "limit": LIST_PAGE, "offset": offset, "sortBy": {"column": "name", "order": "asc"}},
        ))
        names += [r["name"] for r in rows if r.get("id")]  # id null = folder
        if len(rows) < LIST_PAGE:
            return names
        offset += LIST_PAGE


def supabase_download(url, key, name):
    return _supabase_request(url, key, f"object/{SUPABASE_BUCKET}/{urllib.request.quote(name)}")


# --- R2 (S3 API) ---------------------------------------------------------------------------------------------------

def r2_client():
    try:
        import boto3
    except ImportError:
        sys.exit("XƏTA: boto3 yoxdur. Quraşdırın: pip install boto3")
    missing = [v for v in ("R2_ACCOUNT_ID", "R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY") if not os.environ.get(v)]
    if missing:
        sys.exit("XƏTA: mühit dəyişənləri təyin edilməyib: " + ", ".join(missing))
    return boto3.client(
        "s3",
        endpoint_url=f"https://{os.environ['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com",
        aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
        region_name="auto",
    )


def r2_names(client, bucket):
    names = set()
    for page in client.get_paginator("list_objects_v2").paginate(Bucket=bucket):
        names.update(o["Key"] for o in page.get("Contents", []))
    return names


def r2_put(client, bucket, name, data):
    client.put_object(Bucket=bucket, Key=name, Body=data, ContentType=content_type(name), CacheControl=CACHE_CONTROL)


# --- main ----------------------------------------------------------------------------------------------------------

def main(argv=None):
    for stream in (sys.stdout, sys.stderr):  # Windows console (cp1252) cannot print ə, ş, →
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--from-supabase", action="store_true")
    mode.add_argument("--folder", type=Path)
    mode.add_argument("--check", action="store_true")
    ap.add_argument("--dry-run", action="store_true", help="only count, upload nothing")
    ap.add_argument("--overwrite", action="store_true", help="replace images that already exist in R2 (corrected images)")
    args = ap.parse_args(argv)
    bucket = os.environ.get("R2_BUCKET", "prepaz-images-test")

    sb_url, sb_key = os.environ.get("SUPABASE_URL"), os.environ.get("SUPABASE_SERVICE_KEY")
    if (args.from_supabase or args.check) and not (sb_url and sb_key):
        print("XƏTA: SUPABASE_URL və SUPABASE_SERVICE_KEY mühit dəyişənləri təyin edilməyib.")
        return 1
    if args.folder and not args.folder.is_dir():
        print(f"XƏTA: qovluq yoxdur: {args.folder}")
        return 1

    client = r2_client()
    try:
        in_r2 = r2_names(client, bucket)
        if args.folder:
            source = [f.name for f in args.folder.iterdir() if f.is_file()]
        else:
            source = supabase_names(sb_url, sb_key)
    except RuntimeError as e:
        print("XƏTA:", e)
        return 1
    except Exception as e:  # boto3: wrong key, wrong bucket...
        print(f"XƏTA: R2-yə qoşulmaq alınmadı ({type(e).__name__}). Açarları və R2_BUCKET-i yoxlayın.")
        return 1

    todo = to_copy(source, in_r2, overwrite=args.overwrite)
    where = args.folder or f"Supabase/{SUPABASE_BUCKET}"
    print(f"Mənbə ({where}): {len(source)} fayl · R2 ({bucket}): {len(in_r2)} fayl · yüklənməli: {len(todo)}")

    if args.check:
        for n in todo[:50]:
            print("  R2-də yoxdur:", n)
        if len(todo) > 50:
            print(f"  ... və daha {len(todo) - 50}")
        return 0 if not todo else 2
    if args.dry_run or not todo:
        print("Heç nə yüklənmədi." if todo else "Hamısı artıq R2-dədir.")
        return 0

    failed = []
    for i, name in enumerate(todo, 1):
        try:
            data = (args.folder / name).read_bytes() if args.folder else supabase_download(sb_url, sb_key, name)
            r2_put(client, bucket, name, data)
        except Exception as e:
            failed.append(name)
            print(f"  XƏTA {name}: {type(e).__name__}")
        if i % 50 == 0 or i == len(todo):
            print(f"  {i}/{len(todo)}")
    print(f"Yükləndi: {len(todo) - len(failed)}, alınmadı: {len(failed)}")
    if failed:
        print("Yenidən işlədin: artıq yüklənənlər atlanacaq.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
