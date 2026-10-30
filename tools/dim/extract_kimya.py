"""Extracts chemistry questions from DIM PDFs into out/parsed.json and crops figures to images/.

Usage: python extract_kimya.py
"""
import json
import re
from pathlib import Path

import pymupdf
from PIL import Image

from chem_text import MARKS, SUB_C, SUB_O, SUP_C, SUP_O, map_char, to_tex

ROOT = Path(__file__).parent
RAW, OUT, IMAGES = ROOT / "raw", ROOT / "out", ROOT / "images"

# file stem -> (exam label for "mənbədə yeri", group, year, url)
FILES = [
    ("2026-07-12_iv", "2026-07-12 qəbul, IV qrup", "4", 2026),
    ("2026-06-07_iv", "2026-06-07 qəbul, IV qrup", "4", 2026),
    ("2025-07-13_iv", "2025-07-13 qəbul, IV qrup", "4", 2025),
    ("2025-07-13_i", "2025-07-13 qəbul, I qrup", "1", 2025),
    # second round: appended at the END so the codes of the first round (KIM-0001...) never change
    ("2026-07-12_i", "2026-07-12 qəbul, I qrup", "1", 2026),
    ("2026-06-07_i", "2026-06-07 qəbul, I qrup", "1", 2026),
    ("2025-06-01_i", "2025-06-01 qəbul, I qrup", "1", 2025),
    ("2025-06-01_iv", "2025-06-01 qəbul, IV qrup", "4", 2025),
]
SUBJECT_HEADINGS = {"Biologiya", "Fizika", "Riyaziyyat", "Kimya", "Tarix", "Coğrafiya", "Informatika"}

HEADER = re.compile(r"^\s*([A-D])\s+variantı\s+(\d+)\s+saylı\s+test\s+tapşırığı")
FOOTER = [re.compile(p) for p in (r"^\s*\d-c[ıiuü]\s+qrup", r"www\.dim\.gov\.az", r"^\s*\d{2}\.\d{2}\.\d{4}\s*$")]
RE_TOPIC = re.compile(r"^[\W_]*M[öo]vzu\s*:\s*")
RE_CONTEXT = re.compile(r"^\s*Sizə\s+təqdim\s+olunmuş\s+situasiya")
RE_CLASS = re.compile(r"^\s*Sinif\s*:\s*")
RE_EXPL = re.compile(r"^\s*[İI]zah\s*:?\s*")
RE_ANSWER = re.compile(r"^\s*D[oö]ğru\s+cavab\s*:\s*")
SINIF_NUM = {"VII": "7", "VIII": "8", "IX": "9", "X": "10", "XI": "11"}


def page_arrows(page):
    """Reaction arrows are drawings, not text. Returns [{cx, cy, x0, x1, char}]; two stacked arrows = equilibrium."""
    raw = []
    for d in page.get_drawings():
        r = d["rect"]
        if 2 <= r.height <= 8 and r.width >= 10 and len(d["items"]) >= 4:
            raw.append({"cx": (r.x0 + r.x1) / 2, "cy": (r.y0 + r.y1) / 2, "x0": r.x0, "x1": r.x1, "char": "→"})
    merged = []
    for a in sorted(raw, key=lambda a: (a["cy"], a["cx"])):
        for m in merged:
            if abs(m["cx"] - a["cx"]) < 8 and abs(m["cy"] - a["cy"]) < 1:
                break  # same arrow drawn twice (fill + stroke)
            if abs(m["cx"] - a["cx"]) < 8 and abs(m["cy"] - a["cy"]) < 9:
                m["char"] = "⇌"
                break
        else:
            merged.append(a)
    return merged


