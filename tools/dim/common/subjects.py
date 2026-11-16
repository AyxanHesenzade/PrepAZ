"""Per-subject settings shared by check.py, import_questions.py and the build scripts.
Every subject keeps its own data in tools/dim/<slug>/ (images/, out/); see paths.py."""
import paths


def _subject(slug, name, prefix, sections):
    base = paths.subject_dir(slug)
    out = base / "out"
    return {
        "name": name,
        "prefix": prefix,
        "dir": base,
        "images": base / "images",
        "out": out,
        "webp": out / "webp",
        "excel": out / f"{slug}_dim_yoxlama.xlsx",
        "sql": out / f"import_{slug}.sql",
        "sections": sections,
    }


SUBJECTS = {
    "kimya": _subject("kimya", "Kimya", "KIM", ["Ümumi kimya", "Qeyri-üzvi kimya", "Üzvi kimya"]),
    "biologiya": _subject("biologiya", "Biologiya", "BIO",
                          ["Botanika", "Zoologiya", "İnsan anatomiyası və fiziologiyası", "Ümumi biologiya"]),
}
