# Tapşırıq 02: Kimya suallarını bazaya yükləmək və tətbiqdə göstərmək

> Kodu sən yazırsan. Əvvəlcə `CLAUDE.md`-ni və Tapşırıq 01-in nəticəsini (`tools/dim/out/kimya_dim_yoxlama.xlsx`) oxu.
> Qeyri-müəyyən bir şey çıxarsa, təxmin etmə: dayan və sahibdən soruş.

## Məqsəd

Tətbiqdə **real kimya sualları** ilə başdan sona işləyən məşq olsun: sual, şəkil, cavab, izah və zəif mövzular.

## Sahibin qəbul etdiyi qərarlar

1. **Mərhələli yükləmə.** Əvvəlcə 37 təmiz sual, müəllim yoxlayandan sonra yüklənir. Qalan suallar müəllim düzəltdikcə yüklənəcək.
2. **İlk versiyaya yalnız `qapali` və `aciq_eded` tipli suallar** daxildir. 18 `yazili` və situasiya tapşırığı hələlik **yüklənmir**. Excel-də qalır, amma import onları buraxır.
3. **Mövzular vahid siyahıya salınır.** Mövzu adlarına son qərarı sahib verir, çünki o, kimyaçıdır.
4. **Şəkillər tətbiqdə göstərilir.** Kimya üçün bu, vacib funksiyadır.
5. **Sinif sütunu** Excel-də qalır, bazaya hələlik yazılmır.

## Addımlar (bu ardıcıllıqla). ⏸ işarəsi olan yerdə dayan və sahibin cavabını gözlə.

### Addım 1: Supabase-də real vəziyyəti yoxla ⏸

Bazanın cari vəziyyəti dəqiq bilinmir. Sahib bunları işə salıb:
- `CLAUDE.md` Əlavə A-dakı schema;
- bəlkə 001 migration (fingerprint sütunu);
- kimya üçün ayrıca bir query. Bu query `subjects` cədvəlinə `is_active` sütunu əlavə edib, yalnız kimyanı aktiv edib və `"read subjects"` siyasətini `using (is_active)` olaraq dəyişib.

**Sahibə Supabase SQL Editor-da işə salmaq üçün bir yoxlama query-si ver.** O query bunları göstərməlidir:
- `questions` və `subjects` cədvəllərinin sütunları;
- `subjects` cədvəlinin məzmunu;
- `get_daily_set` funksiyasının mətni;
- `topics` cədvəlinin məzmunu.

Nəticəyə görə nəyin çatışmadığını müəyyən et. Lazım olsa, `db/migrations/002_...sql` yaz. Bu fayl:
- lokal test edilməlidir;
- təkrar işə salınanda zərərsiz olmalıdır;
- `subjects.is_active`-i **saxlamalıdır**, yox etməməlidir.

Migration-ı sahib özü işə salır.

### Addım 2: Mövzu siyahısı təklifi ⏸

- DİM-in kimya qəbul proqramına və PDF-lərdəki mövzu adlarına əsasən **vahid mövzu siyahısı** hazırla. Lazım olsa, iki səviyyəli ola bilər: bölmə → mövzu.
- **"Köhnə ad → yeni ad"** cədvəli hazırla: 120 sualda rast gəlinən hər fərqli mövzu adı üçün bir sətir.
- Bunu sahibə **oxunaqlı formada** göstər və təsdiq gözlə. Sahib düzəliş edə bilər.
- Təsdiqdən sonra Excel faylında mövzuları yenilə. Köhnə adı ayrıca `DİM mövzusu` sütununda saxla.

### Addım 3: Müəllim üçün yoxlama faylı

Excel-də ayrıca **"Müəllim 1-ci dəst"** vərəqi və ya ayrıca fayl hazırla. Orada `yoxlanmalı` işarəsi olmayan, tipi `qapali` və ya `aciq_eded` olan sualların hamısı olsun (təxminən 37).

Müəllim hər sual üçün bunları edəcək:
- düzgünlüyü yoxlayır;
- **çətinlik** sütununu (1–5) doldurur;
- `aktiv = bəli` yazır.

Vərəqin yuxarısında müəllim üçün qısa təlimat olsun, Azərbaycan dilində 3–4 cümlə.

Faylı hazırlayıb sahibə ver. **Müəllim cavab verənə qədər 4-cü və 5-ci addımlara keçə bilərsən, amma heç nə yükləmə.**

### Addım 4: Import skripti

Skript Excel faylını oxuyur və bazaya yükləyir. Bazanın **real** sütunlarına görə yaz (addım 1-in nəticəsi).

