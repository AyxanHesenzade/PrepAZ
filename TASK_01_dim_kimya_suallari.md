# Tapşırıq 01: DİM PDF-lərindən kimya suallarının çıxarılması

> Bu tapşırıqda kodu sən yazırsan. Əvvəlcə `CLAUDE.md`-ni oxu.
> Qeyri-müəyyən bir şey çıxarsa, təxmin etmə: dayan və sahibdən soruş.

## Məqsəd

DİM-in saytında dərc etdiyi 4 PDF-dən **yalnız kimya** suallarını çıxarmaq və bizim **Excel sual şablonu** formatına salmaq. Fayl müəllim yoxlamasından keçəndən sonra import skripti ilə bazaya yüklənəcək.

**Hüquqi əsas:** DİM-in yazılı icazəsi var, sahibdə saxlanılır. Hər sualda mənbə mütləq göstərilməlidir.

## Mənbə faylları

| № | İmtahan | Link |
|---|---|---|
| 1 | IV qrup, 12 iyul 2026 | https://dim.gov.az/CkImage/4_cu_qrup_1783846566.pdf |
| 2 | IV qrup, 7 iyun 2026 | https://dim.gov.az/CkImage/4_cu_qrup_1780824862.pdf |
| 3 | IV qrup, 13 iyul 2025 | https://dim.gov.az/CkImage/4_cu_qrup_1752476942.pdf |
| 4 | I qrup, 13 iyul 2025 | https://dim.gov.az/CkImage/1_ci_qrup_1752476895.pdf |

PDF-lər mətnlidir, mətni seçmək mümkündür.

## PDF-lər haqqında bildiklərimiz

Yalnız 1-ci fayl ilkin olaraq yoxlanılıb. Qalan 3 faylın quruluşunu özün yoxla.

- Faylda bir neçə fənn var. IV qrupda biologiya, kimya və fizika ardıcıl gəlir. 1-ci faylda kimya təxminən **31–60-cı tapşırıqlardır**.
- Hər sualda bunlar var: sual mətni, **A–E variantları**, **mövzu** (məs. "Alkenlər", "Hidroliz"), **sinif**, **izah** və **düzgün cavab**.
- Sualın A, B, C, D variantlarındakı nömrələri göstərilə bilər. Bizə hər sual **bir dəfə** lazımdır.
- **Formul problemləri:**
  - aşağı indekslər adi rəqəm kimi çıxır: `H2SO4`;
  - ion yükləri qarışır: `Ag++ NO3-`;
  - reaksiya oxları və şərtləri itə bilər;
  - ikiqat və üçqat rabitələr itir: etilen `CH2 CH2` kimi çıxır;
  - struktur formullar şəkildir, mətndə görünmür;
  - kəsrlər bəzən parçalanır.
- 4-cü faylda (I qrup) kimyanın olub-olmadığı yoxlanmayıb. **Kimya yoxdursa, həmin faylı keç** və hesabatda qeyd et.

## İş addımları

1. **Yüklə.** PDF-ləri `tools/dim/raw/` qovluğuna yüklə. Artıq yüklənmiş faylı təkrar yükləmə. Sorğular arasında fasilə qoy.
2. **Quruluşu öyrən.** Hər faylda kimya bölməsinin harada başlayıb bitdiyini müəyyən et. Ayrı-ayrı tapşırıq nömrələrinə güvənmə, bölmə başlığına görə ayır.
3. **Hər kimya sualından** bunları çıxar: sual mətni, A–E variantları, düzgün cavab (hərflə), mövzu, sinif, izah. Açıq tipli suallar varsa, onları da götür. Tipini düzgün qoy: `aciq_eded` (cavab ədəddir) və ya `yazili`.
4. **Formulları çevir.** Bütün kimyəvi formullar `$\mathrm{...}$` formatında yazılmalıdır, məsələn: `$\mathrm{H_2SO_4}$`, `$\mathrm{Fe^{3+}}$`, `$\mathrm{2H_2 + O_2 \rightarrow 2H_2O}$`. Bu çevirmə sual mətninə, variantlara və izaha aiddir. Riyazi ifadələr də LaTeX-də olmalıdır. `\ce{}` **istifadə etmə**, tətbiq onu göstərə bilmir.
5. **Şəkilləri ayır.** Sualda və ya variantlarda şəkil (struktur formul, sxem, qrafik) varsa, onu PNG kimi `tools/dim/images/` qovluğuna kəs, adı sualın kodu ilə eyni olsun (məs. `KIM-0042.png`). Şablonun `şəkil` sütununa fayl adını yaz.
6. **Etibarsız yerləri işarələ.** Avtomatik çevirmədən əmin olmadığın hər sualı işarələ: yük, ox, rabitə, şəkil və ya parçalanmış kəsr olan yerlər. Kiçik səbəbi də yaz.
7. **Dublikatları birləşdir.** Eyni sual bir neçə faylda varsa, bir dəfə saxla, mənbə sütununda hamısını göstər.

