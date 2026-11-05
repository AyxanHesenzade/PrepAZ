# PrepAZ — layihə yaddaşı

Bu fayl Claude Code üçündür: layihənin məqsədini, qəbul edilmiş qərarları və iş qaydalarını saxlayır.
Hər yeni sessiya əvvəl bu faylı oxuyur. Vacib qərar dəyişəndə bu faylı yeniləyin.

## Məhsul
Azərbaycanda buraxılış və qəbul imtahanlarına hazırlaşan şagirdlər üçün mobil tətbiq.
Əsas ideya: test bazası yox, **şəxsi məşqçi** — şagirdin səhvlərini izləyir, zəif mövzuları göstərir,
gündəlik planı özü qurur.

## Layihə sahibi necə işləyir
- Ünsiyyət dili: Azərbaycan dili. Kod, dəyişən adları və commit mesajları: ingilis dili.
- Hər mərhələnin sonunda: nə edildi, necə yoxlanıldı, növbəti addım nədir — qısa.

## Qəbul edilmiş qərarlar
| Mövzu | Qərar | Səbəb |
|---|---|---|
| Ad | **PrepAZ** (paket: `prepaz`, bundle/applicationId: `az.prepaz`)
| Mobil | Flutter (Dart) | Bir kod → Android + iOS; riyazi düsturları nativ göstərir; ucuz telefonlarda axıcı |
| Platforma | **Uzun müddət yalnız Android** (2026-11-03) | iPhone versiyası planlaşdırılmır; Android-ə xas həllər (məs. Nearby Connections) seçilə bilər |
| Backend | Supabase (PostgreSQL 15+) | Hazır auth, API, storage; ayrıca server yazmağa ehtiyac yoxdur |
| Region | Frankfurt (eu-central-1) | Azərbaycana ən yaxın |
| Oflayn | SQLite (drift) telefonda | Avtobusda/metroda internetsiz həll |
| Düsturlar | LaTeX, `$...$` arasında | |
| Sual daxil etmə | Excel şablonu → `tools/import_questions.py` | Sonra veb admin panel |
| Admin panel | **React (Vite) + Ant Design**, ayrıca qovluq: `C:\Users\ayxan.hv\Desktop\PrepAzAdmin` (öz README-si var). Supabase auth + RLS (`admins` cədvəli, `is_admin()`, migration 005) | Müəllim Excel əvəzinə birbaşa sual əlavə/redaktə edir. Mərhələ 6: v1 yazılıb (siyahı, süzgəc, redaktə, aktiv/passiv, yeni sual, şəkil yükləmə, LaTeX önbaxış) |
| MVP-də AI | **Yoxdur** | Səhvdən sonra müəllimin yazdığı hazır həll göstərilir |
| Supabase "Automatically expose new tables" | Söndürülüb | Giriş hüquqları `schema.sql`-də açıq yazılıb |

## Sual mənbələri (hüquqi)
- Hər sualın `source` sahəsi məcburidir.


## Mühitlər
- **Test Supabase:** `ehaqunuwkccwosaorvgy` (Frankfurt). Konfiqurasiya: `app/env/test.json`. Test üçündür, məlumat silinə bilər.
- **Real Supabase:** ayrıca layihə olacaq. Konfiqurasiya: `app/env/prod.json` (gitignore-dadır, nümunə: `prod.example.json`).
  Real layihədə `db/schema.sql` bir dəfə, sonra `db/migrations/` faylları ardıcıllıqla işlədilir.
- Debug rejimdə (F5, ▶, flutter run) TEST mühiti avtomatik götürülür (`lib/core/config/debug_defaults.dart`, yalnız açıq URL + publishable key).
  Release build mütləq `--dart-define-from-file=env/prod.json` tələb edir. `service_role`/parol heç vaxt koda yazılmır.
- claude.ai sessiyasının mühiti Flutter, pub.dev və Supabase-ə çıxa bilmir. Orada yazılan Dart kodu
  kompilyasiya olunmayıb, VS Code-da `flutter analyze` / `flutter test` / `flutter run` ilə yoxlanmalıdır.

## Struktur və kod qaydaları
Layihə kökdədir (köhnə `prepaz/` qovluğu silinib; `db/` və `tools/` yenidən lazım olsa, Supabase-dən/yenidən yazılacaq).
```
lib/
  main.dart, app.dart        giriş nöqtəsi, MaterialApp
  core/                      config, constants (AppStrings), error (AppException, guard),
                             theme (AppTheme, AppSpacing), utils (Validators), widgets (ortaq), providers
  features/<ad>/
    domain/                  entity + abstract interface (Flutter/Supabase bilmir)
    data/                    Supabase implementasiyası (guard ilə AppException atır)
    presentation/            providers, controller (Notifier), screen, widgets/
env/test.json, prod.json     dart-define faylları (prod.json gitignore-dadır)
```
- State: **Riverpod** (`flutter_riverpod`). UI yalnız `domain` interfeysini tanıyır, testdə `overrideWithValue(fake)`.
- Ekranlarda sətir yazılmır → `AppStrings`; boşluq/rəng → `AppSpacing`/`Theme`. Təkrarlanan UI → `core/widgets`.
- Data qatındakı hər çağırış `guard(...)` ilə sarınır; UI yalnız `AppException` görür.
- `.order()`-də `ascending:` həmişə açıq yazılır (postgrest defoltu azalandır). Qoruyucu test: `test/core/order_direction_test.dart`.
- Yeni feature: `domain` interfeys → `data` implementasiya → provider → ekran → test.

## Bazanın məntiqi (tətbiq bunları təkrar yazmamalıdır)
- `auth.users`-ə qeydiyyat → `profiles` avtomatik yaranır.
- `answers`-ə insert → `is_correct` SERVERDƏ hesablanır (tətbiqin göndərdiyi dəyər nəzərə alınmır).
- Səhv cavab → `review_queue` (1 → 3 → 7 → 14 gün); 4 ardıcıl düz → növbədən çıxır.
- `profiles.streak_days` avtomatik; istifadəçi dəyişə bilməz.
- `topic_mastery` view — mövzu üzrə son 30 cavabın faizi, yalnız `get_daily_set` üçün.
- `topic_progress` view (`db/migrations/013_topic_progress.sql`, lokal test: `tools/dim/test_migration_013.py`) — ekranda göstərilən nəticə: mövzudakı BÜTÜN aktiv testlərə görə, hər test bir dəfə, son cavab həlledicidir. Tətbiqdə `TopicMastery`: yaxşı = bütün testlərin ≥70%-i düz; zəif = ən azı 5 test həll edilib (kiçik mövzuda hamısı) və həll edilənlərin <70%-i düz; qalanı "davam edən".
- `get_daily_set(subject_id, limit)` RPC — əvvəl vaxtı çatmış təkrarlar, sonra zəif mövzular.
- Cavablar dəyişdirilə/silinə bilməz.

