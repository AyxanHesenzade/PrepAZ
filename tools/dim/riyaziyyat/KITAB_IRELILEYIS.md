# Riyaziyyat test toplusu I: harada dayanmışıq

Bu faylı yeni sessiyada ƏVVƏL oxu. Hər alt mövzu bitəndə yenilə.
Son yenilənmə: 2026-11-17

## Qısa vəziyyət
- **Mənbə:** DİM "Riyaziyyat test toplusu I hissə" (2025), skan. Fayl: `tools/dim/riyaziyyat/riyaziyyat_I_2025.pdf` (235 səhifə).
- **Yüklənib (test Supabase):** Fəsil "Natural ədədlər", alt mövzular 1, 2, 3 (**79 sual**, 2026-11-17). Şəkillər `out/images_kitab/`-dadır, `out/upload_kitab/` boşdur.
- **NÖVBƏTİ: bölmə 4** (Natural ədədlərin sadə vuruqlara ayrılışı. ƏBOB. ƏKOB), aşağıda hazır məlumat var. Sonra fəsil 2 "Adi və onluq kəsrlər".
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
| 4 | Natural ədədlər / Natural ədədlərin sadə vuruqlara ayrılışı. ƏBOB. ƏKOB | 5 (sağ sütun)-~10 | 1-96 (yazılı tapşırıqlar atlanır) | **GÖZLƏYİR** |

## Bölmə 4 üçün hazır məlumat (açar pdf 211 aşağı hissə, oxunub)
- Başlıq pdf 5 sağ sütunun yuxarısındadır ("Natural ədədlərin sadə vuruqlara ayrılışı. Ən böyük ortaq bölən (ƏBOB). Ən kiçik ortaq bölünən (ƏKOB)"), Q1 başlıqdan dərhal sonra. Skan etməzdən əvvəl `scan_tool.py grid` ilə Q1-in y-sini ölç, `--skip-above 5:1:Y` ver.
- Bölmə harada bitir (nömrə 96, "Ətraflı yazılı" başlıqları araya girir) HƏLƏ yoxlanmayıb: `scan_tool.py strip` ilə pdf 8-11-ə bax. "Ətraflı yazılı cavab" tapşırıqları (pdf 7-8-də sağ sütunda, pdf 10-da) kəsilmir, ardıcıl nömrələr onlardan keçir (nömrələr davam edir, yoxsa yenidən başlayır: yoxla).
- Açar 1-30 (1-22 qapalı, 23-30 ədədi): 1 A, 2 D, 3 C, 4 A, 5 C, 6 A, 7 A, 8 E, 9 A, 10 C, 11 E, 12 B, 13 B, 14 D, 15 C, 16 A, 17 B, 18 E, 19 B, 20 A, 21 A, 22 E, 23 40, 24 65, 25 35, 26 21, 27 20, 28 30, 29 8, 30 42.
- 31-53 ədədi: 31 `25`, 32 `9`, 33 `3`, 34 `3`, 35 `20`, 36 `42`, 37 `480`, 38 `3`, 39 `12`, 40 `2`, 41 `0`, 42 `56`, 43 `3`, 44 `3`, 45 `972`, 46 `486`, 47 `18`, 48 `24`, 49 `59`, 50 `39`, 51 `72`, 52 `140`, 53 `5`.
- 54-63 uyğunlaşdırma (fırlanmış yazı, hissələri kəsik görünür: açar şəklini yenidən böyüdüb oxu): 54 `...; c, e; b`, 55 `...; c, e; a`, 56 `...; c; a; d, e`, 57 `...; c; a; d, e`, 58 `d; c; b`, 59 `d; a, b; e`, 60 `c, d; a; b`, 61 `b; a, c; d`, 62 `b; a; d, e`, 63 `a, c; e; d`. Başlanğıcları (sətir 1) oxu və yoxla.
- 64-70 ədədi: 64 `300`, 65 `315`, 66 `520`, 67 `495`, 68 `700`, 69 `560`, 70 `24`.
- 71 `18`, 72 `2,8 metr` (ATLA), 73 `2,7 metr` (ATLA), 74 `18`, 75 `23`, 76 `14`, 77 `17`, 78 `48`, 79 `24`, 80 `51`, 81 `24`, 82 `27`, 83 `4`, 84 uyğunlaşdırma (`a, d...`: oxu), 85 uyğunlaşdırma (`b, d...`: oxu), 86 `10`.
- ATLANAN (sözlü/ölçü vahidli/iki cavablı): 72, 73, 87 `6 m, 32`, 88 `8 m, 26`, 89 `12 man, Anar 9, Rəşad 7`, 90 `16 man, Anar 7, Rəşad 5`, 91 `6 m`, 92 `18 m`, 93 `8 sm, 20`, 94 `4 sm, 30`. 95 `81`, 96 `91` ədədidir.
- Açar sahibə görə şübhəli yerlər: uyğunlaşdırma açarları fırlanmış kiçik yazıdır, şəkli görmədən yazma.

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

