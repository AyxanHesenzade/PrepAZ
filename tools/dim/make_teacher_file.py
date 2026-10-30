"""Creates out/muellim_1_dest.xlsx: the review file for the chemistry teacher.

Rows: not flagged (yoxlanmalı empty), tip qapali/aciq_eded, not yet approved. Formulas are shown in readable
Unicode (H₂SO₄, Fe³⁺, →) instead of raw LaTeX. The main Excel stays the single source of truth;
merge_review.py copies çətinlik/aktiv/qeyd back by code.

Usage: python make_teacher_file.py [--batch 2] [--force]
  batch 1 (default): the 32 clean questions.   batch 2: visual-only problems, with the original images embedded.
       python make_teacher_file.py --subject biologiya|kimya [--from-code 121] [--force]
  every closed/numeric question that is not yet approved, with the original images embedded -> out/muellim_biologiya.xlsx
"""
import re
import sys
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.drawing.image import Image as XlImage
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.worksheet.datavalidation import DataValidation

from subjects import SUBJECTS

OUT = Path(__file__).parent / "out"
SECTION_ORDER = {"Ümumi kimya": 0, "Qeyri-üzvi kimya": 1, "Üzvi kimya": 2}

SUB = dict(zip("0123456789+-()naeoirumkplstxhj", "₀₁₂₃₄₅₆₇₈₉₊₋₍₎ₙₐₑₒᵢᵣᵤₘₖₚₗₛₜₓₕⱼ"))
SUP = dict(zip("0123456789+-ni", "⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻ⁿⁱ"))
COMMANDS = {
    r"\rightarrow": "→", r"\leftarrow": "←", r"\uparrow": "↑", r"\downarrow": "↓", r"\Leftrightarrow": "⇔",
    r"\Rightarrow": "⇒", r"\rightleftharpoons": "⇌", r"\cdot": "⋅", r"\times": "×", r"\%": "%", r"^\circ": "°", r"\equiv": "≡",
    r"\alpha": "α", r"\beta": "β", r"\gamma": "γ", r"\delta": "δ", r"\varepsilon": "ε", r"\eta": "η",
    r"\theta": "θ", r"\lambda": "λ", r"\mu": "μ", r"\nu": "ν", r"\pi": "π", r"\rho": "ρ", r"\sigma": "σ",
    r"\tau": "τ", r"\varphi": "φ", r"\chi": "χ", r"\psi": "ψ", r"\omega": "ω", r"\Delta": "Δ", r"\Sigma": "Σ",
    r"\Omega": "Ω", r"\Pi": "Π", r"\Phi": "Φ", r"\upsilon": "υ",
}
MATH = re.compile(r"\$\\mathrm\{(.*?)\}\$")


def _script(table, prefix):
    def repl(m):
        body = m.group(1)
        if all(ch in table for ch in body):
            return "".join(table[ch] for ch in body)
        return f"{prefix}({body})"

    return repl


def readable(text):
    """LaTeX-ish cell text -> plain text a teacher can read."""
    def convert(m):
        s = m.group(1)
        for cmd in sorted(COMMANDS, key=len, reverse=True):
            s = s.replace(cmd + " ", COMMANDS[cmd]).replace(cmd, COMMANDS[cmd])
        s = re.sub(r"_\{([^}]*)\}", _script(SUB, "_"), s)
        s = re.sub(r"\^\{([^}]*)\}", _script(SUP, "^"), s)
        return s

    return MATH.sub(convert, text or "")


INSTRUCTION = (
    "Müəllim üçün qısa təlimat. Hər sualı sonuncu sütundakı DİM mənbəsi (imtahan tarixi, variant və nömrə) ilə "
    "orijinal PDF-də tutuşdurun: sual mətni, variantlar, düzgün cavab və izah düzgün olmalıdır. "
    "'Çətinlik' sütununa 1 (çox asan) ilə 5 (çox çətin) arasında rəqəm yazın. "
    "Sual tam düzgündürsə 'aktiv' sütununda 'bəli' seçin; səhv və ya şübhə varsa 'xeyr' saxlayın və "
    "nəyin düzgün olmadığını 'müəllim qeydi' sütununa yazın. Düsturlar buradan oxunaqlı formada göstərilir "
    "(məsələn, H₂SO₄); bu faylda mətni redaktə etməyin, düzəlişləri qeydə yazın."
)
HEADERS = [
    "kod", "bölmə", "mövzu", "sual", "A", "B", "C", "D", "E", "düzgün cavab", "həll (izah)",
    "çətinlik (1–5)", "aktiv", "müəllim qeydi", "DİM mənbəsi",
]
WIDTHS = (10, 16, 32, 60, 22, 22, 22, 22, 22, 12, 50, 10, 8, 40, 34)


