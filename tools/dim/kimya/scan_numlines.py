"""List lines that start with a question number in every column of pdf pages A..B: python scan_numlines.py A B out.json (y = text top; box top = y - 14). Finds most questions the sequential OCR in scan_segment.py misses; curled page corners still need scan_tool.py grid."""
import sys, re, json
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "common"))
import paths  # noqa: E402,F401  (puts common/, kimya/, biologiya/ on sys.path)
import scan_tool as t, scan_segment as s, numpy as np
from rapidocr_onnxruntime import RapidOCR
ocr = RapidOCR(); d = t._doc()
a, b = int(sys.argv[1]), int(sys.argv[2])
out = {}
for p in range(a, b + 1):
    img = s.page_image(d, p).convert('RGB'); W = img.width
    g = s.find_gutter(img.convert("L"))
    for c, (x0, x1) in enumerate(((0, g + 10), (g - 30, W))):
        res, _ = ocr(np.array(img.crop((x0, 0, x1, img.height))))
        xs = [min(bb[0] for bb in box) for box, txt, sc in res or []]
        left = np.percentile(xs, 10) if xs else 0
        rows = []
        for box, txt, sc in res or []:
            bx = min(bb[0] for bb in box); by = min(bb[1] for bb in box)
            m = re.match(r'^\s*(\d{1,3})\s*[.,]', txt)
            if m and bx < left + 45:
                rows.append((int(by), int(m.group(1))))
            elif re.search(r'(traf|Hidrogen|[Dd]uzlar,)', txt):
                rows.append((int(by), txt[:14]))
        out[f"{p}:{c}:{g}"] = sorted(rows)
        print(p, c, g, sorted(rows), flush=True)
json.dump(out, open(sys.argv[3], 'w'))