def line_markup(line, unknown, arrows=()):
    """Rebuilds a line's text; sub/superscripts (smaller, shifted baseline) get markers."""
    spans = [s for s in line["spans"] if s["text"]]
    if not spans:
        return ""
    dom = max(spans, key=lambda s: len(s["text"].strip()) * s["size"])
    base_y, base_size = dom["origin"][1], dom["size"]
    pending = sorted(arrows, key=lambda a: a["cx"])
    out = []
    for s in spans:
        while pending and s["bbox"][0] >= pending[0]["cx"]:
            out.append(" " + pending.pop(0)["char"] + " ")
        text = "".join(map_char(c, unknown) for c in s["text"])
        small = s["size"] < 0.85 * base_size
        if small and not text.strip():
            out.append(text)
        elif small and s["origin"][1] > base_y + 0.3:
            out.append(SUB_O + text.strip() + SUB_C)
        elif small and s["origin"][1] < base_y - 0.3:
            out.append(SUP_O + text.strip() + SUP_C)
        else:
            out.append(text)
    out += [" " + a["char"] + " " for a in pending]
    txt = "".join(out)
    # adjacent markers of the same kind merge: ⟨sub⟩2⟨/sub⟩⟨sub⟩n⟨/sub⟩
    return txt.replace(SUB_C + SUB_O, "").replace(SUP_C + SUP_O, "")


def collect_lines(doc, subject="Kimya"):
    """Lines of one subject section of a PDF (chemistry by default): [{page, bbox, text, unknown, tags}] with footers removed."""
    lines, active = [], False
    for pn, page in enumerate(doc):
        height = page.rect.height
        arrows, used, page_lines = page_arrows(page), set(), []
        for block in page.get_text("dict")["blocks"]:
            for ln in block.get("lines", []):
                x0, y0, x1, y1 = ln["bbox"]
                mine = [
                    i for i, a in enumerate(arrows)
                    if i not in used and y0 - 3 <= a["cy"] <= y1 + 3 and x0 - 6 <= a["cx"] <= x1 + 80
                ]
                used.update(mine)
                unknown = set()
                text = line_markup(ln, unknown, [arrows[i] for i in mine])
                plain = text.strip()
                if not plain:
                    continue
                if plain in SUBJECT_HEADINGS:
                    active = plain == subject
                    continue
                if not active:
                    continue
                if any(f.search(plain) for f in FOOTER):
                    continue
                if re.fullmatch(r"\d{1,2}", plain) and (y0 < 90 or y0 > height - 90):
                    continue
                entry = {"page": pn, "bbox": ln["bbox"], "text": text, "unknown": unknown, "tags": set(),
                         "arrows": [arrows[i] for i in mine]}
                lines.append(entry)
                page_lines.append(entry)
        # text lines right above/below an attached arrow are reaction conditions (t, kat, H+ ...)
        for host in page_lines:
            for a in host["arrows"]:
                for other in page_lines:
                    ox0, oy0, ox1, oy1 = other["bbox"]
                    short = len(re.sub(f"[{MARKS}]", "", other["text"]).strip()) <= 16
                    if (
                        other is not host and short and ox0 <= a["x1"] and ox1 >= a["x0"]
                        and (ox1 - ox0) <= (a["x1"] - a["x0"]) + 40 and abs((oy0 + oy1) / 2 - a["cy"]) <= 14
                    ):
                        host["tags"].add("oxun şərti (üstündəki/altındakı mətn)")
    return lines


def split_blocks(lines):
    blocks, cur, in_header = [], None, False
    for ln in lines:
        m = HEADER.match(ln["text"])
        if m:
            if not in_header:
                cur = {"headers": [], "body": []}
                blocks.append(cur)
                in_header = True
            cur["headers"].append((m.group(1), int(m.group(2))))
        else:
            in_header = False
            if cur is not None:
                cur["body"].append(ln)
    return blocks


def collapse(s):
    return re.sub(r"\s+", " ", s).strip()


def plain_key(s):
    s = re.sub(f"[{MARKS}]", "", s)
    s = s.replace("−", "-").replace("–", "-")
    return re.sub(r"[\s.;,]", "", s).lower()


