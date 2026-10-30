"""Maps DIM biology topic names (49 variants) to a unified section/topic list.

The first matching rule wins, so compound names ('Çoxalma və inkişaf. Sinir sistemi') go to their first subject.
"""
import re

B, Z, H, G = "Botanika", "Zoologiya", "İnsan anatomiyası və fiziologiyası", "Ümumi biologiya"

RULES = [
    (r"heyvanlar aləminin inkişafı", (Z, "Heyvanlar aləminin inkişafı")),
    (r"bitki tam|bitki aləminin inkişafı", (B, "Bitki aləminin inkişafı")),
    (r"bakteriya|göbələk|şibyə", (B, "Bakteriyalar və göbələklər")),
    (r"yosun|mamır|qıjı|çılpaqtoxum", (B, "Yosunlar, mamırlar, qıjılar, çılpaqtoxumlular")),
    (r"vegetativ", (B, "Vegetativ orqanlar")),
    (r"generativ", (B, "Generativ orqanlar")),
    (r"örtülütoxum", (B, "Örtülütoxumlular şöbəsi")),
    (r"ibtidai|bağırsaqboşluq", (Z, "İbtidailər və bağırsaqboşluqlular")),
    (r"qurd|molyusk", (Z, "Qurdlar və molyusklar")),
    (r"buğumayaqlı", (Z, "Buğumayaqlılar")),
    (r"xordalı|balıq|suda-quruda|sürünən", (Z, "Xordalılar, balıqlar, suda-quruda yaşayanlar, sürünənlər")),
    (r"quşlar|məməli", (Z, "Quşlar və məməlilər")),
    (r"dayaq", (H, "Dayaq-hərəkət sistemi")),
    (r"həzm", (H, "Həzm və maddələr mübadiləsi")),
    (r"(?<![a-zəıöüçşğ])qan(?![a-zəıöüçşğ])|tənəffüs", (H, "Qan, qan dövranı, tənəffüs")),
    (r"ifrazat", (H, "İfrazat sistemi və dəri")),
    (r"sekresiya", (H, "Daxili sekresiya vəziləri")),
    (r"sinir|analizator", (H, "Sinir sistemi və analizatorlar")),
    (r"sitologiya", (G, "Sitologiya")),
    (r"hüceyrənin biokimyası", (G, "Hüceyrənin biokimyası")),
    (r"genetika", (G, "Genetika")),
    (r"seleksiya", (G, "Seleksiya")),
    (r"çoxalma|ontogenez", (G, "Çoxalma və inkişaf")),
    (r"ekologiya|biosfer", (G, "Ekologiya və biosfer")),
    (r"təkamül|yer üzərində", (G, "Təkamül və həyatın əmələ gəlməsi")),
    (r"mövzulararası|fənlərarası", (G, "Mövzulararası əlaqə")),
]


def normalize(name):
    return re.sub(r"\s+", " ", (name or "").strip().rstrip(".").strip()).replace("İ", "i").lower()


def map_topic(old):
    """DIM topic name -> (section, topic, note). note is empty when the mapping is unambiguous."""
    key = normalize(old)
    if not key:
        return "", "", "DİM-də mövzu yoxdur"
    for pattern, (section, topic) in RULES:
        if re.search(pattern, key):
            return section, topic, ""
    return "", "", "Qayda tapılmadı: əl ilə təyin edin"
