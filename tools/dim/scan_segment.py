"""Cuts questions out of a SCANNED test book (image-only PDF, two columns, numbered questions).

OCR is used only to find where each numbered question starts ("25. Hansı ..."); the question itself stays an image.
The OCR text of the lines is kept as a rough draft (it is NOT reliable for Azerbaijani letters and formulas).
Numbers are accepted only in increasing order, so sub-items like "1." inside a question are ignored.

Usage:
  python scan_segment.py BOOK.pdf --first 3 --last 8 --start 1 --out scan/kimya_I          (1-based PDF pages)
Output: <out>/qNNN.png (one question each), <out>/manifest.json and a report of missing numbers.
"""
import argparse
import json
import re
from pathlib import Path

import numpy as np
import pymupdf
from PIL import Image, ImageFilter, ImageOps
from rapidocr_onnxruntime import RapidOCR

# the character after the number must not be a dash: the page number "-15-" reads as "15-"
NUMBER = re.compile(r"^\s*(\d{1,3})(?!\d)\s*[.,)]?\s*[^\s\-–—]")
SCALE = 1.5          # OCR works on an enlarged copy of each column
PAD = 6
MAX_JUMP = 30
LEFT_TOLERANCE = 0.08  # a question number must sit this close (fraction of page width) to the column's left edge


def page_image(doc, page_no):
    """The scan embedded in the page, at its native resolution (grayscale)."""
    xref = doc[page_no - 1].get_images(full=True)[0][0]
    pix = pymupdf.Pixmap(doc, xref)
    if pix.n - pix.alpha >= 4:
        pix = pymupdf.Pixmap(pymupdf.csRGB, pix)
    mode = "L" if pix.n == 1 else "RGB"
    return Image.frombytes(mode, (pix.width, pix.height), pix.samples).convert("L")


def find_separator(img):
    """x of the thin vertical rule between the two columns (longest dark vertical run in the middle band)."""
    a = np.array(img) < 140
    h, w = a.shape
    best_x, best_run = w // 2, 0
    for x in range(int(w * 0.40), int(w * 0.60)):
        col = a[:, x]
        # longest run of dark pixels, tolerating 3px breaks
        run = longest = gap = 0
        for v in col:
            if v:
                run += 1
                gap = 0
            elif gap < 3 and run:
                gap += 1
                run += 1
            else:
                longest = max(longest, run)
                run = gap = 0
        longest = max(longest, run)
        if longest > best_run:
            best_x, best_run = x, longest
    return best_x if best_run > 0.35 * h else w // 2


def ocr_column(engine, img, x0, x1):
    """OCR of one column (enlarged). Returns [(x0, y0, x1, y1, text)] in page coordinates."""
    crop = img.crop((x0, 0, x1, img.height))
    big = ImageOps.autocontrast(crop, cutoff=1).resize((int(crop.width * SCALE), int(crop.height * SCALE)), Image.LANCZOS)
    result, _ = engine(np.array(big.convert("RGB")))
    lines = []
    for box, text, _conf in result or []:
        xs, ys = [p[0] / SCALE for p in box], [p[1] / SCALE for p in box]
        lines.append((x0 + min(xs), min(ys), x0 + max(xs), max(ys), text))
    return lines


def gutter_from_lines(lines, w):
    """x between the two columns: halfway between where the left text really ends and where the right text starts."""
    left = [l[2] for l in lines if l[0] < 0.42 * w and len(l[4]) > 6]
    right = [l[0] for l in lines if l[0] > 0.48 * w and len(l[4]) > 6]
    if len(left) < 5 or len(right) < 5:
        return None
    left_end, right_start = float(np.percentile(left, 92)), float(np.percentile(right, 8))
    return int((left_end + right_start) / 2) if left_end < right_start else None


