# Kitab bölməsi əlavə etmək: az token qaydası

Harada dayandığımız: `KITAB_IRELILEYIS.md` ("Qısa vəziyyət" + "Növbəti").
Skriptlər: `scan_segment.py` (OCR və kəsmə), `scan_tool.py` (köməkçilər), `import_scans.py` (SQL).

## Niyə
Bölmə 10–14-də kontekstin ~50%-i şəkillərə baxmağa getdi: bütün sualların böyük vərəqləri, eyni sərhədi
3–5 dəfə düzəldib yenidən baxmaq, əyri səhifədə bucaq axtarmaq. Bölmə 15–17-də bu qayda ilə xərc 3–4 dəfə az oldu.

## Qaydalar
1. **OCR-ın tapdığı suallara BAXMA.** Yalnız əl ilə əlavə olunanları və bölmənin ilk/son sualını yoxla.
2. Yoxlama vərəqi KİÇİK olsun (`check` 260 px). Yalnız yuxarı kənarı lazımdırsa, `--tops`.
3. Bir dəfə bax, düzəlt, sonra yalnız düzəldilənlərə bir dəfə də bax. Üçüncü dəfə baxma.
4. **Kiçik qüsuru düzəltmə:** qonşu sualın nazik sətri, başlıq qırığı, səhifə nömrəsi. Yalnız sual və ya variant kəsilibsə düzəlt.
   Sahib tətbiqdə test edir və pis şəklin kodunu deyir.
5. Əl ilə kəsəndə yuxarı sərhəd nömrənin ~15 px YUXARISIdır, yoxsa ilk sətir silinir (`drop_cut_lines`).
6. Əyri sütunda (variantlar kəsilirsə) bucaq axtarma: `tilt` = nömrələrin x-i; lazımdırsa `tilt_angle_fixed: 1.5`.
7. Səhifələrə baxanda `strip` (4 səhifə bir kiçik şəkildə) işlət, hər səhifəni ayrıca açma.
8. "Ətraflı yazılı cavab" bölmələri ATLANIR, soruşma. Sıralama sualı (cavab `3, 4, 1, 2`) buraxılır: tətbiqdə bu tip yoxdur.
9. Kiçik bölmələri birləşdir (məs. 16 + 17 bir dəfəyə). Sahib iki SQL + bir qovluq yükləyir.
10. Hesabat qısa: neçə sual, tiplər, nə buraxıldı, sahibin 3 addımı (linklərlə).

## Addımlar (bir bölmə)
Mac-də venv: `pip install pymupdf rapidocr-onnxruntime pillow numpy` (scratchpad-da). `T` = PDF faylı.
```
python scan_tool.py strip 83 86                       # bölmə harada bitir
python scan_tool.py key 335 0.17 0.42                 # cavab açarı (pdf səhifə, yuxarı/aşağı payı)
python scan_segment.py "$T" --first F --last L --start 1 --stop N --skip-above F:COL:Y --out scan/kimya_I_bolmeK
python scan_tool.py grid 84:0:510:30:520 ...           # yalnız tapılmayanların yerini ölç (p:x0:x1:y0:y1)
python scan_tool.py add scan/kimya_I_bolmeK '{"14":[84,0,1421]}' --end '{"14":1528}'
python scan_segment.py "$T" --first F --last L --out scan/kimya_I_bolmeK --recrop
python scan_tool.py check scan/kimya_I_bolmeK 1 14 N    # əl ilə əlavə olunanlar + ilk/son
# scan/kimya_I_bolmeK_cavablar.json yaz (qapalı hərf, çoxlu "1,3", ədəd "12.5", uyğunlaşdırma "a; b, e")
python import_scans.py --dir scan/kimya_I_bolmeK --answers scan/kimya_I_bolmeK_cavablar.json --book 1 --section K \
   --subject kimya --section-name "Ümumi kimya" --topic "..." --source-ref "Kimya test toplusu I (2025), bölmə K" --year 2025
```
- Son sualın altında növbəti başlıq varsa: `--end '{"N": y}'` ilə kəs.
- Sütunda davam edən sual: növbəti sütunun ilk sualına `cont_top` (davamın başladığı y).
- Sahib "ok" deyəndə: `python scan_tool.py done K` (şəkilləri `upload_kitab` → `images_kitab`), sonra `KITAB_IRELILEYIS.md`-i yenilə.
- `test_import_scans.py` Mac-də işləmir (Python 3.14 üçün `pgserver` yoxdur): SQL-də sətir sayını və tipləri `grep` ilə yoxla.
