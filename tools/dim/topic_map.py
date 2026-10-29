"""Proposes a unified topic list for chemistry and maps every DIM topic name to it.

Reads out/kimya_dim_yoxlama.xlsx (read-only), writes out/movzu_xeritesi.xlsx for the owner to review.
Usage: python topic_map.py
"""
import collections
import re
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill

OUT = Path(__file__).parent / "out"

ORDER = ["Ümumi kimya", "Qeyri-üzvi kimya", "Üzvi kimya"]
G, Q, U = ORDER

# (regex on the lower-cased name, (section, topic)); the first rule whose regex matches wins for a segment.
RULES = [
    (r"qeyri-üzvi.*genetik", (Q, "Qeyri-üzvi birləşmələr arasında genetik əlaqə")),
    (r"(?<!qeyri-)üzvi birləşmələr arasında genetik", (U, "Üzvi birləşmələr arasında genetik əlaqə")),
    (r"kimyanın ilk anlayışları", (G, "Kimyanın əsas anlayışları")),
    (r"maddə miqdarı|avoqadro", (G, "Kimyanın əsas anlayışları")),
    (r"tənliklər üzrə hesablama|formul və tənliklər", (G, "Kimyəvi tənliklər üzrə hesablamalar")),
    (r"atomun quruluşu|dövri", (G, "Atomun quruluşu və dövri sistem")),
    (r"hibridləşmə", (G, "Kimyəvi rabitə və hibridləşmə")),
    (r"təsnifat|istilik effekti", (G, "Reaksiyaların təsnifatı və istilik effekti")),
    (r"sürət|tarazlıq", (G, "Reaksiya sürəti və kimyəvi tarazlıq")),
    (r"məhlul", (G, "Məhlullar")),
    (r"dissosiasiya|ion mübadilə", (G, "Elektrolitik dissosiasiya və ion mübadiləsi")),
    (r"hidroliz", (G, "Hidroliz")),
    (r"elektroliz", (G, "Elektroliz")),
    (r"oksidləşmə", (G, "Oksidləşmə-reduksiya reaksiyaları")),
    (r"oksid, əsas|^duzlar|mühim siniflər", (Q, "Qeyri-üzvi maddələrin sinifləri")),
    (r"(?<![a-zəıöüçşğ])hidrogen|^oksigen", (Q, "Hidrogen, oksigen, su")),
    (r"halogen|xlorid", (Q, "Halogenlər")),
    (r"kükürd|sulfat", (Q, "Kükürd və birləşmələri")),
    (r"azot|ammonyak|nitrat", (Q, "Azot və birləşmələri")),
    (r"fosfor", (Q, "Fosfor və mineral gübrələr")),
    (r"karbon turşu", (U, "Karbon turşuları")),
    (r"silisium|^karbon(?! turşu)", (Q, "Karbon və silisium")),
    (r"metal|yarımqrup|dəmir", (Q, "Metallar")),
    (r"tsikloalkan", (U, "Tsikloalkanlar")),
    (r"alkadien|(?<![a-zəıöüçşğ])alken", (U, "Alkenlər və alkadienlər")),
    (r"(?<![a-zəıöüçşğ])alkin", (U, "Alkinlər")),
    (r"(?<![a-zəıöüçşğ])alkan", (U, "Alkanlar")),
    (r"aromatik|benzol", (U, "Aromatik karbohidrogenlər")),
    (r"^karbohidrogenlər$", (U, "Karbohidrogenlər (ümumi)")),
    (r"spirt", (U, "Spirtlər")),
    (r"aldehid|keton", (U, "Aldehidlər və ketonlar")),
    (r"mürəkkəb efir", (U, "Mürəkkəb efirlər")),
    (r"karbohidrat|fruktoza", (U, "Karbohidratlar")),
    (r"amin turşu|aminturşu", (U, "Aminlər və aminturşular")),
    (r"^amin", (U, "Aminlər və aminturşular")),
    (r"molekullu", (U, "Yüksək molekullu birləşmələr")),
]
AMBIGUOUS = {"genetik əlaqə": "Mövzu adında üzvi/qeyri-üzvi yoxdur. Suallara baxıldı: hər ikisi qeyri-üzvidir."}


def normalize(name):
    return re.sub(r"\s+", " ", name.strip().rstrip(".").strip()).replace("İ", "i").lower()


def match_all(text):
    hits = []
    for pattern, target in RULES:
        m = re.search(pattern, text)
        if m and target not in [h[1] for h in hits]:
            hits.append((m.start(), target))
    return [t for _pos, t in sorted(hits, key=lambda h: h[0])]


def map_topic(old):
    """DIM topic name -> (section, topic, note). note is empty when the mapping is unambiguous."""
    key = normalize(old or "")
    if key in AMBIGUOUS:
        return Q, "Qeyri-üzvi birləşmələr arasında genetik əlaqə", AMBIGUOUS[key]
    hits = match_all(key)
    if not hits:
        return "", "", "DİM-də mövzu yoxdur" if not key else "Qayda tapılmadı: əl ilə təyin edin"
    note = ""
    if len(hits) > 1:
        note = "Qarışıq mövzu: ilk mövzuya yazıldı, " + " + ".join(h[1] for h in hits)
    return hits[0][0], hits[0][1], note


def main():
    ws = load_workbook(OUT / "kimya_dim_yoxlama.xlsx")["suallar"]
    header = [c.value for c in ws[1]]
    topics = [dict(zip(header, r))["mövzu"] or "" for r in ws.iter_rows(min_row=2, values_only=True)]
    old_counts = collections.Counter(topics)

    mapping, new_counts = [], collections.Counter()
    for old, n in sorted(old_counts.items(), key=lambda kv: kv[0].lower()):
        section, topic, note = map_topic(old)
        mapping.append((old, n, section, topic, note))
        new_counts[(section, topic)] += n

    wb = Workbook()
    s1 = wb.active
    s1.title = "yeni siyahı"
    s1.append(["Bölmə", "Mövzu", "Sual sayı"])
    for section in ORDER:
        for (sec, topic), n in sorted(new_counts.items(), key=lambda kv: kv[0][1]):
            if sec == section:
                s1.append([sec, topic, n])
    s2 = wb.create_sheet("köhnə → yeni")
    s2.append(["Köhnə DİM mövzusu", "Sual sayı", "Yeni bölmə", "Yeni mövzu", "Qeyd"])
    yellow = PatternFill("solid", fgColor="FFF2CC")
    for row in mapping:
        s2.append(list(row))
        if row[4]:
            for c in s2[s2.max_row]:
                c.fill = yellow
    for sheet, widths in ((s1, (20, 52, 10)), (s2, (50, 10, 20, 52, 70))):
        for col, w in zip("ABCDE", widths):
            sheet.column_dimensions[col].width = w
        for c in sheet[1]:
            c.font = Font(bold=True)
    wb.save(OUT / "movzu_xeritesi.xlsx")

    print(f"old names: {len(old_counts)}, new topics: {len(new_counts)}")
    for section in ORDER:
        print(f"\n{section}")
        for (sec, topic), n in sorted(new_counts.items(), key=lambda kv: kv[0][1]):
            if sec == section:
                print(f"  {topic} ({n})")
    print("\nNeed owner attention:")
    for old, n, _s, topic, note in mapping:
        if note:
            print(f"  {old or '(boş)'!r} ({n}) -> {topic or '?'} | {note}")


if __name__ == "__main__":
    main()
