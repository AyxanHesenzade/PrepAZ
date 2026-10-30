"""Per-subject settings shared by check.py, import_questions.py and the build scripts."""
from pathlib import Path

OUT = Path(__file__).parent / "out"

SUBJECTS = {
    "kimya": {
        "name": "Kimya",
        "prefix": "KIM",
        "excel": OUT / "kimya_dim_yoxlama.xlsx",
        "sql": OUT / "import_kimya.sql",
        "sections": ["Ümumi kimya", "Qeyri-üzvi kimya", "Üzvi kimya"],
    },
    "biologiya": {
        "name": "Biologiya",
        "prefix": "BIO",
        "excel": OUT / "biologiya_dim_yoxlama.xlsx",
        "sql": OUT / "import_biologiya.sql",
        "sections": ["Botanika", "Zoologiya", "İnsan anatomiyası və fiziologiyası", "Ümumi biologiya"],
    },
}