def page_candidates(engine, img):
    """Per column, in reading order: (number, y, x0, text) of every line that looks like a question start.

    The page is OCR-ed twice (each column enlarged, and the whole page); the union finds more numbers than either alone."""
    w, h = img.size
    full = ocr_column(engine, img, 0, w)
    sep = gutter_from_lines(full, w) or find_separator(img)
    cols = []
    for a, b in ((0, sep - 3), (sep + 3, w)):
        lines = ocr_column(engine, img, a, b)
        for ln in full:  # lines the column pass did not see (same place = overlapping box)
            cx = (ln[0] + ln[2]) / 2
            if a <= cx < b and not any(abs(ln[1] - m[1]) < 12 and abs(ln[0] - m[0]) < 40 for m in lines):
                lines.append(ln)
        if not lines:
            cols.append(([], a, b, 0, []))
            continue
        left_edge = np.percentile([l[0] for l in lines if len(l[4]) > 8] or [a], 10)
        cands = []
        for x0, y0, x1, y1, text in sorted(lines, key=lambda l: l[1]):
            m = NUMBER.match(text)
            if m and x0 <= left_edge + LEFT_TOLERANCE * w:
                cands.append((int(m.group(1)), y0, x0, text))
        bottom = max(l[3] for l in lines if l[1] < h * 0.96)
        cols.append((cands, a, b, bottom, lines))
    return sep, cols


UPSCALE = 2


V_BOTTOM = 12   # extra rows below a question (tilted last lines); clean_crop removes the cut lines of the neighbour again


def best_angle(gray):
    """Small rotation (degrees) that makes the text lines horizontal: the angle with the most 'peaky' row ink profile."""
    ink = (np.array(gray) < 150).astype(np.uint8) * 255
    if ink.sum() == 0:
        return 0.0
    base = Image.fromarray(ink)
    best, best_score = 0.0, -1.0
    for ang in np.arange(-2.5, 2.51, 0.25):
        rows = np.array(base.rotate(float(ang), resample=Image.BILINEAR, fillcolor=0)).sum(axis=1).astype(np.float64)
        score = rows.var()
        if score > best_score:
            best, best_score = float(ang), score
    return best


def drop_cut_lines(crop):
    """Removes a partly visible text line at the very top/bottom (the end of the neighbouring question).
    A line is 'cut' when it touches the crop edge and is clearly shorter than the typical line."""
    a = np.array(crop) < 150
    rows = a.sum(axis=1) >= 2
    runs, start = [], None
    for y, v in enumerate(rows):
        if v and start is None:
            start = y
        if not v and start is not None:
            runs.append([start, y])
            start = None
    if start is not None:
        runs.append([start, len(rows)])
    # merge runs separated by very small gaps (accents / dots belong to their line)
    merged = []
    for r in runs:
        if merged and r[0] - merged[-1][1] <= 3:
            merged[-1][1] = r[1]
        else:
            merged.append(r)
    if len(merged) < 3:
        return crop
    heights = sorted(r[1] - r[0] for r in merged)
    typical = heights[len(heights) // 2]
    top, bottom = 0, crop.height
    if merged[0][0] <= 3 and merged[0][1] - merged[0][0] < 0.7 * typical:
        top = merged[1][0] - 3
    if merged[-1][1] >= crop.height - 3 and merged[-1][1] - merged[-1][0] < 0.7 * typical:
        bottom = merged[-2][1] + 3
    return crop.crop((0, max(0, top), crop.width, min(crop.height, bottom)))


def clean_crop(img, box):
    """Crops one question and makes it neat: scan borders are removed, the box is tightened to the ink, the paper is
    whitened, and the picture is enlarged 2x with a light sharpening so it stays readable on a phone."""
    crop = img.crop(box)
    a = np.array(crop)
    dark = a < 150
    # a dark strip at the very edge (scan shadow / page border) is not text: trim up to 8% of the width from each side
    limit = max(4, int(a.shape[1] * 0.08))
    left = 0
    while left < limit and dark[:, left].mean() >= 0.35:
        left += 1
    right = a.shape[1]
    while right > a.shape[1] - limit and dark[:, right - 1].mean() >= 0.35:
        right -= 1
    if left or right < a.shape[1]:
        crop, a = crop.crop((left, 0, right, crop.height)), a[:, left:right]
    # straighten the lines of this question (the book page is curved) and drop the cut lines of the neighbours
    angle = best_angle(crop)
    if abs(angle) >= 0.25:
        crop = crop.rotate(angle, resample=Image.BICUBIC, fillcolor=255)
    crop = drop_cut_lines(crop)
    a = np.array(crop)
    # tighten to the ink with an even margin
    ink = np.argwhere(a < 150)
    if len(ink):
        (y0, x0), (y1, x1) = ink.min(axis=0), ink.max(axis=0)
        m = 10
        crop = crop.crop((max(0, x0 - m), max(0, y0 - m), min(crop.width, x1 + m + 1), min(crop.height, y1 + m + 1)))
    arr = np.array(crop).astype(np.float32)
    paper = np.percentile(arr, 85)                       # the typical paper grey becomes pure white
    arr = np.clip(arr / max(paper, 1) * 255, 0, 255)
    out = Image.fromarray(arr.astype("uint8"))
    out = out.resize((out.width * UPSCALE, out.height * UPSCALE), Image.LANCZOS)
    out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=110, threshold=2))
    # 16 grey levels: the text stays crisp and the file is ~40% smaller
    return out.quantize(colors=16, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)


