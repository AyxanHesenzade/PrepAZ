"""Extracts biology questions (IV group) from the DIM PDFs into out/parsed_biologiya.json.

Same parser as chemistry (extract_kimya.py); biology has no formulas, so no chemistry markup is needed.
Usage: python extract_biologiya.py
"""
import collections
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "common"))
import paths  # noqa: E402,F401
from extract_kimya import FILES, extract_rows  # noqa: E402
from subjects import SUBJECTS  # noqa: E402

OUT = SUBJECTS["biologiya"]["out"]

# Biology appears only in the IV group papers.
BIO_FILES = [f for f in FILES if f[2] == "4"]


def main():
    OUT.mkdir(exist_ok=True)
    rows = extract_rows(BIO_FILES, "Biologiya")
    (OUT / "parsed_biologiya.json").write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
    print("total", len(rows))
    topics = collections.Counter(r["topic"] or "(mövzu yoxdur)" for r in rows)
    print(f"{len(topics)} DIM topics:")
    for t, c in topics.most_common():
        print(f"  {c:3d}  {t}")


if __name__ == "__main__":
    main()
