"""Creates out/muellim_1_dest.xlsx: the review file for the chemistry teacher.

Rows: not flagged (yoxlanmalı empty), tip qapali/aciq_eded, not yet approved. Formulas are shown in readable
Unicode (H₂SO₄, Fe³⁺, →) instead of raw LaTeX. The main Excel stays the single source of truth;
merge_review.py copies çətinlik/aktiv/qeyd back by code.

Usage: python make_teacher_file.py
"""
import re
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.worksheet.datavalidation import DataValidation

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


def main():
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


if __name__ == "__main__":
    main()