def build_batch1():
    ws = load_workbook(OUT / "kimya_dim_yoxlama.xlsx")["suallar"]
    header = [c.value for c in ws[1]]
    rows = [dict(zip(header, ("" if v is None else str(v) for v in r))) for r in ws.iter_rows(min_row=2, values_only=True)]
    chosen = [
        r for r in rows
        if r["yoxlanmalı"] != "bəli" and r["tip"] in ("qapali", "aciq_eded") and r["aktiv"] != "bəli"
    ]
    chosen.sort(key=lambda r: (SECTION_ORDER.get(r["bölmə"], 9), r["mövzu"], r["kod"]))

    wb = Workbook()
    sheet = wb.active
    sheet.title = "Müəllim 1-ci dəst"
    sheet.merge_cells(start_row=1, start_column=1, end_row=1, end_column=len(HEADERS))
    sheet["A1"] = INSTRUCTION
    sheet["A1"].alignment = Alignment(wrap_text=True, vertical="top")
    sheet["A1"].fill = PatternFill("solid", fgColor="DDEBF7")
    sheet.row_dimensions[1].height = 95
    sheet.append([])
    sheet.append(HEADERS)
    for c in sheet[3]:
        c.font = Font(bold=True)
    for r in chosen:
        sheet.append([
            r["kod"], r["bölmə"], r["mövzu"], readable(r["sual mətni"]),
            readable(r["A"]), readable(r["B"]), readable(r["C"]), readable(r["D"]), readable(r["E"]),
            readable(r["düzgün cavab"]), readable(r["həll"]), "", "xeyr", "", r["mənbədə yeri"],
        ])
    last = sheet.max_row
    difficulty = DataValidation(type="whole", operator="between", formula1="1", formula2="5", allow_blank=True,
                                showErrorMessage=True, error="1-dən 5-ə qədər tam ədəd yazın.")
    approve = DataValidation(type="list", formula1='"bəli,xeyr"', allow_blank=False)
    sheet.add_data_validation(difficulty)
    sheet.add_data_validation(approve)
    difficulty.add(f"L4:L{last}")
    approve.add(f"M4:M{last}")
    for col, w in zip("ABCDEFGHIJKLMNO", WIDTHS):
        sheet.column_dimensions[col].width = w
    for row in sheet.iter_rows(min_row=4):
        for c in row:
            c.alignment = Alignment(wrap_text=True, vertical="top")
    sheet.freeze_panes = "D4"
    wb.save(OUT / "muellim_1_dest.xlsx")
    print(f"teacher file: {len(chosen)} questions -> out/muellim_1_dest.xlsx")


BATCH2_INSTRUCTION = (
    "Müəllim üçün qısa təlimat. Bu suallarda cədvəl, çertyoj və ya reaksiya şərti var, ona görə avtomatik çıxarılan "
    "mətn pozula bilər. Qərarı orijinal şəkillərə (sağdakı iki sütun) baxıb verin. Sual, variantlar və cavab "
    "şəkillə uyğundursa, 'çətinlik' (1-5) yazın və 'aktiv' sütununda 'bəli' seçin. Mətn pozulubsa, amma şəkil "
    "düzgündürsə, 'xeyr' saxlayın və qeydə 'mətn pozulub, şəkil düzgündür' yazın; səhv varsa nəyin səhv olduğunu yazın."
)
HEADERS2 = [
    "kod", "bölmə", "mövzu", "sual (mətn, pozula bilər)", "A", "B", "C", "D", "E", "düzgün cavab",
    "çətinlik (1–5)", "aktiv", "müəllim qeydi", "DİM mənbəsi", "avtomatik qeyd",
    "sual şəkli (orijinal)", "izah şəkli (orijinal)",
]
WIDTHS2 = (10, 16, 28, 44, 18, 18, 18, 18, 18, 10, 10, 8, 32, 30, 28, 62, 62)
VISUAL_ONLY = ("cədvəl", "sxem/qrafik", "şəkil/struktur formul", "oxun şərti", "izahda: cədvəl", "izahda: sxem/qrafik",
               "izahda: şəkil/struktur formul")
IMAGES = Path(__file__).parent / "images"
IMAGE_WIDTH_PX = 440


def visual_only(reasons):
    parts = [p.strip() for p in (reasons or "").split(";") if p.strip()]
    return bool(parts) and all(any(p.startswith(v) for v in VISUAL_ONLY) for p in parts)


def embed(sheet, row, column, filename):
    """Puts the image into a cell and returns its height in points (for the row height)."""
    if not filename or not (IMAGES / filename).exists():
        return 0
    img = XlImage(IMAGES / filename)
    scale = IMAGE_WIDTH_PX / img.width
    img.width, img.height = IMAGE_WIDTH_PX, int(img.height * scale)
    sheet.add_image(img, f"{column}{row}")
    return img.height * 0.75


