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
- Yeni feature: `domain` interfeys → `data` implementasiya → provider → ekran → test.

## Bazanın məntiqi (tətbiq bunları təkrar yazmamalıdır)
- `auth.users`-ə qeydiyyat → `profiles` avtomatik yaranır.
- `answers`-ə insert → `is_correct` SERVERDƏ hesablanır (tətbiqin göndərdiyi dəyər nəzərə alınmır).
- Səhv cavab → `review_queue` (1 → 3 → 7 → 14 gün); 4 ardıcıl düz → növbədən çıxır.
- `profiles.streak_days` avtomatik; istifadəçi dəyişə bilməz.
- `topic_mastery` view — mövzu üzrə son 30 cavabın faizi.
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
- [ ] Mərhələ 4: oflayn rejim (drift) + sinxronizasiya
- [ ] Mərhələ 5: taymerli sınaq imtahanı, bal hesablanması
- [~] Mərhələ 6: veb admin panel. v1 hazırdır (`PrepAzAdmin`), migration 005 işlədilməli. Növbəti: mövzu idarəsi
- [ ] Mərhələ 7: Play Store-a çıxış


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
- Cari versiya: **1.1.2**, build **7**. Mənbə: `assets/app.json`; `pubspec.yaml` → `version: 1.1.2+7` ilə eyni olmalıdır (`test/core/app_version_test.dart` uyğunsuzluğu tutur).
- Yeni buraxılışda hər ikisini birlikdə dəyiş. Ana ekranın altında "Versiya 1.1.2 (7)" göstərilir.

## Test Supabase-in cari vəziyyəti (2026-10-30)
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
- **Kitabda harada dayandığımız `KITAB_IRELILEYIS.md`-dədir.** Kitab işinə başlamazdan əvvəl onu oxu, hər bölmə bitəndə mütləq yenilə (bölmə cədvəli, "Qısa vəziyyət", tarix).
- Mənbə: sahibin əlindəki nəşriyyat/DİM test topluları (şəkil PDF). Yalnız sahibin verdiyi fayllar; internetdən qeyri-rəsmi PDF çəkilmir.
- `tools/dim/scan_segment.py KITAB.pdf --first N --last M --start 1 --stop 100 --out scan/<ad>`: RapidOCR yalnız sual nömrələrinin yerini tapır
  (ardıcıl artan nömrə qaydası), hər sual ayrıca təmizlənmiş şəkil kimi kəsilir (haşiyə silinir, ağ kağız, 2x böyütmə). Nümunədə 87/100 tapıldı;
  OCR bəzi sətirləri (səhifə yuxarısı, əyri sətirlər) oxumur. Tapılmayanlar hesabatda "missing" kimi görünür.
- Cavab açarı kitabın sonundan əl ilə JSON-a yazılır (`scan/kimya_I_bolme1_cavablar.json`). Uyğunlaşdırma tipli (A–E olmayan) suallar yüklənmir.
- `tools/dim/import_scans.py` → `out/import_kt1_s01.sql` + `out/upload_kitab/` (şəkillər koda görə adlanır). Kod: `KT<kitab>-S<bölmə>-Q<nömrə>`
  (məs. `KT1-S01-Q030`): problem bildirişində kod birbaşa kitabda yeri göstərir. Sual mətni BOŞDUR, variantlar yalnız hərfdir ("A".."E").
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

## Dizayn, dil və menyu (tətbiq)
- Tema: `lib/core/theme` (böyük yumru künclər `AppRadius`, pill düymələr, Plus Jakarta Sans şrifti `assets/fonts`, fənn rəngləri `AppColors.subjectAccent`).
  Ortaq animasiyalı elementlər: `Pressable`, `FadeSlideIn`, `SoftProgressBar` (`lib/core/widgets`). Sonsuz animasiya yazılmır (testlər `pumpAndSettle` işlədir).
- Tətbiq interfeys dili: AZ / RU / EN (sualların dili bundan asılı deyil). `AppStrings` getter-dir (`const` deyil!): hər mətn `_t(az, ru, en)` ilə yazılır,
  yeni mətn əlavə edəndə üç dili də yaz. Dil `AppStrings.language`-dədir, ayarlar onu dəyişir; `PrepAzApp` dil dəyişəndə ağacı təzədən qurur.