def parse_options(text):
    """Returns (stem, {letter: text}) or (text, {}) when there are no A-E options."""
    pos, cursor = {}, 0
    for letter in "ABCDE":
        m = re.compile(rf"(?<![\w{MARKS}]){letter}\)\s").search(text, cursor)
        if not m:
            return text, {}
        pos[letter] = m
        cursor = m.end()
    letters = list("ABCDE")
    opts = {}
    for i, L in enumerate(letters):
        end = pos[letters[i + 1]].start() if i + 1 < 5 else len(text)
        opts[L] = text[pos[L].end():end]
    return text[: pos["A"].start()], opts


def parse_block(block, exam):
    body = block["body"]
    ctx_start = next((i for i, l in enumerate(body) if RE_CONTEXT.match(l["text"])), None)
    context = body[ctx_start:] if ctx_start is not None else []
    body = body[:ctx_start] if ctx_start is not None else body
    idx = {}
    for i, ln in enumerate(body):
        for name, rx in (("topic", RE_TOPIC), ("class", RE_CLASS), ("expl", RE_EXPL), ("ans", RE_ANSWER)):
            if name not in idx and rx.match(ln["text"]):
                idx[name] = i
    order = sorted(idx.items(), key=lambda kv: kv[1])
    seg = {}
    for k, (name, i) in enumerate(order):
        j = order[k + 1][1] if k + 1 < len(order) else len(body)
        rx = {"topic": RE_TOPIC, "class": RE_CLASS, "expl": RE_EXPL, "ans": RE_ANSWER}[name]
        first = rx.sub("", body[i]["text"], count=1)
        seg[name] = collapse(" ".join([first] + [l["text"] for l in body[i + 1:j]]))
    m = re.match(r"^(VIII|VII|XI|IX|X|\d{1,2}(?:\s*,\s*\d{1,2})*)\s*(.*)$", seg.get("class", ""))
    if m:
        seg["class"] = m.group(1)
        if m.group(2):
            seg["expl"] = collapse(m.group(2) + " " + seg.get("expl", ""))
    # situation tasks have no topic/answer: the question ends where the explanation starts
    q_end = idx.get("topic", idx.get("expl", len(body)))
    unknown = set().union(*(l["unknown"] for l in block["body"])) if block["body"] else set()
    tags = set().union(*(l["tags"] for l in block["body"])) if block["body"] else set()
    return {
        "tags": tags,
        "headers": block["headers"],
        "q_lines": body[:q_end],
        "expl_lines": body[idx["expl"]: idx.get("ans", len(body))] if "expl" in idx else [],
        "context_lines": context,
        "topic": seg.get("topic", ""),
        "class": seg.get("class", ""),
        "expl": seg.get("expl", ""),
        "answer": seg.get("ans"),
        "unknown": unknown,
        "exam": exam,
    }


def column_areas(doc, q_lines, pad=4):
    """[(page_no, Rect)] of the question area, restricted to its text column (pages are two-column)."""
    groups = {}
    for l in q_lines:
        page = doc[l["page"]]
        mid, bb = page.rect.width / 2, l["bbox"]
        if bb[2] - bb[0] > 0.6 * page.rect.width:
            col = 2  # full-width line
        else:
            col = 0 if (bb[0] + bb[2]) / 2 < mid else 1
        groups.setdefault((l["page"], col), []).append(bb)
    areas = []
    for (pn, col), boxes in sorted(groups.items()):
        page = doc[pn]
        mid = page.rect.width / 2
        x0, x1 = {0: (page.rect.x0 + 24, mid - 2), 1: (mid + 2, page.rect.x1 - 24)}.get(
            col, (page.rect.x0 + 24, page.rect.x1 - 24)
        )
        areas.append((pn, pymupdf.Rect(x0, min(b[1] for b in boxes) - pad, x1, max(b[3] for b in boxes) + pad)))
    return areas


