"""Fixes the question boxes of a scanned book section from the INK of the page, not from OCR.

Why: OCR finds most question numbers, but misses some (fractions, mixed numbers), invents others ("15 km" inside a
sentence), and its top edge cuts tall fractions (the number stands in the middle of a fraction).
Here you tell the tool which questions stand in which page column; it finds the blank bands between them and writes the
cuts into manifest.json. Then run `scan_segment.py ... --recrop`.

Usage (from tools/dim/<subject>):
  python ../common/gap_fill.py BOOK.pdf scan/<dir> --region PAGE:COL:FIRST-LAST[:TOP[:BOTTOM]] ... [--drop 15,16]
    PAGE  1-based pdf page, COL 0 = left column, 1 = right column
    FIRST-LAST  the question numbers that stand in this column, top to bottom (e.g. 7-16)
    TOP / BOTTOM  rows where the questions start/end (default: first found question's top / 1192 (page images are ~800x1200)). Give TOP when the first
                  question of the region is missing or a heading stands above it.
  --drop N,N  manifest entries to delete first (OCR false positives)
Questions the OCR found keep their top as a hint: the tool moves it to the blank band just above the question.
Question starts are found from the page ink: numbers stand at the left margin, other lines are indented. The count must match the numbers you give.
Then check with scan_tool.py check (only the ones that were missing).
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
import pymupdf

sys.path.insert(0, str(Path(__file__).resolve().parent))
from scan_segment import find_gutter, page_image  # noqa: E402

V_BOTTOM = 12        # scan_segment.recrop cuts down to y1 + V_BOTTOM
MIN_GAP = 9          # blank rows that can separate two questions
INK = 140


def blank_runs(img, page_gutter, col, lo, hi):
    """Blank row runs [(start, end)] (end exclusive) inside rows lo..hi of one column."""
    a = np.array(img) < INK
    h, w = a.shape
    x0, x1 = (12, page_gutter - 6) if col == 0 else (page_gutter + 6, w - 12)
    band = a[:, x0:x1]
    rule = band.mean(axis=0) > 0.3                      # vertical rules are not text
    rule = np.convolve(rule, np.ones(5), mode="same") > 0
    band = band.copy()
    band[:, rule] = False
    ink_rows = band.sum(axis=1) >= 3
    runs, start = [], None
    for y in range(lo, min(hi, h)):
        if not ink_rows[y]:
            if start is None:
                start = y
        elif start is not None:
            runs.append((start, y))
            start = None
    if start is not None:
        runs.append((start, min(hi, h)))
    return [r for r in runs if r[1] - r[0] >= MIN_GAP]


def text_lines(img, page_gutter, col, lo, hi):
    """Text lines [(y0, y1, min_x)] of one column (ink rows merged across gaps < 4 px), min_x = leftmost ink column."""
    a = np.array(img) < INK
    h, w = a.shape
    x0, x1 = (12, page_gutter - 6) if col == 0 else (page_gutter + 6, w - 12)
    band = a[:, x0:x1].copy()
    rule = band.mean(axis=0) > 0.3
    rule = np.convolve(rule, np.ones(5), mode="same") > 0
    band[:, rule] = False
    rows = band.sum(axis=1) >= 3
    lines, start, last = [], None, None
    for y in range(max(0, lo), min(hi, h)):
        if rows[y]:
            if start is None:
                start = y
            last = y
        elif start is not None and y - last >= 4:
            lines.append((start, last + 1))
            start = None
    if start is not None:
        lines.append((start, last + 1))
    out = []
    for y0, y1 in lines:
        cols = np.where(band[y0:y1].sum(axis=0) >= 2)[0]
        if y1 - y0 >= 7:                                   # specks (watermark edge, page rule ends) are not text
            out.append((y0, y1, int(cols[0]) if len(cols) else 999))
    return out


def question_starts(lines, margin, min_gap=MIN_GAP, window=50, slack=8):
    """Blocks of lines (separated by blank gaps >= min_gap) whose first `window` rows touch the left margin begin a question.
    Returns [(cut_y, first_line_y0)]: the cut lies in the blank gap above the block."""
    blocks, cur = [], []
    for ln in lines:
        if cur and ln[0] - cur[-1][1] >= min_gap:
            blocks.append(cur)
            cur = []
        cur.append(ln)
    if cur:
        blocks.append(cur)
    starts, prev_end = [], None
    for b in blocks:
        y0 = b[0][0]
        first = None
        if any(ln[0] <= y0 + window and ln[2] <= margin + slack for ln in b):
            first = y0
            cut = y0 if prev_end is None else (prev_end + y0) // 2
            starts.append((cut, y0))
        # a margin line further down the block (the neighbour question is packed closer than min_gap): also a start
        last_start = first if first is not None else -10**6
        for i, ln in enumerate(b):
            if i == 0 or ln[0] <= last_start + window or ln[2] > margin + slack or b[i - 1][2] <= margin + slack:
                continue
            starts.append(((b[i - 1][1] + ln[0]) // 2, ln[0]))
            last_start = ln[0]
        prev_end = b[-1][1]
    starts.sort()
    return starts


def header_rule_y(img, page_gutter, col, lo=30, hi=110):
    """Row of the horizontal rule under the running page header (a long thin dark line), or None."""
    a = np.array(img) < INK
    x0, x1 = (12, page_gutter - 6) if col == 0 else (page_gutter + 6, a.shape[1] - 12)
    band = a[lo:hi, x0:x1]
    frac = np.convolve(band.mean(axis=1), np.ones(5), mode="same")      # the rule may be tilted over a few rows
    ys = np.where(frac >= 0.55)[0]
    return int(ys[0]) + lo if len(ys) else None


def parse_region(spec):
    parts = spec.split(":")
    page, col = int(parts[0]), int(parts[1])
    a, b = parts[2].split("-")
    top = int(parts[3]) if len(parts) > 3 and parts[3] else None
    bottom = int(parts[4]) if len(parts) > 4 and parts[4] else 1192
    return page, col, list(range(int(a), int(b) + 1)), top, bottom


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf", type=Path)
    ap.add_argument("dir", type=Path)
    ap.add_argument("--region", action="append", required=True)
    ap.add_argument("--drop", default="")
    a = ap.parse_args()

    mf = a.dir / "manifest.json"
    orig = mf.with_name("manifest.orig.json")
    if not orig.exists():
        orig.write_text(mf.read_text(encoding="utf-8"), encoding="utf-8")
    manifest = json.loads(mf.read_text(encoding="utf-8"))
    drop = {int(x) for x in a.drop.split(",") if x.strip()}
    by = {q["number"]: q for q in manifest if q["number"] not in drop}
    doc = pymupdf.open(a.pdf)
    pages = {}

    for spec in a.region:
        page, col, numbers, top, bottom = parse_region(spec)
        if page not in pages:
            img = page_image(doc, page)
            pages[page] = (img, find_gutter(img))
        img, gutter = pages[page]
        found = {n: by[n] for n in numbers if n in by and by[n]["page"] == page and by[n]["column"] == col}
        if top is None:
            top = min(q["box"][1] for q in found.values()) if found else 66
        if top <= 95:                                  # a column that starts at the page top: begin under the header rule
            ry = header_rule_y(img, gutter, col)
            if ry is not None:
                top = ry + 18                         # lines are read from top-10 = ry+8: below a tilted rule (up to ~18 rows)
        lines = text_lines(img, gutter, col, top - 10, bottom)
        # the left margin where question numbers stand: from the OCR-found questions of this column, else the smallest line start
        xs = []
        for q in found.values():
            near = [ln[2] for ln in lines if q["box"][1] - 6 <= ln[0] <= q["box"][1] + 40]
            if near:
                xs.append(min(near))
        margin = int(np.median(xs)) if xs else min(ln[2] for ln in lines)
        starts = [st for st in question_starts(lines, margin) if st[1] >= top - 10]
        if len(starts) != len(numbers):
            print(f"{spec}: found {len(starts)} question starts, expected {len(numbers)} (margin x={margin}): "
                  + ", ".join(f"{c}/{y}" for c, y in starts))
            sys.exit("Adjust TOP/BOTTOM of the region (watermark, heading) or add the question by hand.")
        cuts = {i: starts[i][0] for i in range(len(numbers))}
        cuts[0] = starts[0][1] - 7     # a little blank above the first question: scan_segment drops a short line that touches the crop edge
        order = [cuts[i] for i in range(len(numbers))]
        if order != sorted(order):
            sys.exit(f"{spec}: cuts are not increasing: {order}")
        for i, n in enumerate(numbers):
            y0 = order[i]
            y1 = (order[i + 1] if i + 1 < len(numbers) else bottom) - V_BOTTOM
            q = by.get(n)
            if q is None or q["page"] != page or q["column"] != col:
                q = {"number": n, "file": f"q{n:03d}.png", "draft_text": "gap_fill"}
                by[n] = q
            q.update({"page": page, "column": col, "gutter": gutter, "box": [0, y0, 0, y1]})
        status = ", ".join(f"{n}{'' if n in found else '*'}@{order[i]}" for i, n in enumerate(numbers))
        print(f"p{page} c{col}: {status}")

    out = sorted(by.values(), key=lambda q: q["number"])
    mf.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(out)} questions in manifest ('*' = was missing). Now: scan_segment.py {a.pdf.name} --first F --last L --out {a.dir} --recrop")


if __name__ == "__main__":
    main()