## Dərslər (bu kitabda)
- **`--recrop` hər `y1`-ə yenə 12 px əlavə edir.** Toxunmadığın suallarda manifestdə `y1`-dən 12 çıx, yoxsa sual növbəti sualın ilk sətrini də götürür. `add` ilə qoyulan `--end` bir dəfə +12 alır.
- Sütunun SONUNCU sualı üçün `y1` boş qalır (0) və recrop xəta verir (`lower < upper`): həmişə `--end` ver.
- `--end` dəyəri sualın real aşağı sərhədindən bir az AŞAĞI olmalıdır (Q17 üçün 310 sətri kəsdi, 322 işlədi). Əvvəl `grid` ilə real y-ni ölç.
- OCR sətir daxilindəki rəqəmi ("3. a ədədini 8-ə...") sual nömrəsi sanıb səhv sütunda tapa bilər (bölmə 3: Q8). Nömrə-sütun uyğunsuzluğunu hesabatda yoxla.
- Sütunun sonundakı sual səhifə nömrəsini və "CamScanner" yazısını da qəbul edir: kiçik qüsur, düzəldilmir.
- Cavab açarında rəqəm sütunlarını böyüdüb oxu (2x), bütün cədvəli bir şəkildə oxuma: fırlanmış yazı kəsilir.

## Fəsillər (içindəkilər, çap səhifəsi; pdf = çap - 2)
Natural ədədlər 4 · Adi və onluq kəsrlər 13 · Faiz. Nisbət. Tənasüb 20 · Həqiqi ədədlər 31 · Tam cəbri ifadələr 36 · Çoxhədlinin vuruqlara ayrılması 41 · Rasional kəsrlər 47 · Kvadrat köklər 55 · Birməxsuslu tənliklər və məsələlər 68 · Tənliklər sistemi 86 · Bərabərsizliklər 97 · Ədədi ardıcıllıqlar 113 · Çoxluqlar 129 · Həndəsəyə aid anlayışlar 135 · Üçbucaqlar 144 · Çoxbucaqlılar 162 · Çevrə və dairə 173 · İsbat məsələləri · Situasiya 197 · 2025 imtahanları (buraxılış, qəbul) 209 · Mövzular üzrə testlərin düzgün cavabları 213.
Səhifə nömrələri içindəkilərdən oxunub, iki-üç fəsil üçün dəqiq deyil: skan etməzdən əvvəl `scan_tool.py strip` ilə yoxla. Fəsildə hər alt mövzunun içindəkilərdəki adı = `--topic`.
- **"Situasiya"** və **2025 imtahanları** (pdf ~207-211, çap 209-) bölmələri ayrıca qərarla (Situasiya yazılı, imtahanlar DİM PDF-ləri ilə üst-üstə düşə bilər: kimyadakı kimi təkrar çəkilməsin).
