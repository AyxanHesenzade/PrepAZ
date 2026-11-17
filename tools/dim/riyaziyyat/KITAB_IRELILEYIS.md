# Riyaziyyat test toplusu I: harada dayanmışıq

Bu faylı yeni sessiyada ƏVVƏL oxu. Hər alt mövzu bitəndə yenilə.
Son yenilənmə: 2026-11-17 (axşam: fəsil 6 yükləndi)

## Qısa vəziyyət
- **Mənbə:** DİM "Riyaziyyat test toplusu I hissə" (2025), skan. Fayl: `tools/dim/riyaziyyat/riyaziyyat_I_2025.pdf` (235 səhifə).
- **Yüklənib (test Supabase):** Fəsil 1 "Natural ədədlər" (bölmə 1-4, 142 sual) və fəsil 2 "Adi və onluq kəsrlər" (bölmə 5-8, 114 sual), fəsil 3 "Faiz. Nisbət. Tənasüb" (bölmə 9-12, 153 sual) fəsil 4 "Həqiqi ədədlər" (bölmə 13-17, 74 sual) və fəsil 5 "Tam cəbri ifadələr" (bölmə 18-22, 82 sual) və fəsil 6 "Çoxhədlinin vuruqlara ayrılması" (bölmə 23-25, 61 sual) = **626 sual**. Şəkillər `out/images_kitab/`-dadır, `out/upload_kitab/` boşdur.
- **Fəsil 2 "Adi və onluq kəsrlər" YÜKLƏNDİ** (bölmə 5-8, 114 sual).
- **Fəsil 3 "Faiz. Nisbət. Tənasüb" YÜKLƏNDİ** (bölmə 9-12, 153 sual).
- **Fəsil 4 "Həqiqi ədədlər" YÜKLƏNDİ** (bölmə 13-17, 74 sual).
- **Fəsil 5 "Tam cəbri ifadələr" YÜKLƏNDİ** (bölmə 18-22, 82 sual).
- **Fəsil 6 "Çoxhədlinin vuruqlara ayrılması" YÜKLƏNDİ** (bölmə 23-25, 61 sual, 2026-11-17). Qeyd: `RT1-S24-Q010`-un E variantı skanda su nişanı ilə örtülüb.
- **NÖVBƏTİ: fəsil 7 "Rasional kəsrlər"** (pdf 44 sağ səhifədən/45-dən, çap 47; açar pdf 216 ortası: alt mövzu "Kəsrlərin ixtisarı. DMQ çoxluğu" və s.; bölmə nömrəsi 26-dan). Əvvəl bu faylın "gap_fill.py" bölməsini oxu.
- Riyaziyyat fənni aktivdir (`subjects.is_active = true`). Əvvəlki 2 nümunə sual (RIY-0001, RIY-0003) silinib.

## Səhifə qaydası
- **Çap nömrəsi = pdf səhifəsi + 2.** Sual səhifələri pdf 2-dən başlayır (pdf 1 üz qabığı).
- Cavab açarı pdf 211-dən (çap 213) başlayır: hər fəsil üçün mövzu-mövzu cədvəllər, nömrələmə HƏR ALT MÖVZUDA 1-dən başlayır.
- İçindəkilər pdf 233-235 (çap 235-237). Situasiya cavabları pdf 229-230.
- Səhifələrin ölçüsü 800x1119 px (şəkil), koordinatlar bu ölçüdədir.

## Kod, ad və bazada quruluş
- Kod: **`RT<kitab>-S<bölmə>-Q<nömrə>`** (məs. `RT1-S02-Q017`). Kimyanın `KT`-si ilə QARIŞMASIN: `questions.code` unikaldır. Əmrlərdə həmişə `--prefix RT`.
- Fəsil = bazada bölmə (`topics`, parent): məs. "Natural ədədlər". Kitabın alt mövzusu = mövzu (`--topic`), `--topic-order 10/20/30...` kitab ardıcıllığı üçün.
- Bölmə nömrəsi (`--section`) = alt mövzunun ardıcıl nömrəsi (1, 2, 3, ... bütün fəsillər boyu davam edir; fəsil 2-nin ilk alt mövzusu 5 olacaq).
- Mənbə: `--source-ref "Riyaziyyat test toplusu I (2025), bölmə N" --year 2025`.

