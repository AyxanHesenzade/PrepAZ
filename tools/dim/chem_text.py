"""PDF span markup to LaTeX for chemistry text (only mathrm formulas, no ce macro)."""
import re

SUB_O, SUB_C, SUP_O, SUP_C = "", "", "", ""
MARKS = SUB_O + SUB_C + SUP_O + SUP_C

ELEMENTS = set("""H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr
Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu Hf Ta W Re Os
Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu""".split())
SAFE_TWO_LETTER = {"Na", "Mg", "Al", "Ca", "Fe", "Cu", "Zn", "Cl", "Br", "Ag", "Au", "Hg", "Pb", "Sn", "Li", "Ba",
                   "Cr", "Mn", "Ni", "Co", "Si", "Ne", "He", "Ar", "Kr", "Xe", "Rb", "Cs", "Sr", "Ti"}
ROMAN = re.compile(r"[IVX]+")

# Symbol font (PUA U+F0xx) -> unicode
_SYM_LETTERS = dict(zip("abcdefghijklmnopqrstuvwxyz", "αβχδεφγηιϕκλμνοπθρστυϖωξψζ"))
_SYM_UPPER = {"D": "Δ", "F": "Φ", "G": "Γ", "L": "Λ", "P": "Π", "Q": "Θ", "S": "Σ", "W": "Ω", "X": "Ξ", "Y": "Ψ"}
SYMBOL = {ord(k): v for k, v in {**_SYM_LETTERS, **_SYM_UPPER}.items()}
SYMBOL.update({0x2d: "-", 0x2b: "+", 0x3d: "=", 0xd7: "⋅", 0xae: "→", 0xad: "↑", 0xaf: "↓", 0xb0: "°", 0xb1: "±",
               0xb7: "•", 0xa3: "≤", 0xb3: "≥", 0xb9: "≠", 0xbb: "≈", 0x5b: "[", 0x5d: "]", 0x28: "(", 0x29: ")",
               0x2e: ".", 0x2c: ",", 0x20: " ", 0x3a: ":", 0xba: "≡", 0xde: "⇒", 0xdb: "⇔", 0xac: "←"})
for d in range(10):
    SYMBOL[0x30 + d] = str(d)

CONNECTORS = {"+": "+", "→": r"\rightarrow", "=": "=", "⋅": r"\cdot", "↑": r"\uparrow", "↓": r"\downarrow",
              "⇒": r"\Rightarrow", "←": r"\leftarrow", "⇌": r"\rightleftharpoons"}
BONDS = {"=": "=", "≡": r"\equiv", "-": "-", "–": "-", "−": "-"}


# Cyrillic look-alikes that appear inside Latin formulas in the DIM PDFs
CYRILLIC = dict(zip("АВЕКМНОРСТХаеорсху", "ABEKMHOPCTXaeopcxy"))


def map_char(ch, unknown):
    ch = CYRILLIC.get(ch, ch)
    o = ord(ch)
    if 0xF000 <= o <= 0xF0FF:
        m = SYMBOL.get(o - 0xF000)
        if m is None:
            unknown.add(f"U+{o:04X}")
            return "?"
        return m
    if ch in "    ":
        return " "
    if ch == "∙":
        return "⋅"
    return ch


def _group(s, i, close):
    j = s.find(close, i)
    if j < 0:
        return None, len(s)
    return s[i:j], j + 1