## Çıxış

**Fayl:** `tools/dim/out/kimya_dim_yoxlama.xlsx`, formatı `CLAUDE.md`-dəki şablonun formatıdır (bölmə 8). Sütunlar necə doldurulur:

| Sütun | Necə doldurulur |
|---|---|
| kod | `KIM-0001`-dən başlayaraq ardıcıl |
| fənn | `Kimya` |
| mövzu | PDF-dəki mövzu adı **olduğu kimi**. Ümumiləşdirmə və ya adını dəyişmə |
| tip | `qapali` / `aciq_eded` / `yazili` |
| sual mətni, A–E | LaTeX-ə çevrilmiş mətn |
| düzgün cavab | qapalı sualda hərf (A–E) |
| çətinlik | PDF-də yoxdursa, **boş qoy** (müəllim dolduracaq) |
| həll | PDF-dəki izah |
| şəkil | şəkil faylının adı (varsa) |
| səviyyə | `qebul` |
| qruplar | `4` və ya `1` (fayla görə) |
| il | 2025 və ya 2026 |
| mənbə | `DİM` |
| mənbədə yeri | məs. `2026-07-12 qəbul, IV qrup, A variantı №34` |
| aktiv | `xeyr`. Müəllim təsdiqləyəndən sonra `bəli` olacaq |

Şablonun sonuna əlavə olaraq iki sütun qoy:
- `yoxlanmalı`: `bəli` və ya boş;
- `qeyd`: nəyin yoxlanmalı olduğu (məs. "ion yükü", "struktur formul şəkildir").

**Müəllim üçün:** işarələnmiş sətirlər sarı rənglə vurğulansın. Ayrıca bir vərəqdə bu xülasə olsun: fayllar üzrə sual sayı, neçəsi işarələnib, mövzular siyahısı və hər mövzuda neçə sual var.

## Etməməli olduqların

- Bazaya **heç nə yükləmə**. Yükləmə yalnız müəllim yoxlamasından sonra, sahibin icazəsi ilə olacaq.
- Sual mətnini, cavabı və ya izahı "yaxşılaşdırma". Yalnız formatı (LaTeX) dəyiş, məzmun DİM-in olduğu kimi qalmalıdır.
- Əmin olmadığın cavabı təxmin etmə. Boş qoy və `yoxlanmalı` kimi işarələ.

## Qəbul meyarları

- 4 faylın hamısı işlənib, kimyası olmayan fayl hesabatda qeyd olunub.
- Hər kimya sualı Excel faylında bir dəfə var, hər birində mənbə və düzgün cavab var (və ya `yoxlanmalı` işarəsi).
- Bütün formullar `$\mathrm{...}$` formatındadır, `\ce{}` yoxdur.
- Excel faylı import skriptinin yoxlamasından (`--check` rejimi) xətasız keçir. Boş çətinlik xanaları üçün xəta çıxırsa, bunu hesabatda göstər, çətinliyi uydurma.
- Kodda dəyişən adları və commit mesajları ingilis dilindədir.

## Hesabat (sahibə, Azərbaycan dilində, qısa)

1. Hər fayldan neçə kimya sualı çıxdı, ümumi neçə sual alındı.
2. Neçə sual `yoxlanmalı` işarəsi aldı və əsas səbəblər nələrdir.
3. Mövzular siyahısı və hər mövzuda sual sayı.
4. 3 nümunə sual: PDF-dəki orijinal görünüş ilə bizim çevrilmiş versiyanın yanaşı müqayisəsi.
5. Problemlər və təkliflər.