## Alt mövzu cədvəli
| Bölmə | Fəsil / alt mövzu | PDF səhifə | Suallar | Vəziyyət |
|---|---|---|---|---|
| 1 | Natural ədədlər / Natural ədədlərin onluq say sistemində yazılışı | 2-3 | 1-30 (31-32 yazılı, atlandı) | **YÜKLƏNDİ**: 9 qapalı, 18 ədədi, 3 uyğunlaşdırma |
| 2 | Natural ədədlər / Natural ədədlərin toplanması, çıxılması, vurulması və bölünməsi | 3-4 | 1-17 (18-21 yazılı) | **YÜKLƏNDİ**: 10 qapalı, 6 ədədi, 1 uyğunlaşdırma |
| 3 | Natural ədədlər / Natural ədədlərin bölünmə əlamətləri. Qalıqlı bölmə | 4-5 | 1-32 | **YÜKLƏNDİ**: 15 qapalı, 17 ədədi |
| 4 | Natural ədədlər / Natural ədədlərin sadə vuruqlara ayrılışı. ƏBOB. ƏKOB | 5 (sağ sütun)-8 | 1-63 (64-96 yazılı, atlandı) | **YÜKLƏNDİ**: 22 qapalı, 31 ədədi, 10 uyğunlaşdırma (Q64-96 yazılı, atlandı) |
| 5 | Adi və onluq kəsrlər / Adi və onluq kəsrlərin toplanması, çıxılması, vurulması və bölünməsi | 11-12 | 1-33 | **YÜKLƏNDİ**: 29 qapalı, 4 ədədi |
| 6 | Adi və onluq kəsrlər / Düzgün və düzgün olmayan kəsrlər. Sonsuz dövrü onluq kəsrlər | 12-14 | 1-34 (35-38 yazılı, atlandı) | **YÜKLƏNDİ**: 26 qapalı, 6 ədədi, 2 uyğunlaşdırma |
| 7 | Adi və onluq kəsrlər / Kəsrlərin müqayisəsi | 14-15 | 1-14 | **YÜKLƏNDİ**: 10 qapalı, 2 ədədi, 2 uyğunlaşdırma |
| 8 | Adi və onluq kəsrlər / Ədədin hissəsinin və hissəsinə görə ədədin tapılması | 15-17 | 1-33 (34-35 yazılı, atlandı) | **YÜKLƏNDİ**: 25 qapalı, 8 ədədi |
| 9 | Faiz. Nisbət. Tənasüb / Nisbət. Tənasüb. Tənasübün xassələri. Düz və tərs mütənasiblik | 18-19 | 1-30 (31-40 yazılı, atlandı) | **YÜKLƏNDİ**: 20 qapalı, 10 ədədi |
| 10 | Faiz. Nisbət. Tənasüb / Faiz. Ədədin faizinin tapılması | 20 | 1-20 | **YÜKLƏNDİ**: 8 qapalı, 12 ədədi |
| 11 | Faiz. Nisbət. Tənasüb / Faizinə görə ədədin tapılması. İki ədədin faiz nisbəti | 20-22 | 1-40 (41-45 yazılı, atlandı) | **YÜKLƏNDİ**: 25 qapalı, 14 ədədi, 1 uyğunlaşdırma |
| 12 | Faiz. Nisbət. Tənasüb / Faizə aid məsələlər | 23-26 | 1-63 (64-84 yazılı, atlandı) | **YÜKLƏNDİ**: 16 qapalı, 42 ədədi, 5 uyğunlaşdırma |
| 13 | Həqiqi ədədlər / Rasional ədədlər. Rasional ədədlər üzərində əməllər | 29 | 1-7 (8-9 yazılı) | **YÜKLƏNDİ**: 7 qapalı |
| 14 | Həqiqi ədədlər / İrrasional ədədlər | 29-30 | 1-12 | **YÜKLƏNDİ**: 11 qapalı, 1 ədədi |
| 15 | Həqiqi ədədlər / Ədədin modulu. Modul daxil olan ifadələrin çevrilməsi | 30 | 1-9 (10-11 yazılı) | **YÜKLƏNDİ**: 6 qapalı, 3 ədədi |
| 16 | Həqiqi ədədlər / Ədədi orta. Həqiqi ədədlərin müqayisəsi | 31-32 | 1-30 (Q11 sütunlar arası, birləşdirilib) | **YÜKLƏNDİ**: 23 qapalı, 5 ədədi, 2 uyğunlaşdırma |
| 17 | Həqiqi ədədlər / Ədədin tam və kəsr hissəsi. Ədədin standart şəkli | 33 | 1-16 | **YÜKLƏNDİ**: 11 qapalı, 3 ədədi, 2 uyğunlaşdırma |
| 18 | Tam cəbri ifadələr / Birhədli və onun standart şəkli. Natural üstlü qüvvət | 34 | 1-14 | **YÜKLƏNDİ**: 9 qapalı, 3 ədədi, 2 uyğunlaşdırma |
| 19 | Tam cəbri ifadələr / Çoxhədlilər və onlar üzərində əməllər | 34-36 | 1-32 (33-36 yazılı) | **YÜKLƏNDİ**: 16 qapalı, 16 ədədi |
| 20 | Tam cəbri ifadələr / Müxtəsər vurma düsturları | 36-37 | 1-10 (Q2 sütunlar arası, birləşdirilib) | **YÜKLƏNDİ**: 10 qapalı |
| 21 | Tam cəbri ifadələr / İfadələrin ədədi qiymətlərinin hesablanması | 37 | 1-12 (13-14 yazılı) | **YÜKLƏNDİ**: 10 qapalı, 2 ədədi |
| 22 | Tam cəbri ifadələr / İfadələrin ən kiçik və ən böyük qiymətlərinin tapılması | 38 | 1-14 | **YÜKLƏNDİ**: 4 qapalı, 7 ədədi, 3 uyğunlaşdırma |
| 23 | Çoxhədlinin vuruqlara ayrılması / Müxtəsər vurma düsturlarının köməyi ilə vuruqlara ayırma | 39 | 1-9 (10-11 yazılı) | **YÜKLƏNDİ**: 8 qapalı, 1 ədədi |
| 24 | Çoxhədlinin vuruqlara ayrılması / Müxtəlif üsulların köməyi ilə vuruqlara ayırma | 39-42 | 1-31 (32-41 yazılı) | **YÜKLƏNDİ**: 17 qapalı, 6 ədədi, 8 uyğunlaşdırma |
| 25 | Çoxhədlinin vuruqlara ayrılması / Vuruqlara ayırma üsulu ilə ifadələrin ədədi qiymətinin hesablanması | 43-44 | 1-21 (22-29 yazılı) | **YÜKLƏNDİ**: 12 qapalı, 7 ədədi, 2 uyğunlaşdırma |

