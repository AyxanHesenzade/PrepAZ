# Test kitabları: harada dayanmışıq

Hər bölmə bitəndən sonra bu fayl yenilənir. Yeni işə başlamazdan əvvəl buradan bax.
Son yenilənmə: 2026-10-31

## Qısa vəziyyət
- **Kitab 1:** "Kimya test toplusu I" (DİM, 2025, 359 səhifə)
- **Fayl:** `tools/dim/Kimya test toplusu I 2025 _250822_103034.pdf`
- **Hazır bölmələr:** 1, 2, 3, 4, 5
- **Bazada:** 206 şəkil-sual
- **Növbəti:** pdf səhifə 19-da, sol sütunda "Ətraflı yazılı cavab tələb olunan tapşırıqlar" başlayır (pdf səhifə 20-nin sonuna qədər, 18 tapşırıq). Bunlar test deyil, ayrıca qərar lazımdır. Sonrakı test bölməsi pdf səhifə 21-dən yoxlanmalıdır.
- **Səhifə qeydi:** kitabda çap olunmuş səhifə nömrəsi = pdf səhifəsi + 1 (pdf 15 = kitabda 16).

## Bölmələr

| Bölmə | Ad / mövzu | PDF səhifə | Kəsilib | Yüklənib | Yüklənməyib | Kod | Cavab faylı |
|---|---|---|---|---|---|---|---|
| 1 | Kimyanın əsas anlayışları | 3–9 | 87 | 87 | 13 sual (1–100 arası) | `KT1-S01-Qnnn` | `scan/kimya_I_bolme1_cavablar.json` |
| 2 | Valentlik və kimyəvi formulların tərtibi | 9 | 16 | 16 | yoxdur | `KT1-S02-Qnnn` | `scan/kimya_I_bolme2_cavablar.json` |
| 3 | Kimyəvi formullar üzrə hesablamalar | 10–14 | 75 | 53 (1–53) | 22 sual (54–75) | `KT1-S03-Qnnn` | `scan/kimya_I_bolme3_cavablar.json` |
| 4 | Fiziki və kimyəvi hadisələr, kimyəvi tənliklər | 14 (sağ sütun)–17 | 32 | 22 (1–22) | 10 sual (23–32) | `KT1-S04-Qnnn` | `scan/kimya_I_bolme4_cavablar.json` |
| 5 | Kimyəvi tənliklər üzrə hesablamalar | 17–19 | 37 | 28 (1–28) | 9 sual (29–37) | `KT1-S05-Qnnn` | `scan/kimya_I_bolme5_cavablar.json` |

Cavablar kitabda səhifə 331-dən başlayır.

## Yarımçıq qalan suallar
- **Bölmə 1:** 13 sual yoxdur. OCR tapmayanlar və A–E olmayan uyğunlaşdırma sualları. Dəqiq siyahı `scan/kimya_I_test/manifest.json`-da.
- **Bölmə 3, sual 54–60:** çoxseçimli cavab. Tətbiqdə şəkil-sual üçün dəstək yoxdur.
- **Bölmə 3, sual 61–75:** ədədi cavab. Tətbiqdə şəkil-sual üçün cavab xanası yoxdur.
- **Bölmə 4, sual 23–30:** çoxseçimli cavab. Açar `scan/kimya_I_bolme4_cavablar.json`-da saxlanıb (məs. 23 = "2,4").
- **Bölmə 4, sual 31–32:** ədədi cavab (31 = 5, 32 = 15). Şəkillər kəsilib, amma 32-ci sualın şəkli yoxlanmayıb.
- **Bölmə 5, sual 29–30:** çoxseçimli cavab (1,2,3 və 1,2,5). Açar faylda saxlanıb.
- **Bölmə 5, sual 31–37:** ədədi cavab. Açar faylda saxlanıb, şəkillər yoxlanmayıb.

Bu tip suallar üçün əvvəl tətbiq dəyişməli və yeni APK çıxmalıdır. Yalnız A–E hərf cavablı suallar tətbiqi yeniləmədən bazadan gəlir.

## Yeni bölmə əlavə etmək
Ətraflı: `CLAUDE.md` → "Skan edilmiş test kitabları".
1. Bölmənin başlanğıc və son səhifəsini tap.
2. `scan_segment.py` ilə sualları kəs, hesabatda "missing" olanlara bax.
3. Kəsilmiş şəkilləri yoxla.
4. Cavabları kitabdan `scan/kimya_I_bolmeN_cavablar.json` faylına yaz.
5. `import_scans.py` işlət: `out/import_kt1_sNN.sql` və `out/upload_kitab/` yaranır.
6. Sahib SQL-i SQL Editor-da işlədir, şəkilləri `upload_kitab` qovluğundan yükləyir.
7. Sahib "ok" deyəndən sonra şəkillər `out/images_kitab/` qovluğuna köçürülür.
8. **Bu faylı yenilə:** cədvəl, "Qısa vəziyyət" və tarix.

## Bölmə kəsəndə diqqət
- **Hazırlıq (Mac):** müvəqqəti venv-də `pip install pymupdf rapidocr-onnxruntime pillow numpy openpyxl`.
- **Başlıq sütunun ortasındadırsa:** əvvəlki bölmənin suallarını ikisi ilə də at. Bölmə 4 üçün əmr:
  `--first 14 --last 17 --start 1 --stop 32 --skip-above 14:0:1570 --skip-above 14:1:800`
- **Şəkilləri gözlə yoxla:** səhifə əyri olanda variant kəsilə və ya qonşu sualın sətri düşə bilər. Bölmə 4-də 5–9, 15–18 və 21-ci suallar əl ilə düzəldilib.
- **OCR tələsi:** sətir rəqəmlə başlayırsa ("16 q kükürd"), sual nömrəsi sayılır və arxadakı suallar itir. Bölmə 5-də belə oldu: qalan hissə ayrıca `--start 8 --skip-above 17:0:1010` ilə tarandı, tapılmayanlar əl ilə ölçüldü, manifest birləşdirildi.
- **Avtomatik təmizləmədən sonra hər şəklə bax:** bölmə 5-də qonşu izlərini silən skript 17-ci sualın D və E variantlarını, maska isə 15-ci sualın "43,8" rəqəmini silmişdi. İkisi də gözlə yoxlamada tutuldu.
- **Əyri səhifə:** bölmə 5-in 15, 17, 18, 19 və 27-ci şəkilləri əl ilə düzəldilib, `--recrop` onları pozar.
- **`--recrop` tələsi:** manifestin `box` sütununda `y1` sualın aşağı sərhədi deyil, ilk kəsimdə ona 12 piksel pay artıq əlavə olunub. `--recrop` bir də 12 əlavə edir. Yenidən kəsməzdən əvvəl toxunmadığın suallarda `y1`-dən 12 çıx, əl ilə ölçdüyün suallarda isə `y1 = real sərhəd - 12` yaz.