## Baza dəyişikliyi qaydası
- `schema.sql`-i Supabase-də **təkrar işlətməyin** (artıq qurulub). Yeni dəyişikliklər `db/migrations/NNN_ad.sql`
  kimi ayrıca faylda yazılır, əvvəl lokal testdən keçirilir, sonra SQL Editor-da işlədilir.
- Lokal test: `db/test/behavior_test.sql` (PostgreSQL 16 + `supabase_stub.sql`).

## Sirlər
- Supabase **Project URL** və **anon/publishable key** tətbiqə yazıla bilər (açıqdır, RLS qoruyur).
- **service_role / secret key** və baza parolu heç vaxt repoya, çata və ya tətbiqə düşməməlidir.

## Yol xəritəsi
- [x] Mərhələ 1: baza, sual şablonu, import — Supabase-də quruldu, 3 nümunə sual
- [~] Mərhələ 2: Flutter skeleti — giriş, ana səhifə (seriya, fənlər, zəif mövzular), sual ekranı, nəticə.
      Yenidən başlandı (təmiz arxitektura): auth + ana səhifə (seriya, fənlər) hazırdır. Növbəti: məşq (quiz) və nəticə ekranı
- [x] Mərhələ 3: "Zəif yerlərim" (mövzu üzrə məşq), səhvlər dəftəri (`features/mistakes`), seriya. `QuizRequest` (daily/topic/mistakes) məşqin mənbəyini seçir.
      Qeyd: `review_queue` + `questions!inner` sorğusu yalnız fake ilə testlənib, real Supabase-də əl ilə yoxlanmalıdır.
- [~] Mərhələ 4: oflayn rejim (drift) + sinxronizasiya. İlk versiya HAZIRDIR (2026-11-03, telefonda yoxlanıb: yükləmə, internetsiz açılış, yüklənmiş mövzuları həll etmək). Bölmə "Oflayn rejim" aşağıdadır. Qalıb: "Bugünkü məşq" və "Səhvlər dəftəri" oflayn, yüklənmiş mövzuların avtomatik yenilənməsi, tur addımı
- [ ] Mərhələ 5: taymerli sınaq imtahanı, bal hesablanması
- [~] Mərhələ 6: veb admin panel. v1 hazırdır (`PrepAzAdmin`), migration 005 işlədilməli. Növbəti: mövzu idarəsi
- [ ] Mərhələ 7: Play Store-a çıxış
- Gələcək fikirlər (sual bazası bitəndən sonra): `FIKIRLER.md` (məs. müəllim-şagird qrupları, ev tapşırığı, canlı nəticə).


## Sual Bazası

- Sualların bazası olaraq DİM dən itfadə edirik. və sorcuları qeyd edirik. dimlə razılaşılıb mənbəni qeyd etməklə isfadə etməyə icazə verir amma bizı script ilə çəkməyə icazə verib hanilar ki paylaşılıb onları çəkə bilərik heç bir risk yoxdur


## DİM kimya sualları (tools/dim, TASK_01)
- `download.py` → `extract_kimya.py` → `build_xlsx.py` → `check.py`. Nəticə: `tools/dim/out/kimya_dim_yoxlama.xlsx` (+ `images/`).
- PDF-lər iki sütunludur; indekslər/yüklər mətndə yox, şrift ölçüsü və baseline ilə saxlanılır (`chem_text.py` bunu LaTeX-ə çevirir).
- Köhnə `import_questions.py` və `schema.sql` silinib; `check.py` TASK_01 qaydalarını yoxlayır. Bazaya yükləmə yalnız müəllim yoxlamasından sonra.

## Kimya sualları: yükləmə axını (TASK_02)
1. Müəllim `tools/dim/out/muellim_1_dest.xlsx`-i doldurur (çətinlik 1-5, aktiv bəli/xeyr, qeyd).
2. `python merge_review.py` → əsas Excel-ə köçürür (ehtiyat nüsxə ilə). `python check.py` yoxlayır.
3. `python import_questions.py` → `out/import_kimya.sql` (xəta varsa heç nə yazmır). Sahib SQL Editor-da işlədir.
4. Şəkillər: əvvəl `db/migrations/002_question_images_bucket.sql`, sonra `python upload_images.py --prepare` (panelə sürüklə) və ya `--upload` (SUPABASE_URL + SUPABASE_SERVICE_KEY yalnız mühit dəyişəni kimi).
5. Lokal test: `python test_import_local.py` (pgserver, db/test/schema_reconstructed.sql: enum etiketləri və grantlar FƏRZDİR).
- `build_xlsx.py` mövcud Excel-in üstünə yazmır (KIM-xxxx kodları bazada açardır).
- Tətbiqdə məşq feature-ı hazırdır: `lib/features/quiz` (LaTeX, şəkil + zoom, izah, nəticə), ana səhifədə zəif mövzular.
- Baza qeydi: `topic_mastery` view-ı bütün istifadəçilərin sətirlərini saxlayırdı. `db/migrations/004_topic_mastery_security_invoker.sql` onu `security_invoker` edir
  (lokal test: `tools/dim/test_migration_004.py`). Test və real Supabase-də SQL Editor-da işlədilməlidir; işlədilənə qədər açıqdır.
- İzah şəkli: hər sual üçün orijinal izah `images/KIM-xxxx_izah.png` (kəsr/cədvəl mətndə pozulur). Excel sütunu `izah şəkli`, baza sütunu
  `questions.solution_image_path` (db/migrations/003; get_daily_set da yenilənir, çünki `setof questions` qaytarır). Tətbiq şəkli mətn əvəzinə göstərir.