## Bölmə 4 (2026-11-17)
- pdf 5 sağ sütun (Q1, y~178)-pdf 8 sağ sütun (Q63, y~450). Q64-96 "Ətraflı yazılı cavab" bölməsidir (pdf 8 sağ sütun, 9, 10): ATLANDI (açarda cavabları var, amma yazılı tapşırıqdır). Yazılı bölmə hər alt mövzunun sonundadır.
- 63 sual: 1-22 qapalı, 23-53 ədədi, 54-63 uyğunlaşdırma (3 sətir). Açar: sahib şəkli verdi (`scan/riyaziyyat_I_bolme4_cavablar.json`).
- Əmr: `--first 5 --last 8 --start 1 --stop 63 --skip-above 5:0:9999 --skip-above 5:1:165`. OCR yalnız Q7-ni tapmadı (əl ilə: `[5,1,695]`). Q6 kəsrin payı nömrədən yuxarıdadır: Q6 `[5,1,612]`. Q63 `--end 460`.
- Qayda: kəsr/formula ilə başlayan sualda nömrə kəsrin ORTASINDADIR, əl ilə kəsəndə üst sərhədi kəsrin payından yuxarı ver.
- Yükləmə: `out/import_rt1_s04.sql` + `out/upload_kitab/` (63 `.webp`).

