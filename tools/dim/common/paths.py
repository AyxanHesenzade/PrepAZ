"""Folder layout of tools/dim (one place; scripts import this instead of guessing paths).

  common/      shared code (DIM PDF parser, import SQL, image tools, DB tests) and raw/ (DIM PDFs used by every subject)
  kimya/       chemistry: book PDF, images/, out/, scan/, chemistry-only scripts
  biologiya/   biology:   images/, out/, biology-only scripts

Importing this module also puts all three folders on sys.path, so `import topic_map` etc. work from any script.
"""
import sys
from pathlib import Path

DIM = Path(__file__).resolve().parents[1]
COMMON = DIM / "common"
RAW = COMMON / "raw"
REPO = DIM.parents[1]          # the Flutter project root (db/, test/ ...)

for _d in (COMMON, DIM / "kimya", DIM / "biologiya"):
    if str(_d) not in sys.path:
        sys.path.append(str(_d))


def subject_dir(slug):
    return DIM / slug
