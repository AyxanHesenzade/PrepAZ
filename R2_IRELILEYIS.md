# Şəkillərin Cloudflare R2-yə köçürülməsi: harada qaldıq

Son yenilənmə: 2026-11-19. Bu işə qayıdanda əvvəl bu faylı oxu, hər addımdan sonra yenilə.

## Niyə
Supabase pulsuz planında aylıq trafik 5 GB-dır, şəkillər (və oflayn yükləmə) onu tez yeyir.
R2: 10 GB pulsuz yaddaş, trafik (egress) HƏMİŞƏ pulsuz. Baza və giriş Supabase-də qalır, yalnız şəkillər köçür.
Sahibin qərarı: R2 bucket AÇIQ ola bilər. İstifadəçi çoxalanda pullu / gizli serverə keçiləcək (kod buna hazırdır).

## Açıq məlumatlar (sirr DEYİL)
| Nə | Dəyər |
|---|---|
| Cloudflare hesabı | layihənin support Gmail-i ilə açılıb |
| Bucket (test) | `prepaz-images-test` (Standard, Eastern Europe) |
| Açıq link (test) | `https://pub-c4883393819844a5a30575d3a4ef7ccc.r2.dev` |
| API token adı | `prepaz-upload-test` (Object Read & Write, yalnız bu bucket) |
| Bucket (real) | `prepaz-images-prod`: hələ yaradılmayıb (real Supabase ilə birlikdə) |

**Gizli açarlar (Access Key ID, Secret Access Key, Supabase service key) bu faylda YOXDUR və heç vaxt repoya yazılmır.**
Onlar sahibdədir (parol meneceri). Lazım olanda yalnız terminalda mühit dəyişəni kimi verilir.

## Addımlar
- [x] Tətbiq: şəkil mənbəyi zənciri **keş → R2 → Supabase** (`lib/features/quiz/presentation/quiz_providers.dart`), disk keşi 7 gün, testlər keçir.
- [x] `IMAGE_BASE_URL` parametri (`env/test.json`, `DebugDefaults.imageBaseUrl`): **hələ BOŞDUR** (bucket boşdur; dolu olsa hər şəkil əvvəl R2-də tapılmayıb gecikərdi).
- [x] Köçürmə skripti: `tools/dim/common/upload_r2.py` (oflayn test: `test_upload_r2.py`). Heç nə silmir, R2-də olanı atlayır.
- [x] Cloudflare hesabı, R2 aktiv ($0), bucket `prepaz-images-test`, açıq r2.dev linki, API token.
- [ ] **NÖVBƏTİ: quru yoxlama.** Sahib öz terminalında (PowerShell):
  ```powershell
  pip install boto3
  $env:R2_ACCOUNT_ID = "..."          # R2 Overview → Account Details → Account ID
  $env:R2_ACCESS_KEY_ID = "..."
  $env:R2_SECRET_ACCESS_KEY = "..."
  $env:SUPABASE_URL = "https://ehaqunuwkccwosaorvgy.supabase.co"
  $env:SUPABASE_SERVICE_KEY = "..."   # Supabase → Project Settings → API Keys
  cd tools\dim\common
  python upload_r2.py --from-supabase --dry-run
  ```
  Çıxışdakı "Mənbə ... · R2 ... · yüklənməli: N" sətri Claude-a göndərilir (açar görünmür).
- [ ] Real köçürmə: `python upload_r2.py --from-supabase`, sonra `python upload_r2.py --check` (0 çatışmayan).
- [ ] Brauzerdə yoxla: `https://pub-c4883393819844a5a30575d3a4ef7ccc.r2.dev/<bir şəkil adı>.webp` açılır.
- [ ] Linki yaz: `env/test.json` → `IMAGE_BASE_URL` və `DebugDefaults.imageBaseUrl` (test ikisinin eyni olmasını yoxlayır).
- [ ] Telefonda yoxla: sual şəkli açılır, oflayn yükləmə işləyir; admin panel Loglar-da `image_fallback` çıxmır.
- [ ] Yeni şəkil axını: `import_scans.py` / `upload_images.py`-dən sonra `python upload_r2.py --folder out/upload_kitab` (bir müddət hər iki yerə yüklənir).

## Sonra (R2-yə tam keçəndə)
- `get_download_catalog` (migration 016) şəkil ölçüsünü `storage.objects`-dən oxuyur: Supabase-dəki şəkillər silinsə, ölçü 0 göstərilər. Yeni migration lazımdır (ölçünü ayrıca cədvəldə saxlamaq). Ona qədər Supabase-dəki şəkilləri SİLMƏ.
- Admin panel (`PrepAzAdmin`) şəkli hələ Supabase-ə yükləyir: R2-yə yükləmə Vercel funksiyası ilə (açar brauzerə düşməz).
- Real buraxılış: `prepaz-images-prod` bucket + öz domen (məs. `img.prepaz.az`; r2.dev sürəti məhduddur, test üçündür), `env/prod.json` → `IMAGE_BASE_URL`.
- Pul xəbərdarlığı: R2 Overview → Billing → Add Budget Alert ($1), edilibmi yoxla.
