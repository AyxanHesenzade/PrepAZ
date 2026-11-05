"""Helpers for adding a scanned book section with as few steps (and as few looked-at images) as possible.
See SUAL_ELAVE_AZ_TOKEN.md. All images go to --tmp (default: /tmp/prepaz_scan), small sizes on purpose.

  python scan_tool.py strip 83 86                 # 4 pages side by side, tiny: where does the section end?
  python scan_tool.py key 335 0.17 0.42           # answer key crop (pdf page, top/bottom fraction of the page)
  python scan_tool.py grid 84:0:510:30:520 85:530:1080:900:1110   # crops with a y-ruler: measure missing questions
  python scan_tool.py add scan/kimya_I_bolme17 '{"1":[83,1,1145],"5":[84,0,75]}' --end '{"4":1590}'
                                                  # adds manual questions {n: [page, column, y0]}, fills y1 from neighbours
  python scan_tool.py check scan/kimya_I_bolme17 1 5 14 83 [--tops]   # small sheet of only these questions
  python scan_tool.py done 16 17                  # owner said "ok": move KT1-S16/S17 webp upload_kitab -> images_kitab
"""
import argparse
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
PDF = HERE / "Kimya test toplusu I 2025 _250822_103034.pdf"


def _doc():
    import pymupdf
    return pymupdf.open(PDF)


def strip(a):
    from PIL import Image
    import io
    doc = _doc()
    ims = [Image.open(io.BytesIO(doc[p - 1].get_pixmap(dpi=30).tobytes("png"))) for p in range(a.first, a.last + 1)]
    out = Image.new("RGB", (sum(i.width for i in ims), max(i.height for i in ims)), "white")
    x = 0
    for i in ims:
        out.paste(i, (x, 0)); x += i.width
    _save(out, a, f"strip_{a.first}_{a.last}.png")


def key(a):
    import pymupdf
    doc = _doc()
    p = doc[a.page - 1]; r = p.rect
    clip = pymupdf.Rect(r.x0, r.y0 + r.height * a.top, r.x1, r.y0 + r.height * a.bottom)
    p.get_pixmap(dpi=150, clip=clip).save(_path(a, f"key_{a.page}.png"))
    print(_path(a, f"key_{a.page}.png"))


def grid(a):
    sys.path.insert(0, str(HERE))
    from scan_segment import page_image
    from PIL import Image, ImageDraw
    doc = _doc()
    crops = []
    for spec in a.specs:
        p, x0, x1, y0, y1 = map(int, spec.split(":"))
        c = page_image(doc, p).crop((x0, y0, x1, y1)).convert("RGB"); d = ImageDraw.Draw(c)
        for y in range((y0 // 20 + 1) * 20, y1, 20):
            d.line([(0, y - y0), (18 if y % 100 else 45, y - y0)], fill=(255, 0, 0))
            if y % 100 == 0:
                d.text((48, y - y0 - 6), str(y), fill=(255, 0, 0))
        d.text((c.width - 40, 2), f"p{p}", fill=(0, 0, 255)); crops.append(c)
    w = max(c.width for c in crops)
    out = Image.new("RGB", (w, sum(c.height + 6 for c in crops)), "black"); y = 0
    for c in crops:
        out.paste(c, (0, y)); y += c.height + 6
    _save(out, a, "grid.png", width=560)


def add(a):
    """Manual boxes. Question top = ~15 px ABOVE the number's text (else drop_cut_lines eats the first line)."""
    mf = Path(a.dir) / "manifest.json"
    orig = mf.with_name("manifest.orig.json")
    if not orig.exists():
        shutil.copy(mf, orig)
    m = json.loads(mf.read_text(encoding="utf-8"))
    by = {q["number"]: q for q in m}
    gut = {q["page"]: q["gutter"] for q in m}
    new = {int(k): v for k, v in json.loads(a.questions).items()}
    for n, (p, c, y0) in new.items():
        by[n] = {"number": n, "page": p, "column": c, "box": [0, y0, 0, 0], "file": f"q{n:03d}.png",
                 "gutter": gut.get(p) or a.gutter, "draft_text": "manual"}
    ends = {int(k): v for k, v in json.loads(a.end or "{}").items()}
    qs = [by[n] for n in sorted(by)]
    for i, q in enumerate(qs):
        nx = qs[i + 1] if i + 1 < len(qs) else None
        if q["number"] in ends:
            q["box"][3] = ends[q["number"]]
        elif q["number"] in new or (nx and nx["number"] in new):
            if nx and (nx["page"], nx["column"]) == (q["page"], q["column"]):
                q["box"][3] = nx["box"][1]           # ends where the next one starts
    mf.write_text(json.dumps(qs, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(qs)} questions in manifest; now run: scan_segment.py PDF --first F --last L --out {a.dir} --recrop")


def check(a):
    from PIL import Image, ImageDraw
    rows = []
    for n in a.numbers:
        im = Image.open(Path(a.dir) / f"q{n:03d}.png").convert("L")
        im = im.resize((260, int(im.height * 260 / im.width)))
        if a.tops:
            im = im.crop((0, 0, 260, min(im.height, 40)))
        rows.append((n, im))
    out = Image.new("RGB", (260, sum(i.height + 12 for _, i in rows)), "white"); d = ImageDraw.Draw(out); y = 0
    for n, im in rows:
        d.rectangle([0, y, 260, y + 10], fill=(255, 200, 200)); d.text((2, y - 1), str(n), fill="black")
        y += 12; out.paste(im, (0, y)); y += im.height
    _save(out, a, "check.png")


def done(a):
    up, dst = HERE / "out/upload_kitab", HERE / "out/images_kitab"
    moved = 0
    for s in a.sections:
        for f in up.glob(f"KT1-S{s:02d}-Q*.webp"):
            shutil.move(str(f), dst / f.name); moved += 1
    print(f"moved {moved}; upload_kitab left: {len(list(up.iterdir()))}; images_kitab: {len(list(dst.iterdir()))}")


def _path(a, name):
    Path(a.tmp).mkdir(parents=True, exist_ok=True)
    return str(Path(a.tmp) / name)


def _save(img, a, name, width=None):
    if width and img.width > width:
        img = img.resize((width, int(img.height * width / img.width)))
    p = _path(a, name); img.save(p); print(p)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tmp", default="/tmp/prepaz_scan")
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("strip"); s.add_argument("first", type=int); s.add_argument("last", type=int); s.set_defaults(f=strip)
    s = sub.add_parser("key"); s.add_argument("page", type=int); s.add_argument("top", type=float); s.add_argument("bottom", type=float); s.set_defaults(f=key)
    s = sub.add_parser("grid"); s.add_argument("specs", nargs="+"); s.set_defaults(f=grid)
    s = sub.add_parser("add"); s.add_argument("dir"); s.add_argument("questions"); s.add_argument("--end"); s.add_argument("--gutter", type=int, default=540); s.set_defaults(f=add)
    s = sub.add_parser("check"); s.add_argument("dir"); s.add_argument("numbers", type=int, nargs="+"); s.add_argument("--tops", action="store_true"); s.set_defaults(f=check)
    s = sub.add_parser("done"); s.add_argument("sections", type=int, nargs="+"); s.set_defaults(f=done)
    a = ap.parse_args()
    a.f(a)


if __name__ == "__main__":
    main()
