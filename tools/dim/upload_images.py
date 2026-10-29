"""Uploads the images of APPROVED questions to the Supabase Storage bucket 'question-images'.

Which images: rows with aktiv = bəli, tip qapali/aciq_eded, çətinlik filled and a şəkil file (same selection as
import_questions.py). The path in the bucket equals the file name, which import_questions.py already writes to
questions.image_path.

Modes:
  python upload_images.py --prepare   copy the needed files to out/upload/ (for drag and drop in the dashboard)
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

from import_questions import HERE, read_rows, select_rows

BUCKET = "question-images"
IMAGES = HERE / "images"
UPLOAD_DIR = HERE / "out" / "upload"


def needed_files(excel):
    chosen, _skipped = select_rows(read_rows(excel))
    return sorted({r["şəkil"] for _i, r in chosen if r["şəkil"]})


def upload_one(base_url, key, name, data):
    """Returns 'uploaded' | 'exists'. Raises RuntimeError on anything else (the key is never printed)."""
    req = urllib.request.Request(
        f"{base_url.rstrip('/')}/storage/v1/object/{BUCKET}/{name}",
        data=data,
        method="POST",
        headers={"Authorization": f"Bearer {key}", "apikey": key, "Content-Type": "image/png",
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
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--prepare", action="store_true")
    mode.add_argument("--upload", action="store_true")
    args = ap.parse_args(argv)

    names = needed_files(args.file)
    missing = [n for n in names if not (IMAGES / n).exists()]
    if missing:
        print("XƏTA: şəkil faylları yoxdur:", ", ".join(missing))
        return 1
    print(f"Təsdiqlənmiş suallar üçün {len(names)} şəkil lazımdır.")
    if not names:
        return 0

    if args.prepare:
        UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
        for n in names:
            shutil.copy(IMAGES / n, UPLOAD_DIR / n)
        print(f"Kopyalandı: {UPLOAD_DIR}\nSupabase → Storage → {BUCKET} → Upload files ilə bu qovluqdakı faylları yükləyin.")
        return 0

    url, key = os.environ.get("SUPABASE_URL"), os.environ.get("SUPABASE_SERVICE_KEY")
    if not url or not key:
        print("XƏTA: SUPABASE_URL və SUPABASE_SERVICE_KEY mühit dəyişənləri təyin edilməyib.")
        return 1
    done = {"uploaded": 0, "exists": 0}
    try:
        for n in names:
            done[upload_one(url, key, n, (IMAGES / n).read_bytes())] += 1
    except RuntimeError as e:
        print("XƏTA:", e)
        print(json.dumps(done))
        return 1
    print(f"Yeni yüklənən: {done['uploaded']}, artıq var idi (toxunulmadı): {done['exists']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
