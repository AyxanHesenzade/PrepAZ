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
- [ ] Mərhələ 3: "Zəif yerlərim", səhvlər dəftəri, seriya
- [ ] Mərhələ 4: oflayn rejim (drift) + sinxronizasiya
- [ ] Mərhələ 5: taymerli sınaq imtahanı, bal hesablanması
- [ ] Mərhələ 6: veb admin panel (sual əlavə/redaktə)
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
- Baza qeydi: `topic_mastery` view-ı bütün istifadəçilərin sətirlərini saxlayır; tətbiq `user_id` ilə süzür, amma view `security_invoker` deyilsə, bu RLS səviyyəsində açıqdır.
