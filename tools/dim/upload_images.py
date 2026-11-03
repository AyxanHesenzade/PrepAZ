"""Uploads the images of APPROVED questions to the Supabase Storage bucket 'question-images'.

Which images: rows with aktiv = bəli, tip qapali/aciq_eded, çətinlik filled and a şəkil file (same selection as
import_questions.py). The path in the bucket equals the file name, which import_questions.py already writes to
questions.image_path.

Modes:
  python upload_images.py --prepare   copy the needed files to out/upload/ (for drag and drop in the dashboard)
  python upload_images.py --folder out/upload_kitab --upload   (every PNG/WebP of a folder, e.g. the scanned-book questions)
  python upload_images.py --folder out/webp --upload           (the compressed WebP images made by compress_images.py)
  python upload_images.py --folder out/webp --delete-png       dry run: how many old .png files would be deleted
  python upload_images.py --folder out/webp --delete-png --yes delete NAME.png from the bucket for every NAME.webp in the folder
                                                              (only after db/migrations/015_webp_images.sql ran and the app was checked)
  python upload_images.py --upload    upload through the Storage API. Needs environment variables:
                                        SUPABASE_URL          e.g. https://xxxx.supabase.co
                                        SUPABASE_SERVICE_KEY  service_role key (never commit or paste it anywhere)
An image that already exists in the bucket is skipped, never overwritten.
"""
import argparse
import json
import os
import shutil
import sys
import urllib.error
import urllib.request
from pathlib import Path

from compress_images import web_name
from import_questions import HERE, read_rows, select_rows

BUCKET = "question-images"
WEBP_DIR = HERE / "out" / "webp"
UPLOAD_DIR = HERE / "out" / "upload"


def needed_files(excel):
    chosen, _skipped = select_rows(read_rows(excel))
    return sorted({r[col] for _i, r in chosen for col in ("şəkil", "izah şəkli") if r[col]})


CONTENT_TYPES = {".png": "image/png", ".webp": "image/webp"}


def delete_many(base_url, key, names):
    """Deletes the given objects from the bucket. Raises RuntimeError on any failure (the key is never printed)."""
    req = urllib.request.Request(
        f"{base_url.rstrip('/')}/storage/v1/object/{BUCKET}",
        data=json.dumps({"prefixes": list(names)}).encode(),
        method="DELETE",
        headers={"Authorization": f"Bearer {key}", "apikey": key, "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return len(json.loads(resp.read() or b"[]"))
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"silmə: HTTP {e.code} {e.read().decode('utf-8', 'replace')[:200]}") from None
    except urllib.error.URLError as e:
        raise RuntimeError(f"silmə: bağlantı xətası ({e.reason})") from None


def upload_one(base_url, key, name, data):
    """Returns 'uploaded' | 'exists'. Raises RuntimeError on anything else (the key is never printed)."""
    req = urllib.request.Request(
        f"{base_url.rstrip('/')}/storage/v1/object/{BUCKET}/{name}",
        data=data,
        method="POST",
        headers={"Authorization": f"Bearer {key}", "apikey": key, "Content-Type": CONTENT_TYPES.get(Path(name).suffix.lower(), "image/png"),
                 "x-upsert": "false", "cache-control": "max-age=3600"},
    )
    try:
        with urllib.request.urlopen(req, timeout=60):
            return "uploaded"
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")
        if e.code == 409 or "Duplicate" in body or "already exists" in body:
            return "exists"
        raise RuntimeError(f"{name}: HTTP {e.code} {body[:200]}") from None
    except urllib.error.URLError as e:
        raise RuntimeError(f"{name}: bağlantı xətası ({e.reason})") from None


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", type=Path, default=HERE / "out" / "kimya_dim_yoxlama.xlsx")
    ap.add_argument("--folder", type=Path, help="upload every PNG/WebP in this folder (e.g. out/upload_kitab) instead of the Excel selection")
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--prepare", action="store_true")
    mode.add_argument("--upload", action="store_true")
    mode.add_argument("--delete-png", action="store_true", help="delete NAME.png from the bucket for every NAME.webp in --folder")
    ap.add_argument("--yes", action="store_true", help="with --delete-png: really delete (without it only a dry run)")
    args = ap.parse_args(argv)
    if args.delete_png and not args.folder:
        print("XƏTA: --delete-png üçün --folder (məs. out/webp) lazımdır.")
        return 1

    source = args.folder or WEBP_DIR
    names = (
        sorted(f.name for f in args.folder.iterdir() if f.suffix.lower() in CONTENT_TYPES)
        if args.folder
        else [web_name(n) for n in needed_files(args.file)]
    )
    missing = [n for n in names if not (source / n).exists()]
    if missing:
        print("XƏTA: şəkil faylları yoxdur:", ", ".join(missing))
        return 1
    print(f"Təsdiqlənmiş suallar üçün {len(names)} şəkil lazımdır.")
    if not names:
        return 0

    if args.prepare:
        UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
        for n in names:
            shutil.copy(source / n, UPLOAD_DIR / n)
        print(f"Kopyalandı: {UPLOAD_DIR}\nSupabase → Storage → {BUCKET} → Upload files ilə bu qovluqdakı faylları yükləyin.")
        return 0

    if args.delete_png:
        old = [Path(n).with_suffix(".png").name for n in names if n.endswith(".webp")]
        print(f"Silinəcək köhnə PNG: {len(old)}")
        if not args.yes:
            print("Quru yoxlama: heç nə silinmədi. Həqiqətən silmək üçün --yes əlavə edin.")
            return 0
        url, key = os.environ.get("SUPABASE_URL"), os.environ.get("SUPABASE_SERVICE_KEY")
        if not url or not key:
            print("XƏTA: SUPABASE_URL və SUPABASE_SERVICE_KEY mühit dəyişənləri təyin edilməyib.")
            return 1
        try:
            removed = delete_many(url, key, old)
        except RuntimeError as e:
            print("XƏTA:", e)
            return 1
        print(f"Silindi: {removed} (bucket-də olmayanlar sayılmır)")
        return 0

    url, key = os.environ.get("SUPABASE_URL"), os.environ.get("SUPABASE_SERVICE_KEY")
    if not url or not key:
        print("XƏTA: SUPABASE_URL və SUPABASE_SERVICE_KEY mühit dəyişənləri təyin edilməyib.")
        return 1
    done = {"uploaded": 0, "exists": 0}
    try:
        for n in names:
            done[upload_one(url, key, n, (source / n).read_bytes())] += 1
    except RuntimeError as e:
        print("XƏTA:", e)
        print(json.dumps(done))
        return 1
    print(f"Yeni yüklənən: {done['uploaded']}, artıq var idi (toxunulmadı): {done['exists']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