**Tələblər:**
- Yalnız `aktiv = bəli`, tipi `qapali` və ya `aciq_eded` olan və çətinliyi doldurulmuş sətirləri yükləyir. Qalanlarını buraxır və **nə üçün buraxdığını** hesabatda sayı ilə göstərir.
- **Əvvəl hamısını yoxlayır.** Ən azı bir xəta varsa, heç nə yükləmir. Xətaları sətir nömrəsi ilə göstərir.
- Mövzular yoxdursa, yaradır, varsa, təkrar yaratmır.
- Suallar `code`-a görə yazılır: varsa, yenilənir, yoxdursa, əlavə olunur. Yəni skripti təkrar işə salmaq dublikat yaratmır.
- `source = 'DİM'`, `source_ref` isə Excel-dəki `mənbədə yeri` sütunundan götürülür.
- Əvvəl lokal PostgreSQL-də test et: Supabase stub + schema + migration-lar + import → sonra `get_daily_set` kimya suallarını qaytarmalıdır.
- **Bağlantı:** Supabase-ə yazmaq üçün `service_role` açarı və ya baza parolu lazımdır. Bunu **repoya yazma**. Sahibdən soruş və yalnız mühit dəyişəni (environment variable) kimi istifadə et. Alternativ yol: skript SQL faylı yaradır, sahib onu SQL Editor-da özü işə salır. Hansı yolu seçəcəyini sahibdən soruş.

### Addım 5: Şəkillər

**Supabase Storage:**
- `question-images` adlı bucket lazımdır. Daxil olmuş istifadəçilər **oxuya** bilər, yalnız admin yaza bilər.
- Bucket-i və onun qaydalarını yaratmaq üçün sahibə addım-addım göstəriş ver: harada nəyə basmaq lazımdır və ya hansı SQL-i işə salmaq lazımdır.
- Şəkilləri yükləyən skript yaz: yalnız bazaya yüklənən sualların şəkillərini yükləsin, `questions.image_path`-ə Storage yolunu yazsın, artıq yüklənmiş şəkli təkrar yükləməsin.

**Tətbiq (`app/`):**
- Sual ekranında sual mətninin **altında** şəkil göstərilir (`image_path` varsa).
- Şəkil ekran enini tutur. Üzərinə toxunanda böyüdülə bilir (zoom).
- Yüklənərkən yer tutucu göstərilir. Şəkil yüklənməsə, "Şəkil yüklənmədi" yazılır, amma sual həll oluna bilir.
- Şəkil Supabase Storage-dən **imzalı link** (signed URL) ilə və ya bucket qaydasına uyğun yolla alınır. Bütün Storage çağırışları `repository.dart`-da olur.
- Nəticə ekranında, səhv sualların siyahısında da şəkil varsa, kiçik ölçüdə göstərilir.

### Addım 6: Başdan sona yoxlama

Müəllimin təsdiqlədiyi suallar yükləndikdən sonra tətbiqdə bu ssenarini keç:
1. Ana səhifədə yalnız **Kimya** görünür.
2. "Bugünkü məşqə başla" basılır və kimya sualları gəlir.
3. Formullar düzgün görünür: indekslər, yüklər, oxlar.
4. Şəkilli sual: şəkil görünür və böyüdülür.
5. Bir sualı düz, birini səhv cavabla. İzah görünür.
6. Nəticə ekranı açılır.
7. Ana səhifədə zəif mövzular **vahid mövzu adları** ilə görünür.

Ekran görüntüləri çək: hər biri üçün bir şəkil, ümumi 5–7 ədəd.

## Etməməli olduqların

- Müəllimin təsdiqləmədiyi sualı bazaya yükləmə.
- Sual mətnini, cavabı və izahı dəyişmə. Yalnız mövzu adı dəyişir, sahibin təsdiqi ilə.
- `service_role` açarını, baza parolunu və ya digər sirri repoya, koda və ya hesabata yazma.
- Supabase-də sahibin xəbəri olmadan heç nə işə salma.

## Hesabat (sahibə, Azərbaycan dilində, qısa)

1. Addım 1: bazada nə tapıldı, migration lazım oldumu.
2. Təsdiqlənmiş mövzu siyahısı (neçə mövzu).
3. Neçə sual yükləndi, neçəsi hansı səbəbdən buraxıldı.
4. Neçə şəkil yükləndi.
5. Ssenarinin nəticəsi və ekran görüntüləri.
6. Problemlər və növbəti addım təklifi.