def parse_formula(tok, flags):
    """Returns LaTeX body for a formula token, or None if tok is not a formula."""
    out, i, n = [], 0, len(tok)
    groups = interesting = 0
    depth = 0
    prev = ""  # 'el' | 'close' | 'num' | 'op'
    while i < n:
        c = tok[i]
        if c == SUB_O:
            body, i = _group(tok, i + 1, SUB_C)
            if body is None or not re.fullmatch(r"[0-9A-Za-z]+", body):
                return None
            out.append("_{%s}" % body)
            interesting += 1
            prev = "sub"
        elif c == SUP_O:
            body, i = _group(tok, i + 1, SUP_C)
            if body is None:
                return None
            body = body.replace("−", "-")
            if not re.fullmatch(r"\d*[+\-]|\d+", body):
                flags.add("yük")
                return None
            out.append("^{%s}" % body)
            interesting += 1
            prev = "sup"
        elif c.isdigit():
            j = i
            while j < n and tok[j].isdigit():
                j += 1
            num = tok[i:j]
            if prev in ("el", "close"):
                out.append("_{%s}" % num)
                interesting += 1
                prev = "sub"
            elif prev in ("", "op"):
                out.append(num)
                prev = "num"
            else:
                return None
            i = j
        elif c.isupper():
            two = tok[i:i + 2]
            if len(two) == 2 and two[1].islower() and two in ELEMENTS:
                sym, i = two, i + 2
            elif c in ELEMENTS:
                sym, i = c, i + 1
            else:
                return None
            out.append(sym)
            groups += 1
            prev = "el"
        elif c == "(":
            depth += 1
            out.append("(")
            prev = "op"
            i += 1
        elif c == ")":
            depth -= 1
            if depth < 0:
                return None
            out.append(")")
            prev = "close"
            i += 1
        elif c in BONDS and prev in ("el", "close", "sub", "sup") and i + 1 < n and tok[i + 1] != "":
            if c in "=≡":
                flags.add("rabitə")
            out.append(BONDS[c])
            prev = "op"
            i += 1
        elif c in CONNECTORS and c != "=" and prev in ("el", "close", "sub", "sup") and i + 1 < n:
            out.append(CONNECTORS[c])
            prev = "op"
            i += 1
        else:
            return None
    if depth != 0 or prev == "op" or groups == 0:
        return None
    plain = re.sub(f"[{MARKS}]", "", tok)
    if not interesting:
        if ROMAN.fullmatch(plain):
            return None
        if groups == 1:
            if plain not in SAFE_TWO_LETTER:
                return None
        # several element symbols without digits (OH, NaOH, CO) are accepted
    return "".join(out)


_AZ = "a-zəıöüçşğ"
_SUFFIX = re.compile(rf"^(.+?)[-–]([{_AZ}]+)$")
_GLUED = re.compile(rf"^(.*[{SUB_C}{SUP_C}])([{_AZ}]{{2,}})$")
_GREEK = {"α": r"\alpha ", "β": r"\beta ", "γ": r"\gamma ", "δ": r"\delta ", "ε": r"\varepsilon ", "η": r"\eta ",
          "θ": r"\theta ", "λ": r"\lambda ", "μ": r"\mu ", "ν": r"\nu ", "π": r"\pi ", "ρ": r"\rho ",
          "σ": r"\sigma ", "τ": r"\tau ", "φ": r"\varphi ", "χ": r"\chi ", "ψ": r"\psi ", "ω": r"\omega ",
          "Δ": r"\Delta ", "Σ": r"\Sigma ", "Ω": r"\Omega ", "Π": r"\Pi ", "Φ": r"\Phi ", "υ": r"\upsilon "}
_GENERIC = re.compile(rf"[A-Za-z0-9()\[\]+\-−=<>.,/⋅·×%°{''.join(_GREEK)}{MARKS}]+")
_CONN_CHARS = "→⇌↑↓⇔⇒←+–─−-="
_CONN_TEX = {"→": r"\rightarrow", "↑": r"\uparrow", "↓": r"\downarrow", "⇔": r"\Leftrightarrow",
             "⇒": r"\Rightarrow", "←": r"\leftarrow", "⇌": r"\rightleftharpoons", "+": "+", "–": "-", "─": "-", "−": "-", "-": "-", "=": "="}


def generic_math(tok):
    """Variable-like expressions such as v(N2)=3 or m(Fe)=56: wrap as-is, keeping sub/superscripts."""
    tok = re.sub(f"{SUB_O}{SUB_C}|{SUP_O}{SUP_C}", "", tok)
    if not _GENERIC.fullmatch(tok) or not re.search(f"[{MARKS}]", tok):
        return None
    if re.search(r"[a-z]{3,}", re.sub(f"[{MARKS}]", "", tok)):
        return None  # a real word, not a variable
    tok = re.sub(f"{SUB_O}(.*?){SUB_C}", lambda m: "_{" + m.group(1) + "}", tok)
    tok = re.sub(f"{SUP_O}(.*?){SUP_C}", lambda m: "^{" + m.group(1) + "}", tok)
    for src, dst in (("−", "-"), ("⋅", r"\cdot "), ("·", r"\cdot "), ("×", r"\times "), ("%", r"\%"),
                     ("°", r"^\circ ")):
        tok = tok.replace(src, dst)
    for src, dst in _GREEK.items():
        tok = tok.replace(src, dst)
    return tok.strip()


