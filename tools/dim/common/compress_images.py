"""Converts the question images (PNG) to WebP so students download less data.

Per subject <s> (kimya, biologiya): sources tools/dim/<s>/images (DİM questions and explanations) and <s>/out/images_kitab (scanned books).
Result:  tools/dim/<s>/out/webp/<same name>.webp. The originals are never changed or deleted.

  python compress_images.py            convert everything that is not converted yet (all subjects)
  python compress_images.py --subject kimya   only one subject
  python compress_images.py --quality 85
  python compress_images.py --check    only verify that every WebP opens and has the same size as its PNG

The pixel size stays the same (the images are already about 900 px wide). Only the encoding changes.
After uploading the .webp files, db/migrations/015_webp_images.sql renames image_path / solution_image_path.
"""
import argparse
import sys
from pathlib import Path

from PIL import Image

QUALITY = 80


def folders(slug):
    """(source folders, WebP folder) of one subject: its DİM images and the scanned-book images."""
    from subjects import SUBJECTS
    cfg = SUBJECTS[slug]
    return [cfg["images"], cfg["out"] / "images_kitab"], cfg["webp"]


def web_name(name):
    """NAME.png -> NAME.webp (the name that goes into the database and the bucket). Empty stays empty."""
    return str(Path(name).with_suffix(".webp").as_posix()) if name else name


def convert(src: Path, dst: Path, quality: int = QUALITY) -> None:
    with Image.open(src) as im:
        # Palette/gray PNGs become plain RGB: WebP lossy needs it, and the result is still tiny.
        im.convert("RGB").save(dst, "WEBP", quality=quality, method=6)


def check(slugs) -> int:
    bad = 0
    for slug in slugs:
        sources, out = folders(slug)
        for src_dir in sources:
            for png in sorted(src_dir.glob("*.png")):
                webp = out / (png.stem + ".webp")
                if not webp.exists():
                    print(f"MISSING {webp.name}")
                    bad += 1
                    continue
                with Image.open(png) as a, Image.open(webp) as b:
                    b.load()
                    if a.size != b.size:
                        print(f"SIZE    {png.name}: {a.size} -> {b.size}")
                        bad += 1
    print("check:", "OK" if bad == 0 else f"{bad} problem(s)")
    return 1 if bad else 0


def main() -> int:
    import paths  # noqa: F401
    from subjects import SUBJECTS
    ap = argparse.ArgumentParser()
    ap.add_argument("--quality", type=int, default=QUALITY)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--subject", choices=list(SUBJECTS), help="default: every subject")
    args = ap.parse_args()
    slugs = [args.subject] if args.subject else list(SUBJECTS)
    if args.check:
        return check(slugs)

    done = skipped = 0
    before = after = 0
    for slug in slugs:
        sources, out = folders(slug)
        out.mkdir(parents=True, exist_ok=True)
        seen: dict[str, Path] = {}
        for src_dir in sources:
            for png in sorted(src_dir.glob("*.png")):
                if png.name in seen:
                    print(f"DUPLICATE NAME {png.name}: {seen[png.name]} and {png}", file=sys.stderr)
                    return 1
                seen[png.name] = png
                dst = out / (png.stem + ".webp")
                if dst.exists():
                    skipped += 1
                    continue
                convert(png, dst, args.quality)
                before += png.stat().st_size
                after += dst.stat().st_size
                done += 1
    print(f"converted {done}, already done {skipped}")
    if done:
        print(f"PNG {before / 1024 / 1024:.1f} MB -> WebP {after / 1024 / 1024:.1f} MB ({after / before * 100:.0f}%)")
    return check(slugs)


if __name__ == "__main__":
    sys.exit(main())