## Komandalar (`tools/dim/riyaziyyat` qovluğundan)
```
# skan (2 səhifə ~4 dəq, ARXA FONDA: run_in_background)
python -W ignore ../common/scan_segment.py riyaziyyat_I_2025.pdf --first F --last L --start 1 --stop N --skip-above P:COL:Y --out scan/riyaziyyat_I_bolmeK
# köməkçilər (scan_tool kimya qovluğundadır, --tmp = müvəqqəti qovluq)
python ../kimya/scan_tool.py --subject riyaziyyat --prefix RT --tmp <qovluq> grid P:x0:x1:y0:y1 ...     # y-xətkeşli kəsik: ölç
python ../kimya/scan_tool.py --subject riyaziyyat --prefix RT --tmp <qovluq> add scan/riyaziyyat_I_bolmeK '{"3":[4,0,917]}' --end '{"5":1100}'
python -W ignore ../common/scan_segment.py riyaziyyat_I_2025.pdf --first F --last L --out scan/riyaziyyat_I_bolmeK --recrop
python ../kimya/scan_tool.py --subject riyaziyyat --prefix RT --tmp <qovluq> check scan/riyaziyyat_I_bolmeK 1 5 N
# cavablar: scan/riyaziyyat_I_bolmeK_cavablar.json  {"answers": {"1": "C", "10": "11", "28": "c; a; b, e"}}
python ../common/import_scans.py --dir scan/riyaziyyat_I_bolmeK --answers scan/riyaziyyat_I_bolmeK_cavablar.json --book 1 --section K --subject riyaziyyat --prefix RT --section-name "<fəsil>" --topic "<alt mövzu>" --topic-order <10*K> --source-ref "Riyaziyyat test toplusu I (2025), bölmə K" --year 2025
# sahib "ok" deyəndə:
python ../kimya/scan_tool.py --subject riyaziyyat --prefix RT done K
```
- Çıxış: `out/import_rt1_sKK.sql` + `out/upload_kitab/` (yalnız yeni şəkillər). Sahib SQL-i SQL Editor-da işlədir, şəkilləri Storage-ə yükləyir, "ok" deyir, sonra `done`.
- `scan_tool.py` `--tmp` verilməsə `/tmp/prepaz_scan` yazır (Windows-da scratchpad qovluğu ver).
- Qaydalar kimyadakı kimidir (`tools/dim/kimya/SUAL_ELAVE_AZ_TOKEN.md`): OCR-ın tapdığı suallara baxma, yalnız əl ilə əlavə olunanlara və ilk/son suala bir dəfə bax, kiçik qüsuru düzəltmə.

## gap_fill.py: kəsmənin ƏSAS aləti (2026-11-17, fəsil 2-dən)
OCR sual nömrələrinin bir hissəsini tapmır, uydurma nömrə də tapır ("15 km"), kəsrli suallarda üst sərhədi kəsir. Riyaziyyatda OCR (`scan_segment.py`) ARTIQ LAZIM DEYİL (fəsil 3-dən): `scan/riyaziyyat_I_bolmeK/manifest.json` faylına `[]` yaz və yalnız `gap_fill.py` + `--recrop` işlət (dəqiqələr, OCR 4 dəq/2 səhifə idi). Cavab açarını əvvəl oxu, bölmə sərhədlərini səhifə cütlərinə (0.8 miqyas) baxıb tap, sonra:
```
python -W ignore ../common/gap_fill.py riyaziyyat_I_2025.pdf scan/riyaziyyat_I_bolmeK --region PAGE:COL:İLK-SON[:TOP[:BOTTOM]] ... [--drop N]
python -W ignore ../common/scan_segment.py riyaziyyat_I_2025.pdf --first F --last L --out scan/riyaziyyat_I_bolmeK --recrop
```
- Hər səhifə sütunu üçün bir `--region`: orada duran sualların nömrə aralığı (məs. `13:0:7-16` = pdf 13 sol sütunda 7-dən 16-ya). Alət sual başlanğıclarını səhifənin MÜREKKƏBİNDƏN tapır (nömrə sol haşiyədədir, qalan sətirlər içəridən başlayır) və hamısını yenidən yazır (OCR-ın tapdıqlarını da: kəsrin payı artıq kəsilmir). Saydığı sayı verdiyin sayla uyğun gəlməsə, tapdıqlarını çap edib dayanır.
- `TOP` başlıqdan sonra, `BOTTOM` səhifə nömrəsindən ("- 16 -") və ya "Ətraflı yazılı" başlığından əvvəl olmalıdır. Səhifə şəkli ~800x1200-dür (preview şəkilləri 1119 hündürlükdədir: koordinatı `grid`-dən götür, preview-dan yox). Xəta mesajında "found N starts" siyahısı var: artıq başlanğıc səhifənin altlığıdırsa BOTTOM-u azalt, başlıq sətri sayılıbsa TOP-u artır.
- Əyri səhifədə sol haşiyə sürüşür: alət hər sətrin x-ini öz qonşuluğundakı ən sol sətrə görə ölçür, uzun şaquli xətləri (sütun ayırıcısı) silir. Sualın cavab variantları (şəklin altında) haşiyədə durursa, artıq başlanğıc çıxır: `--ignore PAGE:COL:Y`. Sütun sonundan növbəti sütuna keçən sual üçün `--cont-top N:Y` (N = növbəti sütunun ilk sualı, Y = davamın başladığı sətir, başlıq xəttindən aşağı).
- Alət sütunun tepəsində səhifə başlığının altındakı xətti (`header_rule_y`) özü tapır (TOP ≤ 95 olanda). Sütunun ən altındakı son variant 1140-dan aşağı düşə bilər (Q10/Q16 kimi): BOTTOM-u 1150-1165 qoy, amma su nişanı (CamScanner) altda yazılı olduğundan bəzən örtülü qalır. Səhifənin altlığı ("- 21 -") və "Ətraflı yazılı" başlığından sonrakı sual BOTTOM-dan kənarda qalmalıdır, yoxsa artıq başlanğıc sayılır.
- `manifest.orig.json` (OCR varsa) OCR-ın ilkin nəticəsidir; alət onu ilk işdə saxlayır. Yenidən başlamaq üçün onu `manifest.json`-un üstünə kopyala.
- `scan_tool.py ... check N N N` ilə yalnız əvvəl tapılmayanlara və hər bölmənin ilk/son sualına bax.