- Yeni sütun əlavə etmək: `sync_new_columns.py` (təsdiqləri pozmur). Əsas Excel-i heç vaxt `build_xlsx.py --force` ilə yenidən qurma.
- 2-ci partiya: `make_teacher_file.py --batch 2` → `muellim_2_dest.xlsx` (46 sual, orijinal şəkillər faylın içindədir); `merge_review.py out/muellim_2_dest.xlsx`.
- Yükləmə ardıcıllığı: 003 migration → 002 migration → `import_kimya.sql` → şəkillər (`upload_images.py --prepare` və ya `--upload`).
- Şəkillər AÇIQDIR (`lib/core/config/app_features.dart` → `questionImages = true`): biologiya və kimyada şəkil sualın özüdür. Test Supabase-də bucket var, 120 şəkil yüklənib; qalanları təsdiqdən sonra `upload_images.py` ilə. Storage yükü ~17 MB (limit 1 GB); risk aylıq trafikdir (5 GB), lazım olsa cache + sıxma.
- **Şəkillər WebP-dir** (migration `015_webp_images.sql`, 2026-11-03: test Supabase-də 616 şəkil çevrildi, köhnə PNG-lər silindi; ölçü PNG-nin ~44%-i, gözlə fərq yoxdur). Qayda:
  - Orijinal PNG-lər (`tools/dim/images`, `out/images_kitab`) qalır, Excel-də `şəkil` / `izah şəkli` PNG adı ilə qalır (kodlar açardır). Bazaya və bucket-ə yalnız `.webp` adı yazılır (`compress_images.web_name`).
  - **DİM sualları:** əvvəl `python compress_images.py` (→ `out/webp/`, `--check` yoxlayır), sonra `import_questions.py` (WebP yoxdursa dayanır), şəkillər `upload_images.py --prepare` / `--upload` ilə `out/webp`-dən yüklənir.
  - **Kitab skanları:** `import_scans.py` şəkli özü WebP-yə çevirib `out/upload_kitab/`-a yazır (`upload_kitab` qaydası dəyişmir, fayllar `.webp`dir; `--folder out/upload_kitab --upload`).
  - Köhnə PNG-ləri silmək: `upload_images.py --folder out/webp --delete-png [--yes]` (service key yalnız mühit dəyişəni; Git Bash-da `export`, PowerShell-də `$env:`).
  - Niyə: 9 fənn × minlərlə şəkil üçün həcm/trafik (oflayn yükləmə planı, Mərhələ 4). Növbəti: oflayn rejim, mövzu üzrə yükləmə.


## Fənlər və yeni sual əlavə etmək
- Fənn parametrləri `tools/dim/subjects.py`-dadır (kod prefiksi, Excel, bölmələr): `kimya` (KIM-), `biologiya` (BIO-).
- Biologiya: `extract_biologiya.py` → `build_biologiya.py` → `out/biologiya_dim_yoxlama.xlsx` (119 sual, hamısı müəllim yoxlaması gözləyir).
  `check.py --subject biologiya`, `import_questions.py --subject biologiya`; lokal test: `test_import_biologiya.py`.
  Bazada `subjects` cədvəlinə `biologiya` sətri əl ilə əlavə olunmalıdır (idxal SQL-i onsuz dayanır).
- **Yeni DİM PDF əlavə etmək:** `download.py` SOURCES + `extract_kimya.py` FILES (SONUNA, köhnə kodlar sürüşməsin) → `extract_kimya.py` / `extract_biologiya.py`
  → `python append_new.py --subject kimya|biologiya` (yalnız yeni unikal sualları əlavə edir, köhnə kod/təsdiq/şəkilə toxunmur, eyni sual başqa imtahanda
  çıxıbsa onu mövcud sətrə birləşdirir, oxşar sualları "oxşar sual: KOD" qeydi ilə işarələyir). `build_*.py` yalnız ilk dəfə.
- Kimya Excel-i indi 240 sual (ilk 120 yoxlanıb, sonrakı 120 təzə əlavə olunub, müəllim yoxlaması gözləyir). `make_teacher_file.py` hələ yalnız kimyadır.
- Ehtiyat nüsxə: hər Excel üçün tək `*.backup.xlsx` (hər dəfə üstünə yazılır).
- Sual mənbəyi: DİM (razılaşma var) və Araz/Güvən (sahib bildirir ki, razılıq alınıb, 2026-10-30; yazılı razılığın surətini saxlamaq tövsiyə olunur). Yalnız sahibin verdiyi fayllar qəbul olunur, internetdən qeyri-rəsmi PDF çəkilmir.
- Dərsliklər (məktəb kitabları) üçün razılıq YOXDUR: mövzu izahlarında yalnız mənbə/plan kimi, mətn öz sözlərimizlə yazılır, köçürülmür.

## Versiya
- Cari versiya: **1.5.0**, build **11**. Mənbə: `assets/app.json`; `pubspec.yaml` → `version: 1.5.0+11` ilə eyni olmalıdır (`test/core/app_version_test.dart` uyğunsuzluğu tutur).
- Yeni buraxılışda hər ikisini birlikdə dəyiş. Ana ekranın altında "Versiya 1.5.0 (11)" göstərilir.

## Test Supabase-in cari vəziyyəti (2026-11-02)
- Migration 014 işlənib, kitab 1-dən 253 şəkil-sual yüklənib (206 qapalı, 47 açıq).
- Migrationlar işlənib: 002, 003, 004 (`topic_mastery` security_invoker).
- Yüklənib: kimya 158 sual, biologiya 81 sual (`biologiya` fənni aktivdir). Şəkillər `question-images` bucket-indədir.
- Gözləyən: kimyada 82 sual (yoxlanmayıb / cavabsız / yazılı), biologiyada 38 sual (yazılı, açıq tapşırıq, cavabı uyğunlaşmayan).
- Real (prod) Supabase hələ qurulmayıb.

## Admin panel (Mərhələ 6)
- `db/migrations/005_admin_panel.sql`: `admins` cədvəli, `is_admin()`, adminə bütün sualları görmək/əlavə/yeniləmək, mövzu əlavəsi, `question-images` bucket-inə yükləmə.
  Sual SİLİNMİR (is_active=false). Lokal test: `tools/dim/test_migration_005.py` (19 yoxlama).
- Admin əlavə etmək (yalnız SQL Editor-da əl ilə): `insert into admins (user_id) select id from auth.users where email = '...';`
- Panel yalnız açıq URL + publishable key bilir (`PrepAzAdmin/.env.local`). service_role heç vaxt.
- Redaktor köməkçiləri (`PrepAzAdmin/src/lib/formula.js`, testli): düstur çevirici (`H2SO4 + 2NaOH -> Na2SO4 + 2H2O` → `$\mathrm{...}$`, ion yükü üçün `Fe^3+`),
  simvol düymələri (→ ⇌ ↑ ↓ Δ ° · × ≥ ≤ indeks kəsr kök), "Yapışdır və böl" (A–E variantlarını ayırır), oxşar sual xəbərdarlığı.

## Skan edilmiş test kitabları (şəkil-sual)
- **Az token qaydası: `tools/dim/SUAL_ELAVE_AZ_TOKEN.md` (köməkçi: `tools/dim/scan_tool.py`). Kitab işinə başlamazdan əvvəl MÜTLƏQ oxu:** OCR-ın tapdığı suallara baxılmır, yalnız əl ilə kəsilənlər kiçik vərəqdə bir dəfə yoxlanır, kiçik qüsur düzəldilmir.
- **Kitabda harada dayandığımız `KITAB_IRELILEYIS.md`-dədir.** Kitab işinə başlamazdan əvvəl onu oxu, hər bölmə bitəndə mütləq yenilə (bölmə cədvəli, "Qısa vəziyyət", tarix).
- Mənbə: sahibin əlindəki nəşriyyat/DİM test topluları (şəkil PDF). Yalnız sahibin verdiyi fayllar; internetdən qeyri-rəsmi PDF çəkilmir.
- `tools/dim/scan_segment.py KITAB.pdf --first N --last M --start 1 --stop 100 --out scan/<ad>`: RapidOCR yalnız sual nömrələrinin yerini tapır
  (ardıcıl artan nömrə qaydası), hər sual ayrıca təmizlənmiş şəkil kimi kəsilir (haşiyə silinir, ağ kağız, 2x böyütmə). Nümunədə 87/100 tapıldı;
  OCR bəzi sətirləri (səhifə yuxarısı, əyri sətirlər) oxumur. Tapılmayanlar hesabatda "missing" kimi görünür.
