"""Downloads DIM PDFs into tools/dim/raw (skips files that already exist)."""
import time
import urllib.request
from pathlib import Path

RAW = Path(__file__).parent / "raw"
SOURCES = {
    "2026-07-12_iv": "https://dim.gov.az/CkImage/4_cu_qrup_1783846566.pdf",
    "2026-06-07_iv": "https://dim.gov.az/CkImage/4_cu_qrup_1780824862.pdf",
    "2025-07-13_iv": "https://dim.gov.az/CkImage/4_cu_qrup_1752476942.pdf",
    "2025-07-13_i": "https://dim.gov.az/CkImage/1_ci_qrup_1752476895.pdf",
}

for name, url in SOURCES.items():
    target = RAW / f"{name}.pdf"
    if target.exists():
        print("skip", name)
        continue
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        target.write_bytes(r.read())
    print("ok", name, target.stat().st_size)
    time.sleep(3)