## Dərslər (bu kitabda)
- **`--recrop` hər `y1`-ə yenə 12 px əlavə edir.** Toxunmadığın suallarda manifestdə `y1`-dən 12 çıx, yoxsa sual növbəti sualın ilk sətrini də götürür. `add` ilə qoyulan `--end` bir dəfə +12 alır.
- Sütunun SONUNCU sualı üçün `y1` boş qalır (0) və recrop xəta verir (`lower < upper`): həmişə `--end` ver.
- `--end` dəyəri sualın real aşağı sərhədindən bir az AŞAĞI olmalıdır (Q17 üçün 310 sətri kəsdi, 322 işlədi). Əvvəl `grid` ilə real y-ni ölç.
- OCR sətir daxilindəki rəqəmi ("3. a ədədini 8-ə...") sual nömrəsi sanıb səhv sütunda tapa bilər (bölmə 3: Q8). Nömrə-sütun uyğunsuzluğunu hesabatda yoxla.
- Sütunun sonundakı sual səhifə nömrəsini və "CamScanner" yazısını da qəbul edir: kiçik qüsur, düzəldilmir.
- Cavab açarında rəqəm sütunlarını böyüdüb oxu (onluq kəsr açarda vergüllədir: JSON-da NÖQTƏ yaz, `0.1`; idxal bazaya `0,1` yazır) (2x), bütün cədvəli bir şəkildə oxuma: fırlanmış yazı kəsilir.

## Fəsillər (içindəkilər, çap səhifəsi; pdf = çap - 2)
Natural ədədlər 4 · Adi və onluq kəsrlər 13 · Faiz. Nisbət. Tənasüb 20 · Həqiqi ədədlər 31 · Tam cəbri ifadələr 36 · Çoxhədlinin vuruqlara ayrılması 41 · Rasional kəsrlər 47 · Kvadrat köklər 55 · Birməxsuslu tənliklər və məsələlər 68 · Tənliklər sistemi 86 · Bərabərsizliklər 97 · Ədədi ardıcıllıqlar 113 · Çoxluqlar 129 · Həndəsəyə aid anlayışlar 135 · Üçbucaqlar 144 · Çoxbucaqlılar 162 · Çevrə və dairə 173 · İsbat məsələləri · Situasiya 197 · 2025 imtahanları (buraxılış, qəbul) 209 · Mövzular üzrə testlərin düzgün cavabları 213.
Səhifə nömrələri içindəkilərdən oxunub, iki-üç fəsil üçün dəqiq deyil: skan etməzdən əvvəl `scan_tool.py strip` ilə yoxla. Fəsildə hər alt mövzunun içindəkilərdəki adı = `--topic`.
- **"Situasiya"** və **2025 imtahanları** (pdf ~207-211, çap 209-) bölmələri ayrıca qərarla (Situasiya yazılı, imtahanlar DİM PDF-ləri ilə üst-üstə düşə bilər: kimyadakı kimi təkrar çəkilməsin).