- Cavab açarı kitabın sonundan əl ilə JSON-a yazılır (`scan/kimya_I_bolme1_cavablar.json`). Açarın forması tipi təyin edir ("Açıq sual tipləri" bölməsinə bax).
- `tools/dim/import_scans.py` → `out/import_kt1_s01.sql` + `out/upload_kitab/` (şəkillər koda görə adlanır). Kod: `KT<kitab>-S<bölmə>-Q<nömrə>`
  (məs. `KT1-S01-Q030`): problem bildirişində kod birbaşa kitabda yeri göstərir. Sual mətni BOŞDUR, qapalı sualda variantlar yalnız hərfdir ("A".."E").
- Tətbiq: `Question.isImageOnly` (mətn boş + şəkil var) → şəkil + A–E hərf düymələri (`LetterOptions`). Admin panel mətn boş ola bilər (şəkil varsa).
- Kitablar: 1 = "Kimya test toplusu I" (DİM, 2025, 359 səhifə): bölmə 1 = səhifə 3–9 (sual 1–100), cavablar səhifə 331.
- Kitab 1 bölmələri: **bölmə 1** (səhifə 3–9, 87/100 sual yükləndi, mövzu "Kimyanın əsas anlayışları"), **bölmə 2** "Valentlik. Kimyəvi formulların tərtibi"
  (pdf səhifə 9, sol sütunda başlıqdan sonra, 16/16 sual, mövzu "Valentlik və kimyəvi formulların tərtibi"; əmr: `--first 9 --last 9 --start 1 --stop 16 --skip-above 9:0:630 --pad 18`).
  Növbəti bölmə 3 "Kimyəvi formullar üzrə hesablamalar" pdf səhifə 10-dan başlayır. Hər bölmə üçün `scan/kimya_I_bolmeN_cavablar.json` əl ilə yazılır.
- `scan_segment.py` seçimləri: `--skip-above PAGE:COL:Y` (başlıqdan əvvəlki hissəni at), `--pad` (nömrədən yuxarı pay, valentlik işarələri üçün), `--recrop` (OCR-sız yenidən kəsmə).
  Lokal test: `test_import_scans.py out/import_kt1_sNN.sql`.
- **Yükləmə qovluqları (qayda):** sahib həmişə TƏK qovluqdan yükləyir: `tools/dim/out/upload_kitab/` = yalnız hələ yüklənməmiş yeni şəkillər.
  Sahib "ok" deyəndən sonra bu şəkillər `tools/dim/out/images_kitab/` qovluğuna köçürülür (artıq Storage-dədir). Yeni qovluq açılmır.
  Düzəldilmiş şəkil (eyni ad) yenidən yüklənəndə əvvəl Storage-dəki köhnəsi silinməlidir. `import_scans.py` yeni şəkilləri `upload_kitab`-a yazır.
- Bölmə 3 "Kimyəvi formullar üzrə hesablamalar": pdf səhifə 10-14, 75 sual kəsilib, yalnız 1-53 (hərf cavablı) yüklənir; 54-60 çoxseçimli, 61-75 ədədi cavablıdır.
  Əmr: `--first 10 --last 15 --start 1 --stop 75 --skip-above 10:0:105` (`--pad` defoltla: böyük pad əvvəlki sualın son sətrini yeyir).
  `scan_segment.py` indi sütunun sonunda davam edən sualları (`stitch_continuations`, `CONT_TOP`) avtomatik birləşdirir. Kəsmənin kənarı əyri sətirdə yanılsa, `manifest.json`-da `box` düzəldilib `--recrop` işlədilir.

## Açıq sual tipləri
- `db/migrations/014_open_question_types.sql` (lokal test: `tools/dim/test_migration_014.py`). Yoxlama serverdədir (`check_answer`).
- `aciq_eded`: yazı xanası, `12,5` və `12.5` eyni sayılır. Açar JSON-da onluq NÖQTƏ ilə: `12.5`.
- `coxlu_secim`: yalnız rəqəm yazılan xana, şagird `135` yazır, ekranda `1,3,5` görünür. Sıra və təkrar fərq etmir. Açarda vergüllə: `1,3,5`; bazada `135`.
- `uygunlasdirma`: sətir-hərf cədvəli (`MatchingGrid`), bir sətirdə bir neçə hərf seçilə bilər. Açarda kitabdakı kimi `c; b, e`; bazada `C;BE`, `options = {"1": "ABCDE", "2": "ABCDE"}`. Ekranda `1-c, 2-be`.
- Bütün sətirlər və hərflər düz olmasa, cavab səhvdir (qismən bal yoxdur).
- Tətbiq: `OpenAnswerInput` (`lib/features/quiz/presentation/widgets`) hər iki ekranda işləyir; cavabı göstərmək üçün `Question.formatAnswer` / `rightAnswerText`, `correctAnswer` birbaşa göstərilmir.
- Şəkil-suallar: `import_scans.py` tipi açardan özü tapır; `--open-only` qapalıları buraxır (`out/import_kt<kitab>_s<bölmə>_aciq.sql`).
- Köhnə APK bu tipləri tanımır: yeni tipli sual yükləməzdən əvvəl tətbiq yenilənməlidir (`min_version`).
- Admin panel (`PrepAzAdmin`) bu kompüterdə yoxdur, yeni tiplərə hələ uyğunlaşdırılmayıb.

## Dizayn, dil və menyu (tətbiq)
- Tema: `lib/core/theme` (böyük yumru künclər `AppRadius`, pill düymələr, Plus Jakarta Sans şrifti `assets/fonts`, fənn rəngləri `AppColors.subjectAccent`).
  Ortaq animasiyalı elementlər: `Pressable`, `FadeSlideIn`, `SoftProgressBar` (`lib/core/widgets`). Sonsuz animasiya yazılmır (testlər `pumpAndSettle` işlədir).
- Tətbiq interfeys dili: AZ / RU / EN (sualların dili bundan asılı deyil). `AppStrings` getter-dir (`const` deyil!): hər mətn `_t(az, ru, en)` ilə yazılır,
  yeni mətn əlavə edəndə üç dili də yaz. Dil `AppStrings.language`-dədir, ayarlar onu dəyişir; `PrepAzApp` dil dəyişəndə ağacı təzədən qurur.
