# tools/dim: sual hazırlama alətləri

```
common/      ortaq kod + DB testləri + raw/ (DİM PDF-ləri, bütün fənlər)
kimya/       kimya məlumatı (images/, out/, scan/, kitab PDF) + kimyaya xas skriptlər + KITAB_IRELILEYIS.md
biologiya/   biologiya məlumatı (images/, out/) + biologiyaya xas skriptlər
```

Komandalar **fənn qovluğundan** işlədilir (nisbi yollar `out/...`, `scan/...` ora görədir):

```
cd tools/dim/kimya
python ../common/compress_images.py --check
python ../common/import_scans.py --dir scan/kimya_I_bolmeNN --answers scan/kimya_I_bolmeNN_cavablar.json ...
python scan_tool.py strip 224 228

cd tools/dim/biologiya
python extract_biologiya.py
python ../common/check.py --subject biologiya
```

DB testləri: `python common/test_migration_0NN.py` (pgserver lazımdır).
Yolların hamısı `common/paths.py` və `common/subjects.py`-dadır. Ətraflı: layihə kökündəki `CLAUDE.md`.
