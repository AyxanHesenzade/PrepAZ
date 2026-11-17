# Riyaziyyat test toplusu I: harada dayanmışıq

Bu faylı yeni sessiyada ƏVVƏL oxu. Hər alt mövzu bitəndə yenilə.
Son yenilənmə: 2026-11-17

## Qısa vəziyyət
- **Mənbə:** DİM "Riyaziyyat test toplusu I hissə" (2025), skan. Fayl: `tools/dim/riyaziyyat/riyaziyyat_I_2025.pdf` (235 səhifə).
- **Yüklənib (test Supabase):** Fəsil "Natural ədədlər", alt mövzular 1, 2, 3 (**79 sual**, 2026-11-17). Şəkillər `out/images_kitab/`-dadır, `out/upload_kitab/` boşdur.
- **Bölmə 4** (ƏBOB/ƏKOB, 63 sual) kəsilib, `import_rt1_s04.sql` hazırdır; sahib yükləyib "done" deyəndən sonra `scan_tool.py --subject riyaziyyat --prefix RT done 4` və cədvəl yenilənir. **NÖVBƏTİ: fəsil 2 "Adi və onluq kəsrlər"** (pdf 11-dən, çap 13; açar pdf 212; bölmə nömrəsi 5-dən).
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
| 4 | Natural ədədlər / Natural ədədlərin sadə vuruqlara ayrılışı. ƏBOB. ƏKOB | 5 (sağ sütun)-8 | 1-63 (64-96 yazılı, atlandı) | SQL + şəkillər hazır (22 qapalı, 31 ədədi, 10 uyğunlaşdırma), sahib yükləyir; sual sayı 63 (Q64-96 yazılı) |

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