- Ayarlar (dil + gündüz/gecə/sistem): `features/settings`, SharedPreferences-də saxlanır (`main.dart` override edir; testdə `InMemorySettingsRepository`).
- Ana səhifədə yan menyu (`features/menu/presentation/app_drawer.dart`): Dil, Görünüş (basanda açılır), Tövsiyə olunan müəllimlər, Dostunla paylaş, Xəta bildir, Şərtlər və məxfilik, Hesabı sil, Çıxış. Versiya yazısı ekranın altında sabitdir.
- **Dostunla paylaş** (`lib/features/share`): Android-in öz paylaşma pəncərəsi (`share_plus`), UI onu birbaşa çağırmır: `ShareService` interfeysi (`SystemShareService`, testdə fake) + `ShareAppAction`. Link koda yazılmır, hər basışda bazadakı `app_config.update_url`-dan oxunur (`appConfigRepositoryProvider`). Oxunmasa/boşdursa pəncərə açılmır, SnackBar `shareAppNoLink`. Mətn `AppStrings.shareAppMessage(link)` (üç dildə). Turda `TourStep.shareApp` (müəllimlərdən sonra).
  `update_url` həm yeniləmə, həm də dostlar üçün yükləmə linkidir: hamıya açıq işlək APK linki olmalıdır (Play Store-dan sonra mağaza linki).
- Tövsiyə olunan müəllimlər: məlumat YALNIZ `lib/features/teachers/data/teachers_data.dart`-da yazılır (ad, fənn, telefon, tanıtım, hazırlıq təklifi).
  Faylda hazırda NÜMUNƏ sətir var: real məlumatla əvəz et. Zəng/WhatsApp `url_launcher` ilə açılır.

## Tövsiyə olunan müəllimlər (dinamik)
- Baza: `db/migrations/006_teachers.sql` (`teachers` cədvəli, RLS: istifadəçi yalnız `is_active and consent` olanları görür, admin hamısını; silinmir; public bucket `teacher-photos`). Lokal test: `tools/dim/test_migration_006.py`.
- Nümunə (saxta) məlumat: `db/seed/teachers_demo.sql`, fotolar `tools/teachers/upload/` (`make_demo_photos.py`). Real buraxılışdan əvvəl "Nümunə ..." sətirləri passiv edilməlidir.
- Tətbiq: `lib/features/teachers` (repository + `teachersProvider` FutureProvider; ekranı dizayn agenti də dəyişə bilər). Admin panel: "Müəllimlər" tabı (`TeachersPage`, `TeacherDrawer`, `lib/teachers.js`).
- Müəllimdən məlumat toplama forması: ad, fənn, format (əyani/online/hər ikisi), yer, nömrə, haqqında, təklif, foto, razılıq (bəli/xeyr). Razılıq yoxdursa göstərilmir.
- Növbəti: məcburi yeniləmə ekranı (minimum versiya bazadan oxunur), tətbiqin adi yeniləmə xəbərdarlığı.

## Məcburi yeniləmə
- `db/migrations/008_app_config.sql`: tək sətirli `app_config` (`min_version`, `latest_version`, `update_url`); anon də oxuya bilər (giriş əvvəli yoxlanır), yalnız admin dəyişir. Lokal test: `tools/dim/test_migration_008.py`.
- Tətbiq: `lib/features/update` (`UpdateGate` `app.dart`-da `AuthGate`-i sarıyır). Versiya `assets/app.json`-dan (`1.5.0+11`) bazadakı ilə müqayisə olunur:
  `min_version`-dan aşağı → bağlanmayan `ForceUpdateScreen`; `latest_version`-dan aşağı → bir dəfə "Sonra" düyməli xəbərdarlıq. Oxunmasa (internet yox / cədvəl yox) heç nə bloklanmır.
- Admin panel: "Tənzimləmələr" tabı. Yeni buraxılışda ƏVVƏL APK/mağaza yüklənir və link yazılır, SONRA `latest_version` (və lazımsa `min_version`) qaldırılır.

## Problem bildirişləri
- `db/migrations/009_reports.sql`: `reports` (kind `question`/`app`, `question_id` + `question_code`, açıqlama 10-1000 simvol MƏCBURİ, `app_version`, status new/seen/done, `admin_note`).
  İstifadəçi yalnız əlavə edir (öz adından), oxuya bilməz; admin oxuyur/dəyişir/silir. Saatda 10 bildiriş limiti (`security definer` trigger: RLS səbəbindən adi istifadəçi sayı görə bilmir). Lokal test: `tools/dim/test_migration_009.py`.
- Tətbiq: `lib/features/reports` (`showReportSheet`). Sual ekranlarında `QuestionCodeLabel` "Xəta bildir" düyməsi + kod göstərir (quiz, mövzular, səhvlər dəftəri); yan menyuda "Tətbiqdə xəta bildir".
- Admin panel: "Bildirişlər" tabı (status süzgəci, status dəyişmə, daxili qeyd, silmə). Sual bildirişində kodu kopyalayıb Suallar tabında axtarırıq.

## İmtahan hədəfi (PLAN faza B)
- `db/migrations/010_exam_goals.sql`: `exam_periods` (qış 2027-02-15, yay 2027-06-15 = FƏRZ; yalnız admin dəyişir, silinmir) və `user_goals` (şagird yalnız özününkünü oxuyur/yazır, gündəlik hədəf 5-200). Lokal test: `tools/dim/test_migration_010.py`. Test və real Supabase-də SQL Editor-da işlədilməlidir.
- Tətbiq: `lib/features/goal` (`GoalRepository`, `GoalScreen`, `GoalCard`). Ana ekranda seriya altında kart: "N gün qalıb" + bu günkü cavab sayı/hədəf. Hədəf yoxdursa ilk açılışda seçim ekranı bir dəfə açılır; oxuma xətasında heç nə göstərilmir.
- Dövr adı `AppStrings.periodName(code, ad)` ilə tərcümə olunur (`winter`/`summer`); yeni kod əlavə olunsa bazadakı ad göstərilir.
- Admin panel: Tənzimləmələr tabında "İmtahan dövrləri" (tarix + aktiv).

## Giriş və qeydiyyat
- Ekran: `AuthScreen`. Əvvəlcə `AuthChoiceView` açılır: "Yeni istifadəçiyəm" / "Hesabım var" (tester tabları görmədiyi üçün tablar çıxarıldı), sonra ayrıca forma, yuxarıda geri düyməsi. Təsdiq lazımdırsa `EmailConfirmView` açılır: 3 addımlı təlimat, "Təsdiqlədim, davam et", "Yenidən göndər", "Geri qayıt".
- Sahibin qərarı (test mərhələsi, pulsuz Supabase): deep link YOXDUR, Supabase-in link ayarlarına toxunulmur. Məktubdakı link boş səhifə aça bilər, amma e-poçt təsdiqlənir.
- İstifadəçi tətbiqə qayıdanda `checkConfirmedSilently` yaddaşdakı parolla özü daxil olur. Parol yalnız yaddaşda qalır, heç yerə yazılmır.
- Təsdiqli e-poçtla təkrar qeydiyyatda Supabase xəta vermir, boş `identities` qaytarır: bu, `AccountExistsException` olur və ekran girişə keçir.
- Parol bərpası hələ yoxdur.