- Ayarlar (dil + gündüz/gecə/sistem): `features/settings`, SharedPreferences-də saxlanır (`main.dart` override edir; testdə `InMemorySettingsRepository`).
- Ana səhifədə yan menyu (`features/menu/app_drawer.dart`): Dil, Görünüş (basanda açılır), Tövsiyə olunan müəllimlər, Çıxış. Versiya yazısı ekranın altında sabitdir.
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
- Tətbiq: `lib/features/update` (`UpdateGate` `app.dart`-da `AuthGate`-i sarıyır). Versiya `assets/app.json`-dan (`1.1.2+7`) bazadakı ilə müqayisə olunur:
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

## Öyrədici tur
- `lib/features/tour`: hədəf seçimi bağlanan kimi (hədəf artıq varsa və ya oxunmursa, ana ekran açılanda) bir dəfə başlayır. Bayraq telefonda: `AppSettings.tourSeen` (`settings.tour_seen`, SharedPreferences), yalnız son addımda true olur; yarıda bağlansa, yenidən başlayır.
- Ardıcıllıq (`TourStep`): salam → menyu düyməsinə basmaq (burada "Anladım" yoxdur, işıqlı düyməyə basılır) → Dil, Görünüş, Müəllimlər, Xəta bildir, Çıxış → yan menyu bağlanır → birinci fənn kartı: Bugünkü məşq, Zəif yerlərim, Səhvlər dəftəri, Mövzular → son. Fənn yoxdursa, kart addımları atlanır. Tur atlanmır (sahibin istədiyi kimi yalnız "Anladım").
- Hədəf elementlər `TourTargets`-dəki GlobalKey-lərlə tapılır. Açarlar `HomeScreen`-in State-ində yaşayır və `TourScope` ilə ötürülür. Onları provider-ə və ya qlobal yerə qoyma: dil dəyişəndə `PrepAzApp` ağacı yenidən qurur, qlobal GlobalKey köhnə ekranı açıq yan menyu ilə köçürür və tətbiq donur. Yeni menyu elementi əlavə edəndə `TourStep`, `keyFor`, `_message` və üç dildə mətn də əlavə olunur.
- Ana ekranın başlığındakı balaca köməkçiyə (`HeaderMascot`) basanda tur bayraqdan asılı olmayaraq yenidən açılır (`TourController.replay`).
- Köməkçi `lib/core/widgets/mascot`-dadır: `Mascot` (widget), `MascotBehavior` (hərəkət: `TalkingMascot`, `IdleMascot`), `MascotPose` (bir anın vəziyyəti), `MascotPainter` (yalnız boyayır), `MascotStyle` (rəng və ölçülər). Yeni hərəkət = `MascotBehavior`-un yeni implementasiyası, boyama kodu dəyişmir; görünüş = yalnız `MascotStyle`.
- Köməkçi sonsuz animasiyadır (ümumi qaydadan yeganə istisna). Testlər üçün: `mascotMotionProvider` defoltda false-dur, `main.dart` true edir; `InMemorySettingsRepository` defoltda `tourSeen: true`-dur; tur testlərində `pumpAndSettle` yox, `pump` işlədilir.

## Android imza açarı
- Release build-lər `android/app/prepaz-release.jks` (alias `prepaz`) ilə imzalanır; şifrə `android/key.properties`-dədir. Hər ikisi gitignore-dadır, şifrə repoya yazılmır.
- Sertifikat SHA-256: `bca577b1454d2dfdb1afa03a544347606cd7ef7e500b9c5803c3f715b1810a3a`. Bu açar itsə, tətbiqi eyni imza ilə yeniləmək mümkün olmur; ehtiyat nüsxə saxlanmalıdır.
- `key.properties` yoxdursa, release build xəta ilə dayanır (debug açarına səssiz keçmir). Başqa kompüterdən build üçün bu iki fayl ora köçürülməlidir.
- Yığma: `flutter build apk --release --dart-define-from-file=env/test.json` (test), real baza qurulandan sonra `env/prod.json`.