def _core_math(core, flags):
    """core -> (latex, trailing_text) or None. Handles formulas, 'CO2-nin', 'R1və', variables."""
    body = parse_formula(core, flags)
    if body is not None:
        return body, ""
    m = _SUFFIX.match(core)
    if m:
        left = parse_formula(m.group(1), flags)
        if left is not None:
            return left, "-" + m.group(2)
    m = _GLUED.match(core)
    if m:
        left = parse_formula(m.group(1), flags) or generic_math(m.group(1))
        if left is not None:
            return left, " " + m.group(2)
    body = generic_math(core)
    return (body, "") if body is not None else None


def _try_math(t, flags):
    """Token with optional surrounding punctuation -> (latex, lead, trail) or None."""
    r = _core_math(t, flags)
    if r:
        return r[0], "", r[1]
    m = re.match(r"^([«\"“(\[]*)(.*?)([.,;:!?»\"”)\]]*)$", t)
    lead, core, trail = m.groups()
    for lead_, core_, trail_ in ((lead, core, trail), ("", t[: len(t) - len(trail)], trail)):
        r = _core_math(core_, flags) if core_ else None
        if r:
            return r[0], lead_, r[1] + trail_
    if t.endswith(")") and "(" not in t:
        r = _core_math(t[:-1], flags)
        if r:
            return r[0], "", r[1] + ")"
    return None


def _analyze(t, flags):
    """Token -> list of items (kind, latex, lead, trail); kind 'm' math, 'c' connector (lead = original char)."""
    if t in _CONN_TEX:
        return [("c", _CONN_TEX[t], t, "")]
    r = _try_math(t, flags)
    if r:
        return [("m", r[0], r[1], r[2])]
    a, b = 0, len(t)
    while a < b and t[a] in _CONN_CHARS:
        a += 1
    while b > a and t[b - 1] in _CONN_CHARS:
        b -= 1
    if (a, b) != (0, len(t)) and a < b:
        r = _try_math(t[a:b], flags)
        if r:
            return (
                [("c", _CONN_TEX[ch], ch, "") for ch in t[:a]]
                + [("m", r[0], r[1], r[2])]
                + [("c", _CONN_TEX[ch], ch, "") for ch in t[b:]]
            )
    return None


def to_tex(s, flags):
    """s: collapsed text with sub/sup markers and mapped symbols -> LaTeX string."""
    s = re.sub(f"[{SUB_O}{SUP_O}][^{SUB_C}{SUP_C}]*[{SUB_C}{SUP_C}]", lambda m: m.group().replace(" ", ""), s)
    items = []
    for t in s.split(" "):
        if not t:
            continue
        found = _analyze(t, flags)
        if found:
            items += found
        else:
            if re.search(f"[{MARKS}]", t):
                flags.add("formul")
            items.append(("t", re.sub(f"[{MARKS}]", "", t), "", ""))
    out, i = [], 0
    while i < len(items):
        k, v, lead, trail = items[i]
        if k == "t":
            out.append(v)
            i += 1
            continue
        if k == "c":
            out.append(lead)  # connector that is not inside a formula stays a plain character
            i += 1
            continue
        parts, j = [v], i
        while not trail and j + 2 < len(items) and items[j + 1][0] == "c" and items[j + 2][0] == "m" \
                and not items[j + 2][2]:
            parts += [items[j + 1][1], items[j + 2][1]]
            trail = items[j + 2][3]
            j += 2
        out.append(lead + r"$\mathrm{" + " ".join(parts) + "}$" + trail)
        i = j + 1
    return " ".join(out)