## Google ilə giriş
- Tətbiqdə: `AuthRepository.signInWithGoogle()` (`google_sign_in` 7.x: `GoogleSignIn.instance.initialize(serverClientId)` bir dəfə, `authenticate()`, sonra `Supabase.auth.signInWithIdToken(provider: google, idToken)`). İstifadəçi pəncərəni bağlasa `false`, xəta olsa `AppException(googleSignInFailed)`. Çıxışda və hesab silinəndə Google hesabı da çıxarılır.
- Düymə `AuthChoiceView`-dadır ("və ya" xəttindən sonra, böyük). E-poçt təsdiqi və parol lazım deyil. Razılıq qutusu yoxdur: düymənin altında "davam etməklə şərtləri qəbul edirsiniz" qeydi (`GoogleConsentNote`), basanda `acceptLegal` yazılır.
- Google Cloud layihəsi `PrepAZ` (Firebase vasitəsilə yaradılıb, kart istənmədi; Firebase özü istifadə olunmur). OAuth clientlər:
  - **Web** `PrepAZ Supabase`: redirect URI `https://ehaqunuwkccwosaorvgy.supabase.co/auth/v1/callback`. Client ID açıqdır: `AppConfig.googleWebClientId` (`GOOGLE_WEB_CLIENT_ID`, debug defoltu `DebugDefaults`, `env/test.json`). **Client secret yalnız Supabase-dədir**, repoya və koda düşməz.
  - **Android** `PrepAZ Android debug`: paket `az.prepaz`, debug SHA-1 `3E:FE:05:F1:75:59:4D:C8:6B:18:D1:EB:C3:4E:B7:16:7F:79:11:AC`.
  - **Android** `PrepAZ Android release`: paket `az.prepaz`, release SHA-1 `B5:31:09:76:32:18:08:89:E3:4B:AD:A4:CF:4C:30:0F:7C:E6:C9:14`. ID-si Supabase Client IDs-dədir (`web,debug,release`). 2026-11-03: release APK 1.4.0 (10) ilə bazada olmayan hesab Google ilə qeydiyyatdan keçdi, Testing rejimində də (Test users boş).
- Supabase (test) → Authentication → Providers → Google: Web ID + secret, Client IDs xanasında `webID,debugID,releaseID` (vergüllə, boşluqsuz). "Skip nonce checks" söndürülüb.
- Hələ edilməyib:
  - Play Store-da Play App Signing olsa, Play Console-dakı "App signing key" SHA-1-i üçün də ayrıca Android client lazımdır (yoxdursa Google girişi Supabase-ə çatmır: Auth loglarında `/auth/v1/token` görünmür).
  - Consent screen "Testing" rejimindədir. Yalnız əsas scope-larla (Android Credential Manager) Test users siyahısında olmayan hesab da girə bildi, amma ehtiyat üçün buraxılışdan əvvəl **Publish app** (əvvəl Branding səhifəsi doldurulmalıdır, çox güman ki məxfilik siyasəti linki lazımdır).
  - Web client secret söhbətdə göründüyü üçün yenilənməlidir (Clients → Add secret, Supabase-də dəyiş, köhnəni sil).
  - Real (prod) Supabase qurulanda Google provider orada da ayrıca aktivləşdirilir.
- Windows-da plugin-li layihəni build etmək üçün Developer Mode açıq olmalıdır (symlink).

## Öyrədici tur
- `lib/features/tour`: hədəf seçimi bağlanan kimi (hədəf artıq varsa və ya oxunmursa, ana ekran açılanda) bir dəfə başlayır. Bayraq telefonda: `AppSettings.tourSeen` (`settings.tour_seen`, SharedPreferences), yalnız son addımda true olur; yarıda bağlansa, yenidən başlayır.
- Ardıcıllıq (`TourStep`): salam → menyu düyməsinə basmaq (burada "Anladım" yoxdur, işıqlı düyməyə basılır) → Dil, Görünüş, Müəllimlər, Xəta bildir, Şərtlər və məxfilik, Hesabı sil, Çıxış → yan menyu bağlanır → birinci fənn kartı: Bugünkü məşq, Zəif yerlərim, Səhvlər dəftəri, Mövzular → son. Fənn yoxdursa, kart addımları atlanır. Tur atlanmır (sahibin istədiyi kimi yalnız "Anladım").
- Hədəf elementlər `TourTargets`-dəki GlobalKey-lərlə tapılır. Açarlar `HomeScreen`-in State-ində yaşayır və `TourScope` ilə ötürülür. Onları provider-ə və ya qlobal yerə qoyma: dil dəyişəndə `PrepAzApp` ağacı yenidən qurur, qlobal GlobalKey köhnə ekranı açıq yan menyu ilə köçürür və tətbiq donur. Yeni menyu elementi əlavə edəndə `TourStep`, `keyFor`, `_message` və üç dildə mətn də əlavə olunur.
- Ana ekranın başlığındakı balaca köməkçiyə (`HeaderMascot`) basanda tur bayraqdan asılı olmayaraq yenidən açılır (`TourController.replay`).
- Köməkçi `lib/core/widgets/mascot`-dadır: `Mascot` (widget), `MascotBehavior` (hərəkət: `TalkingMascot`, `IdleMascot`), `MascotPose` (bir anın vəziyyəti), `MascotPainter` (yalnız boyayır), `MascotStyle` (rəng və ölçülər). Yeni hərəkət = `MascotBehavior`-un yeni implementasiyası, boyama kodu dəyişmir; görünüş = yalnız `MascotStyle`.
- Köməkçi sonsuz animasiyadır (ümumi qaydadan yeganə istisna). Testlər üçün: `mascotMotionProvider` defoltda false-dur, `main.dart` true edir; `InMemorySettingsRepository` defoltda `tourSeen: true`-dur; tur testlərində `pumpAndSettle` yox, `pump` işlədilir.