def crop_figure(doc, q_lines, name, pad=4):
    """Crops the question area into one PNG (column parts stitched top to bottom)."""
    imgs = []
    for pn, rect in column_areas(doc, q_lines, pad):
        tmp = IMAGES / f"_{name}.png"
        doc[pn].get_pixmap(matrix=pymupdf.Matrix(2, 2), clip=rect).save(tmp)
        imgs.append(Image.open(tmp).copy())
        tmp.unlink()
    canvas = Image.new("RGB", (max(i.width for i in imgs), sum(i.height for i in imgs)), "white")
    y = 0
    for im in imgs:
        canvas.paste(im, (0, y))
        y += im.height
    canvas.save(IMAGES / f"{name}.png")
    return True


def visual_reasons(doc, q_lines):
    """Images/drawings in the question's own column area (tables, diagrams, structural formulas)."""
    reasons = set()
    for pn, area in column_areas(doc, q_lines):
        page = doc[pn]
        if any(pymupdf.Rect(i["bbox"]).intersects(area) for i in page.get_image_info()):
            reasons.add("şəkil/struktur formul")
        drawings = [pymupdf.Rect(d["rect"]) for d in page.get_drawings() if pymupdf.Rect(d["rect"]).intersects(area)]
        if sum(1 for r in drawings if r.width < 1.5 and r.height >= 8) >= 2:
            reasons.add("cədvəl")
        if any(r.width >= 25 and r.height >= 12 for r in drawings):
            reasons.add("sxem/qrafik")
        boxes = [l["bbox"] for l in q_lines if l["page"] == pn]
        arrows = [
            a for a in page_arrows(page)
            if area.contains(pymupdf.Point(a["cx"], a["cy"]))
            and not any(b[1] - 3 <= a["cy"] <= b[3] + 3 and b[0] - 6 <= a["cx"] <= b[2] + 80 for b in boxes)
        ]
        if arrows:
            reasons.add("reaksiya oxu (mətndə yoxdur)")
    return reasons


def lines_text(lines):
    return " ".join(l["text"] for l in lines)


def lines_data(lines):
    return [{"page": l["page"], "bbox": list(l["bbox"])} for l in lines]


def extract_rows(files, subject):
    """Parsed question rows of one subject from the given [(stem, exam, group, year)] PDFs."""
    IMAGES.mkdir(exist_ok=True)
    rows = []
    for stem, exam, group, year in files:
        doc = pymupdf.open(RAW / f"{stem}.pdf")
        blocks = [parse_block(b, exam) for b in split_blocks(collect_lines(doc, subject))]
        print(f"{stem}: {len(blocks)} questions")
        shared = []  # situation text that applies to the following topic-less tasks
        for b in blocks:
            if b["context_lines"]:
                shared = b["context_lines"]
            elif b["topic"]:
                shared = []
            ctx = shared if not b["topic"] else []
            a_no = next((n for L, n in b["headers"] if L == "A"), b["headers"][0][1])
            rows.append({
                "file": stem, "exam": exam, "group": group, "year": year, "a_no": a_no,
                "q_text": lines_text(b["q_lines"]), "ctx_text": lines_text(ctx),
                "topic": b["topic"], "class": b["class"], "expl": b["expl"], "answer": b["answer"],
                "unknown": sorted(b["unknown"]), "tags": sorted(b["tags"]),
                "visual": sorted(visual_reasons(doc, ctx + b["q_lines"])),
                "q_lines": lines_data(ctx + b["q_lines"]),
                "expl_visual": sorted(visual_reasons(doc, b["expl_lines"])) if b["expl_lines"] else [],
                "expl_q_lines": lines_data(b["expl_lines"]),
                "short_lines": sum(
                    1 for l in b["q_lines"]
                    if len(re.sub(f"[{MARKS}]", "", l["text"]).strip()) <= 14 and not re.match(r"\s*A\)", l["text"])
                ),
            })
    return rows


def main():
    OUT.mkdir(exist_ok=True)
    rows = extract_rows(FILES, "Kimya")
    (OUT / "parsed.json").write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
    print("total", len(rows))


if __name__ == "__main__":
    main()