def find_gutter(img):
    """x of the blank vertical band between the two text columns (center of the longest ink-free run near the middle)."""
    a = np.array(img) < 150
    h, w = a.shape
    ink = a[int(h * 0.06):int(h * 0.95)].sum(axis=0)
    blank = ink <= max(2, 0.004 * h)
    best_start, best_len, start = None, 0, None
    for x in range(int(w * 0.38), int(w * 0.62)):
        if blank[x]:
            start = x if start is None else start
            if x - start + 1 > best_len:
                best_start, best_len = start, x - start + 1
        else:
            start = None
    if best_start is not None and best_len >= 8:
        return best_start + best_len // 2
    return find_separator(img)


CONT_TOP = 82        # rows above this are the running page header
CONT_MIN = 50        # a continuation needs at least this many rows of text above the first question of a column


def stitch_continuations(doc, items, out_dir):
    """A question that starts at the bottom of a column continues at the top of the next column (or page), above that
    column's first numbered question. When the numbers are consecutive, that text is cut and appended below the question.
    Returns the numbers of the questions that were extended."""
    pages, touched = {}, []
    for k, q in enumerate(items):
        if k == 0:
            continue
        prev = items[k - 1]
        first_in_column = (prev["page"], prev["column"]) != (q["page"], q["column"])
        if not first_in_column or q["number"] != prev["number"] + 1:
            continue
        y_top = q["box"][1]
        if y_top - CONT_TOP < CONT_MIN:
            continue
        if q["page"] not in pages:
            pages[q["page"]] = page_image(doc, q["page"])
        img = pages[q["page"]]
        gutter = q.get("gutter") or find_gutter(img)
        box = (0, CONT_TOP, gutter + 14, y_top) if q["column"] == 0 else (gutter - 9, CONT_TOP, img.width, y_top)
        extra = clean_crop(img, box).convert("L")
        if extra.height < 40:
            continue
        base = Image.open(out_dir / prev["file"]).convert("L")
        canvas = Image.new("L", (max(base.width, extra.width), base.height + extra.height + 8), 255)
        canvas.paste(base, (0, 0))
        canvas.paste(extra, (0, base.height + 8))
        canvas.quantize(colors=16, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(out_dir / prev["file"], optimize=True)
        prev["continued_from"] = {"page": q["page"], "column": q["column"], "rows": [CONT_TOP, y_top]}
        touched.append(prev["number"])
    return touched


def recrop(args):
    """Re-cuts the images from the manifest (same questions and heights) with the gutter between the columns found from the ink.
    No OCR: fast. Used after the cutting code changed."""
    manifest = json.loads((args.out / "manifest.json").read_text(encoding="utf-8"))
    doc = pymupdf.open(args.pdf)
    pages = {}
    for q in manifest:
        if q["page"] not in pages:
            img = page_image(doc, q["page"])
            pages[q["page"]] = (img, q.get("gutter") or find_gutter(img))
        img, gutter = pages[q["page"]]
        w, h = img.size
        _x0, y0, _x1, y1 = q["box"]       # the manifest keeps the question's own rows; the margin is added only for cutting
        top, bottom = y0, min(h, y1 + V_BOTTOM)
        box = (0, top, gutter + 14, bottom) if q["column"] == 0 else (gutter - 9, top, w, bottom)   # a little past the middle: the OCR gutter is only an estimate
        q["box"] = [box[0], y0, box[2], y1]
        clean_crop(img, box).save(args.out / q["file"], optimize=True)
    for q in manifest:
        q.pop("continued_from", None)
    touched = stitch_continuations(doc, manifest, args.out)
    (args.out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"re-cut {len(manifest)} questions; gutters: " + ", ".join(f"p{p}={g}" for p, (_i, g) in sorted(pages.items())))
    print(f"continued onto the next column/page: {touched}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf", type=Path)
    ap.add_argument("--first", type=int, required=True)
    ap.add_argument("--last", type=int, required=True)
    ap.add_argument("--start", type=int, default=1, help="number of the first question of the section")
    ap.add_argument("--stop", type=int, default=None, help="last question number of the section")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--skip-above", action="append", default=[], metavar="PAGE:COLUMN:Y",
                    help="ignore everything above this row in that column (e.g. the end of the previous section); repeatable")
    ap.add_argument("--pad", type=int, default=PAD, help="rows kept above each question number (valence marks etc.)")
    ap.add_argument("--recrop", action="store_true", help="re-cut the images of an existing --out folder (no OCR)")
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    if args.recrop:
        return recrop(args)
    skip = {}
    for spec in args.skip_above:
        pg, col, y = (int(v) for v in spec.split(":"))
        skip[(pg, col)] = y
    engine = RapidOCR()
    doc = pymupdf.open(args.pdf)

    items, expected, missing = [], args.start, []
    for page_no in range(args.first, args.last + 1):
        img = page_image(doc, page_no)
        w, h = img.size
        sep, cols = page_candidates(engine, img)
        found_here = []
        for ci, (cands, a, b, bottom, lines) in enumerate(cols):
            accepted = []
            for num, y, x0, text in cands:
                if y < skip.get((page_no, ci), -1):
                    continue
                if args.stop and num > args.stop:
                    continue
                if expected <= num <= expected + MAX_JUMP:   # increasing; the OCR may have missed some in between
                    missing += list(range(expected, num))
                    accepted.append((num, y))
                    expected = num + 1
            for i, (num, y) in enumerate(accepted):
                top = max(0, y - args.pad)
                nxt = accepted[i + 1][1] - args.pad if i + 1 < len(accepted) else bottom + PAD
                inside = [l for l in lines if top - 2 <= l[1] < nxt]
                box = (int(a), int(top), int(b), int(min(h, nxt + V_BOTTOM)))   # whole column; clean_crop tightens it
                draft = " ".join(l[4] for l in sorted(inside, key=lambda l: (l[1], l[0])))
                file = f"q{num:03d}.png"
                clean_crop(img, box).save(args.out / file, optimize=True)
                items.append({"number": num, "page": page_no, "column": ci, "box": list(box), "file": file, "gutter": sep,
                              "draft_text": draft})
                found_here.append(num)
        print(f"page {page_no}: {found_here}")

    touched = stitch_continuations(doc, items, args.out)
    if touched:
        print(f"continued onto the next column/page: {touched}")
    (args.out / "manifest.json").write_text(json.dumps(items, ensure_ascii=False, indent=1), encoding="utf-8")
    last = args.stop or expected - 1
    absent = sorted(set(range(args.start, last + 1)) - {q["number"] for q in items})
    print(f"\nfound {len(items)} of {last - args.start + 1}; missing: {absent}")


if __name__ == "__main__":
    main()