## Köməkçinin məşqdəki sözləri
- "Bugünkü məşq"-də (`QuizKind.daily`) ardıcıl düz cavablara görə köməkçi (mascot) ekranın yuxarısından hoppanıb balonda söz deyir, ~3.8 san sonra çəkilir (toxunanda dərhal): `CheerOverlay`. Digər məşq növləri (mövzu, səhvlər dəftəri, Mövzular bölməsi) HƏLƏ səssizdir, sahib sonra əlavə etməyi istədi.
- Qayda (`lib/features/quiz/domain/cheer_policy.dart`, testi `cheer_policy_test.dart`): 3 → `three`, 5 → `five`, 10/15/20/25... → `big` (≥20 `cheerLegend`); ən azı 5 düzdən sonra bir səhv → `comeback` (ruhlandırır). **Ardıcıl səhvlərə heç vaxt heç nə deyilmir** (ikinci səhvdə qırılan seriya qalmır).
- Mətnlər `AppStrings.cheer*` siyahılarındadır (üç dildə, `{n}` = ardıcıl say, emoji ilə); `cheerText` ümumi sözlərə fənnə aid olanları qarışdırır (`cheerKimya`, `cheerBiologiya`; kimyada səhvdən sonra `cheerKimyaComeback` "tövsiyə olunan müəllimlərə bax" deyir). Söz seçimi `cheerRandomProvider` ilə (testdə sabit). Zaman cədvəli bir AnimationController-dədir (Timer yoxdur).
- Sahib "kimya müəlliminin nömrəsini bizə paylaş" ideyasını da dedi: BİLƏREKDƏN əlavə edilmədi (müəllimin razılığı olmadan nömrə toplamaq olmaz; razılıq formu `teachers` bölməsindədir). Əvəzində kimya sözü mövcud "Tövsiyə olunan müəllimlər" menyusuna yönəldir.

## Android imza açarı
- Release build-lər `android/app/prepaz-release.jks` (alias `prepaz`) ilə imzalanır; şifrə `android/key.properties`-dədir. Hər ikisi gitignore-dadır, şifrə repoya yazılmır.
- Sertifikat SHA-256: `bca577b1454d2dfdb1afa03a544347606cd7ef7e500b9c5803c3f715b1810a3a`. Bu açar itsə, tətbiqi eyni imza ilə yeniləmək mümkün olmur; ehtiyat nüsxə saxlanmalıdır.
- `key.properties` yoxdursa, release build xəta ilə dayanır (debug açarına səssiz keçmir). Başqa kompüterdən build üçün bu iki fayl ora köçürülməlidir.
- Yığma: `flutter build apk --release --dart-define-from-file=env/test.json` (test), real baza qurulandan sonra `env/prod.json`.

## İstifadə şərtləri və məxfilik
- `lib/features/legal`: razılıq YALNIZ qeydiyyat formasının altındadır (`SignUpConsent`, qutu işarələnmədən "Hesab yarat" işləmir). Girişdə yoxdur, ayrıca ekran yoxdur (sahibin qərarı). Mətnlər `data/legal_texts.dart`-da üç dildədir; yan menyuda "Şərtlər və məxfilik".
- Qeydiyyatda versiya telefonda gözləyir (`AppSettings.pendingLegalVersion`), `LegalAcceptanceRecorder` daxil olanda onu `legal_acceptances`-ə yazıb təmizləyir (`db/migrations/011_legal_acceptances.sql`, lokal test: `tools/dim/test_migration_011.py`). Yazılmasa, heç nə bloklanmır, növbəti açılışda təkrarlanır.
- Mətn mahiyyətcə dəyişəndə `currentLegalVersion` və `AppStrings.legalLastUpdated` birlikdə dəyişir. Mövcud istifadəçilərdən razılıq soruşulmur.
- Sahibin qərarları: tətbiq sahibi Ayxan Həsənzadə (fiziki şəxs), ödəniş gələcəkdə ola bilər, şərtlərdə sualların mənbəyi barədə heç nə yazılmır (test bunu yoxlayır). Əlaqə kanalı hələlik "Tətbiqdə xəta bildir"-dir.
- Mətnə hüquqşünas baxmayıb.

## Hesabı silmək
- `db/migrations/012_delete_account.sql`: `delete_my_account()` RPC (`security definer`), istifadəçi məlumatları `auth.users`-dən kaskadla silinir. Admin hesabı rədd olunur (`admin_account`). Lokal test: `tools/dim/test_migration_012.py`.
- Tətbiq: yan menyuda "Hesabı sil" → `showDeleteAccountDialog` → `AuthRepository.deleteAccount()`. Play Store veb silmə linki də istəyir, o hələ yoxdur.

## Mövzular və Tədris
- Mövzular = şagirdin özünün seçib başdan sona işlədiyi yer (`lib/features/browse`: `TopicExamController`, `TopicQuestionsScreen`, `TopicResultView`). Bütün testlər işlənir, düz/səhv gedişdə GÖSTƏRİLMİR, nəticə sonda: hər test üçün ✓/✗, doğru cavab, izah, irəliləyiş. Cavablar "Bitir"-də bazaya yazılır (5-5), göndərilə bilməyənlər qaralamada qalır.
- Yarıda çıxanda cavablar telefonda saxlanır (`TopicDraftRepository`, SharedPreferences, hər istifadəçi üçün ayrıca) və şagird qaldığı yerdən davam edir ("Bitir" istənilən vaxt mümkündür). Bitmiş mövzu "Yenidən başla" ilə təkrar işlənir, son cavab həlledicidir.
- Cavabsız buraxılan test səhv sayılmır: sonda ona qayıdılır.
- Mövzu izahı Mövzular-da OLMAYACAQ. Ayrıca "Tədris" bölməsi olacaq (hələ yazılmayıb): bütün kimya mövzuları, şagird dərs oxuyur. Mətn dərslikdən köçürülmür, öz sözlərimizlə yazılır.