GENERAL_INSTRUCTION = (
    "Müəllim üçün qısa təlimat. Hər sualı DİM mənbəsi (imtahan tarixi, variant və nömrə) ilə tutuşdurun. "
    "Mətn avtomatik çıxarılıb, ona görə sağdakı orijinal şəkillər (varsa) ilə də yoxlayın: sual, variantlar və "
    "düzgün cavab düzgün olmalıdır. Hər şey düzgündürsə, 'çətinlik' (1 = çox asan, 5 = çox çətin) yazın və 'aktiv' "
    "sütununda 'bəli' seçin. Səhv və ya şübhə varsa 'xeyr' saxlayın və nəyin səhv olduğunu 'müəllim qeydi' sütununa yazın. "
    "'Avtomatik qeyd' sütunu proqramın nəyi şübhəli saydığını göstərir (məsələn, 'oxşar sual: BIO-0005' varsa, "
    "iki sualdan birini 'xeyr' edin ki, təkrar olmasın)."
)


def build_batch2(force, subject="kimya", from_code=None):
    """[from_code]: only questions numbered from it (e.g. 121 = the ones added by append_new.py), any subject."""
    cfg = SUBJECTS[subject]
    general = subject != "kimya" or from_code is not None
    name = "muellim_biologiya.xlsx" if subject == "biologiya" else f"muellim_{subject}_yeni.xlsx"
    target = OUT / (name if general else "muellim_2_dest.xlsx")
    if target.exists() and not force:
        sys.exit(f"{target.name} already exists (the teacher may have filled it). Use --force to overwrite.")
    ws = load_workbook(cfg["excel"])["suallar"]
    header = [c.value for c in ws[1]]
    rows = [dict(zip(header, ("" if v is None else str(v) for v in r))) for r in ws.iter_rows(min_row=2, values_only=True)]
    chosen = [
        r for r in rows
        if r["aktiv"] != "bəli" and r["tip"] in ("qapali", "aciq_eded")
        and (from_code is None or int(r["kod"].split("-")[1]) >= from_code)
        and (r["düzgün cavab"] != "" if general else (r["yoxlanmalı"] == "bəli" and visual_only(r["qeyd"])))
    ]
    order = {name: n for n, name in enumerate(cfg["sections"])} if general else SECTION_ORDER
    chosen.sort(key=lambda r: (order.get(r["bölmə"], 9), r["mövzu"], r["kod"]))

    wb = Workbook()
    sheet = wb.active
    sheet.title = f"Müəllim {cfg['name']}" if general else "Müəllim 2-ci dəst"
    sheet.merge_cells(start_row=1, start_column=1, end_row=1, end_column=len(HEADERS2))
    sheet["A1"] = GENERAL_INSTRUCTION if general else BATCH2_INSTRUCTION
    sheet["A1"].alignment = Alignment(wrap_text=True, vertical="top")
    sheet["A1"].fill = PatternFill("solid", fgColor="DDEBF7")
    sheet.row_dimensions[1].height = 80
    sheet.append([])
    sheet.append(HEADERS2)
    for c in sheet[3]:
        c.font = Font(bold=True)
    for n, r in enumerate(chosen, start=4):
        sheet.append([
            r["kod"], r["bölmə"], r["mövzu"], readable(r["sual mətni"]),
            readable(r["A"]), readable(r["B"]), readable(r["C"]), readable(r["D"]), readable(r["E"]),
            readable(r["düzgün cavab"]), "", "xeyr", "", r["mənbədə yeri"], r["qeyd"], "", "",
        ])
        heights = [embed(sheet, n, "P", r["şəkil"]), embed(sheet, n, "Q", r["izah şəkli"]), 60]
        sheet.row_dimensions[n].height = min(max(heights) + 6, 400)
    last = sheet.max_row
    difficulty = DataValidation(type="whole", operator="between", formula1="1", formula2="5", allow_blank=True,
                                showErrorMessage=True, error="1-dən 5-ə qədər tam ədəd yazın.")
    approve = DataValidation(type="list", formula1='"bəli,xeyr"', allow_blank=False)
    sheet.add_data_validation(difficulty)
    sheet.add_data_validation(approve)
    difficulty.add(f"K4:K{last}")
    approve.add(f"L4:L{last}")
    for col, w in zip("ABCDEFGHIJKLMNOPQ", WIDTHS2):
        sheet.column_dimensions[col].width = w
    for row in sheet.iter_rows(min_row=4):
        for c in row:
            c.alignment = Alignment(wrap_text=True, vertical="top")
    sheet.freeze_panes = "D4"
    wb.save(target)
    print(f"teacher file ({subject}): {len(chosen)} questions -> out/{target.name}")


def main(argv):
    if "--subject" in argv:
        from_code = int(argv[argv.index("--from-code") + 1]) if "--from-code" in argv else None
        build_batch2("--force" in argv, argv[argv.index("--subject") + 1], from_code)
    elif "--batch" in argv and argv[argv.index("--batch") + 1] == "2":
        build_batch2("--force" in argv)
    else:
        target = OUT / "muellim_1_dest.xlsx"
        if target.exists() and "--force" not in argv:
            sys.exit(f"{target.name} already exists (the teacher may have filled it). Use --force to overwrite.")
        build_batch1()


if __name__ == "__main__":
    main(sys.argv[1:])