## Oflayn rejim (Mərhələ 4, `lib/features/offline`)
Sahibin qərarları: şagirdlər əsasən YOLDA (avtobus/metro) istifadə edir; yükləmə DÜYMƏ ilə (avtomatik yox, çünki trafik və şəkillər ağırdır); yükləmə vahidi MÖVZUdur (fənn → bölmə → mövzu, məs. Kimya → Kimyanın əsas anlayışları ≈ 100 test, 3 MB).
- **Hazırdır (2026-11-03):** server kataloqu (`db/migrations/016_download_catalog.sql`, `get_download_catalog`, test və real Supabase-də SQL Editor-da işlədilməlidir; test-də işlədilib), telefon bazası (drift, `LocalDatabase`, sxema v2, `prepaz.sqlite`), yükləmə xidməti (`TopicDownloader`: davam edir, dayandırılır, yenilənmədə yalnız yeni şəkillər, silmədə yalnız ortaq olmayan şəkillər), `OfflineBrowseRepository` (yüklənmiş mövzu HƏMİŞƏ telefondan oxunur), şəkil fayldan (`QuestionImage` + `localImagePathProvider`), cavab növbəsi (`AnswerOutbox`/`PendingAnswers`) və göndərmə (`AnswerSyncer`, tetiklər: `AnswerSyncGate` açılışda/arxa fondan qayıdanda, onlayn "Bitir"-dən sonra).
- **"Yüklə" ekranı (7-ci addım, 2026-11-03):** Mövzular ekranının yuxarı sağındakı düymə → `DownloadScreen` (fənn → bölmə → mövzu, ölçü, vəziyyət: yüklənməyib / yüklənir / yarımçıq / yeniləmə var / yükləndi; yüklə, davam et, yenilə, dayandır, telefondan sil, "Hamısını yüklə" təsdiqlə və ümumi ölçü ilə). Yükləmə `DownloadsController`-dədir (tətbiq boyu yaşayır: ekrandan çıxanda dayanmır; xəta mətni qalır, "Yenidən cəhd et"). İnternet yoxdursa, yalnız yüklənmiş mövzular göstərilir. Yüklənmiş mövzu siyahıda `download_done` işarəsi daşıyır. Dayandırma yalnız 4 şəkillik partiyalar arasında işləyir.
- **Görünüş (istifadəçi nə etdiyini anlasın):** ad "İnternetsiz həll et" (yalnız "Yüklə" aydın deyildi). Mövzular siyahısının başında fənn rəngində gradient `OfflineHintCard` (heç nə yüklənməyibsə və kataloq alınıbsa; ilk yükləmədən sonra yox olur); hər mövzunun yanında `TopicDownloadChip` (ölçü düyməsi `⬇ 3.0 MB` → dairəvi irəliləyiş, toxunanda dayanır → yaşıl `✓ Telefonda`; `Yenilə`, `Davam et`, xəta olanda `Yenidən cəhd et`). Yükləmə ekranında gradient `_Hero` (telefonda N mövzu · X MB), bölmə başlığında rəng zolağı, hər mövzuda vəziyyət dairəsi. Düymələr siyahıdadır, ayrıca ekrana getmək lazım deyil. **Ana ekranda** da giriş var: hər fənn kartının altında gradient `OfflineEntryTile` ("İnternetsiz həll et" + "Mövzuları yüklə" və ya "Telefonda: 3 mövzu · 9 MB") → `DownloadScreen`. Öyrədici tura bu sətir üçün addım HƏLƏ əlavə edilməyib (`TourStep`).
- **İnternet olmayanda (sahibin qərarı, 2026-11-03):** ayrıca "Yüklədiyin suallar" bölməsi. Ana ekranın başında `OfflineHomeBanner`: "Hazırda oflayn rejimdəsən" + "Yüklədiyin suallara keç" düyməsi (heç nə yüklənməyibsə yalnız izah, düymə yox) → `DownloadedSubjectsScreen` (yalnız tam yüklənmiş mövzusu olan fənlərin adları) → `DownloadedTopicsScreen` (həmin fənnin yüklənmiş mövzuları) → `TopicQuestionsScreen`. Solğun düymə, "internet lazımdır" mesajı və s. QƏSDƏN YOXDUR (sahib istəmədi: sadə olsun). İnternet olmayanda fənn kartları ana ekranda ÜMUMİYYƏTLƏ göstərilmir (düymələri internetsiz işləmir), yalnız narıncı "Hazırda oflayn rejimdəsən" yeri qalır; orada "İnterneti yenidən yoxla" düyməsi var (ekran qısa olduğu üçün çəkib yeniləməyə güvənilmir; `ListView` yenə də `AlwaysScrollableScrollPhysics`-dir). "Oflayn" siqnalı `offlineModeProvider`-dir: `OfflineSubjectRepository` fənlər siyahısını serverdən ala bilməyib telefondakı surəti göstərəndə true olur, serverdən alınanda false (çəkib yeniləmə də bunu sıfırlayır). Fənlər siyahısı `LocalSubjects`-də (sxema v3) keşlənir: ana ekran internetsiz də açılır və yüklənmiş mövzuların fənn adı oradan götürülür. Seriya bloku oxunmasa gizlənir (xəta bloku yoxdur).
- Hələ yoxlanmayıb: tətbiqin internetsiz SOYUQ açılışı (Supabase sessiyası telefonda qalır, amma token yenilənməsi alınmayanda davranış real telefonda yoxlanmalıdır) və oflayn "Çıxış" düyməsi (`signOut` serverə müraciət edir).
- Telefonda real yoxlanmayıb (yalnız fake server + yaddaşdakı baza ilə testlər): real `get_download_catalog` çağırışı, Storage `download`, `LocalDatabase.open()`, `FileImageStore` yolu. İlk real sınaq: yüklə → təyyarə rejimi → həll et → internet qayıt → cavabların getdiyini yoxla.
- "Bugünkü məşq" və "Səhvlər dəftəri" oflayn deyil (`review_queue`/`get_daily_set` serverin hesablamasıdır; sonrakı mərhələ).
- Drift `watch()` istifadə olunmur (widget testlərində widget silinəndə gözləyən Timer qoyur): `DriftOfflineStore.watchTopics` öz dəyişiklik siqnalı ilə işləyir. `AnswerOutbox.watchCount` hələ drift `watch()`-dur: ekranda istifadə olunanda eyni yanaşmaya keçirilməlidir.
- **Oflayn "Bitir":** yalnız yüklənmiş mövzuda. Əvvəl onlayn cəhd olunur; alınmasa nəticə telefonda hesablanır (`AnswerChecker`), cavablar növbəyə yazılır, nəticə ekranında `resultSavedOffline` qeydi çıxır. Göndərmə: `session_id` YOXDUR (null), `client_id` (UUID) təkrar göndərməni təhlükəsiz edir (23505 → mövcud nəticə), `answered_at` əsl vaxtla (gələcək vaxt kəsilir). Seriya və təkrar növbəsi serverin `current_date`-i ilə, yəni göndərmə gününə yazılır.
- **`AnswerChecker` (Dart) = `check_answer` (SQL) surəti.** Qayda dəyişəndə HƏR İKİSİ və `test/fixtures/check_answer_cases.json` birlikdə dəyişir. Paritet: `test/features/quiz/answer_checker_test.dart` (Dart) + `tools/dim/test_check_answer_parity.py` (real PostgreSQL trigger, 46 hal). Server həmişə son qərarı verir.
- Şagirdin son cavabları yüklənmiş mövzuda telefonda keşlənir (`LocalLatestAnswers`), göndərilməmiş cavablar üstünə qoyulur: həll edilmiş test oflayn yenidən "həll edilməmiş" görünmür.
- Real bazada `answers.client_id` sütunu və adi istifadəçi üçün `answered_at` insert icazəsi olmalıdır (yeni tətbiq hər cavabda `client_id` göndərir: yoxdursa BÜTÜN cavablar yazılmır). Buraxılışdan əvvəl yoxlanmalıdır.
- Şəkillər telefonda `getApplicationSupportDirectory()/offline_images` qovluğundadır (cache yox). Əvvəl `compress_images.py` ilə WebP (aşağıda "Şəkillər WebP-dir").
