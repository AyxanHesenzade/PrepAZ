# PrepAZ — gələcək fikirlər

Burada sonrakı versiyalar üçün fikirlər saxlanılır. Əsas iş (sual bazası) bitməmiş bunlara başlanmır.
Hər fikir üçün: tarix, nə istənir, açıq suallar, qeydlər.

---

## 1. Müəllim və şagird: qruplar, ev tapşırığı, canlı nəticə
**Tarix:** 2026-11-03 · **Vəziyyət:** fikir (sual bazası tam bitəndən sonra)

### Nə istənir
- Qeydiyyat zamanı rol seçilir: **müəllim** və ya **şagird**.
- Müəllim **qrup** yaradır (məs. 1 müəllim, 5 şagird). Şagirdi nik-adı ilə tapıb qrupa əlavə edir.
- Müəllim qrupa tətbiqin içində **ev tapşırığı** verir (mövzu və ya seçilmiş testlər, son tarix).
- Müəllim nəticələri **canlı** görür: kim başlayıb, kim bitirib, neçə düz, hansı testdə səhv edilib.

### Açıq suallar və qərar lazım olan yerlər
1. **Müəllimin təsdiqi.** İstənilən adam özünü müəllim kimi qeyd edə bilər. Seçimlər: admin paneldən əl ilə təsdiq
   və ya mövcud `teachers` cədvəli ilə əlaqələndirmək (artıq razılıq forması var).
2. **Şagirdi qrupa necə əlavə etmək.** Nik-adla birbaşa əlavə etmək yad adamı da qrupa salmağa imkan verir.
   Daha təhlükəsiz: müəllim **dəvət kodu / link** paylaşır, şagird özü qoşulur, ya da nik-adla dəvət gedir və şagird **qəbul edir**.
3. **Məxfilik.** Şagirdlərin çoxu azyaşlıdır. Müəllim yalnız öz qrupundakı şagirdin nəticəsini görməlidir.
   Şagird qrupdan çıxa bilməlidir. Şərtlər və məxfilik mətninə yeni bölmə lazım olacaq.
4. **Nik-ad.** Hazırda `profiles`-da unikal nik-ad yoxdur. Əlavə olunmalıdır (unikal, dəyişdirilə bilən?).
5. **Ödəniş.** Bu funksiya müəllimlər üçün ödənişli ola bilər (gəlir modeli). Pulsuz limit: məs. 1 qrup, 5 şagird?
6. **Oflayn.** Ev tapşırığı yüklənmiş mövzu kimi oflayn həll oluna bilərmi? Cavablar `AnswerOutbox` ilə gedir.
   Onda müəllim nəticəni "canlı" yox, şagird internetə qoşulanda görür.

### Texniki eskiz (ilkin)
- Baza (yeni migration-lar):
  - `profiles.role` (`student` / `teacher`) və `profiles.nickname` (unikal).
  - `groups` (müəllim, ad, dəvət kodu), `group_members` (qrup, şagird, status: dəvət/üzv).
  - `assignments` (qrup, mövzu və ya test siyahısı, son tarix), `assignment_answers` və ya mövcud `answers`-ə `assignment_id`.
  - RLS: müəllim yalnız öz qruplarının üzvlərinin tapşırıq cavablarını görür, şagird yalnız özününkünü.
- Canlı nəticə: Supabase **Realtime** (`answers` cədvəlində dəyişikliklərə abunə). Pulsuz planda limitlər var, yoxlanmalıdır.
- Tətbiq: `lib/features/groups`, `lib/features/assignments`. Müəllim üçün ayrıca ana ekran.
- Bildiriş (push) lazımdır: yeni tapşırıq, son tarix yaxınlaşır, şagird bitirdi. Hazırda tətbiqdə push YOXDUR (FCM qurulmalıdır).
- Müəllim üçün veb versiya daha rahat ola bilər (nəticə cədvəlləri böyük ekranda). Admin panel (`PrepAzAdmin`) əsasında ayrıca "müəllim paneli" variantı düşünülə bilər.

### Əlavə fikirlər (2026-11-03, müzakirə)
**Müəllim üçün**
- **Qrupun zəif mövzuları:** bütün qrup üzrə `topic_progress` cəmlənir. Müəllim "qrupun 4/5-i bu mövzuda zəifdir" görür və dərsdə həmin mövzunu yenidən keçir.
- **Qrupda ən çox səhv edilən suallar:** sual kodu ilə siyahı (`KIM-0123`, `KT1-S01-Q030`). Müəllim həmin sualı dərsdə izah edir.
- **Şəxsi tapşırıq bir düymə ilə:** "hər şagirdə öz zəif mövzusunu ver". Hər kəs fərqli tapşırıq alır (`get_daily_set` məntiqi).
- **Qrup sınaq imtahanı:** Mərhələ 5 (taymerli sınaq) ilə birləşir. Hamı eyni vaxtda başlayır, sonda bal və sıralama göstərilir.
- **Aktivlik:** "3 gündür tətbiqə girməyib" siyahısı və şagirdə xatırlatma göndərmək.
- **Səhvə qeyd:** müəllim şagirdin konkret səhvinin altına qısa izah yazır.

**Valideyn üçün**
- **Həftəlik hesabat:** neçə test həll edib, faiz, zəif mövzular, seriya. Valideynə link kimi göndərilir. Müəllim üçün güclü satış aləti olur (valideyn nəticəni görür).

**Şagird üçün**
- **Qrup reytinqi (həftəlik):** motivasiya verir. Ehtiyat: zəif şagirdi ruhdan sala bilər. Müəllim bunu söndürə bilməlidir, şagird adını gizlədə bilməlidir.
- **Qrup məqsədi:** "bu həftə qrup birlikdə 500 test həll etsin" (seriyanın qrup versiyası).
- **Müəllimə sual ver:** sual ekranındakı `QuestionCodeLabel` yanında "Müəllimdən soruş" düyməsi. Sual kodu ilə birlikdə gedir.
- **Köməkçi ilə əlaqə:** tapşırıq bitəndə köməkçi müəllimin adını çəkir ("Müəllimin nəticəni görəcək!").

**Biznes**
- **Kurs mərkəzləri:** bir mərkəzdə bir neçə müəllim və çoxlu qrup olur. Bu, təşkilat səviyyəsində ödənişli plandır.
- **Tövsiyə olunan müəllimlərlə əlaqə:** şagird müəllimin kartından "qrupuna qoşulmaq istəyirəm" sorğusu göndərir.
- Müəllimin öz suallarını yalnız öz qrupu üçün əlavə etməsi: faydalıdır, amma mənbə/hüquq məsələsi var (`source` məcburi qalır).

**Təklif olunan ilk versiya (v1):** rol + təsdiq, dəvət kodu ilə qrup, tapşırıq (mövzu + son tarix), nəticə cədvəli,
qrupun zəif mövzuları. Qalanları (reytinq, valideyn hesabatı, push, qrup imtahanı) sonrakı addımlarda.

---

## 2. Duel: iki şagird eyni suallarda yarışır
**Tarix:** 2026-11-03 · **Vəziyyət:** fikir (sual bazası tam bitəndən sonra)

### Nə istənir
- İki şagird telefonlarını birləşdirir (Bluetooth və ya internet), ikisi də eyni sualları eyni vaxtda görür.
- Hər sual üçün vaxt var. Sonda kimin qalib gəldiyi göstərilir (düz cavab sayı, bərabərlikdə ümumi vaxt).

### Mümkündürmü?
Bəli. İki yol var:

**A) İnternetlə (tövsiyə: birinci bu)**
- Supabase **Realtime** (broadcast + presence) ilə qurulur. Ayrıca server lazım deyil.
- Şagird duel otağı yaradır, ekranda **4 rəqəmli kod / QR** çıxır, dostu kodu yazır və ya QR-ı oxudur.
- Android ↔ iPhone problemsiz işləyir, iki şagird fərqli şəhərlərdə də ola bilər.
- Gələcəkdə buradan "təsadüfi rəqib tap" funksiyası da çıxa bilər.

**B) Bluetooth ilə (internetsiz, metroda)**
- Suallar artıq telefonda ola bilər (oflayn rejim: yüklənmiş mövzu). Telefonlar arasında yalnız kiçik mesajlar gedir:
  sual ID-ləri, cavab, vaxt. Şəkil göndərmək lazım deyil.
- Tətbiq uzun müddət yalnız Android üçündür (sahibin qərarı, 2026-11-03), ona görə Android ↔ iPhone problemi indi aktual deyil.
  Android-də Google **Nearby Connections** işlədilir (məs. `nearby_connections` paketi; o vaxt yenidən yoxlanmalıdır).
  Bluetooth + Wi-Fi Direct-i özü seçir, internet lazım deyil. iPhone gələndə bu yol onunla işləməyəcək (Apple Multipeer ayrıdır).
- Hər iki telefonda EYNİ mövzu yüklənmiş olmalıdır (eyni versiyada). Yoxdursa, duel başlamır.

### Nələr lazımdır
1. **Duel qaydaları:** sual sayı (məs. 10), sual başına vaxt (məs. 30 san), mövzu seçimi, bal (düz cavab + sürət bonusu?).
2. **Sualları seçmək:** otağı yaradan telefon sualları seçir və ID siyahısını göndərir. Hər iki tərəfdə eyni ardıcıllıq olur.
3. **Ədalət:** taymer hər iki telefonda eyni anda başlamalıdır ("3-2-1" geri sayımı). Cavab vaxtı telefonun öz saatı ilə ölçülür.
4. **Cavab yoxlaması:** internetlə duel → server (`check_answer`). Bluetooth duel → telefonda `AnswerChecker`,
   cavablar sonra `AnswerOutbox` ilə serverə gedir (seriya və statistikaya yazılır).
5. **Qopma halları:** rəqib çıxdı / əlaqə kəsildi → qalan suallar tək davam edir və ya duel ləğv olunur.
6. **Hile:** iki tərəf eyni telefonda deyil, amma başqa telefonda cavab axtarmaq olar. Qısa taymer bunu çətinləşdirir.
7. **Nəticə ekranı:** kim qalib gəlib, hər sual üzrə müqayisə, doğru cavab və izah. Köməkçi qalibi təbrik edir.
8. **Baza:** `duels` (iştirakçılar, suallar, nəticə). Duel tarixçəsi və dostla hesab ("Səbinə ilə 3:2") istəyə görə.
9. **İcazələr:** Bluetooth variantında Bluetooth və yaxındakı cihazlar icazəsi (Android 12+), köhnə Android-lərdə yer (location) icazəsi.

### Qrup funksiyası ilə əlaqə
- Müəllim qrupunda duel: qrup içində turnir, müəllim nəticələri görür.

**Təklif:** tətbiq yalnız Android olduğu üçün Bluetooth (Nearby) variantı ilk versiya ola bilər: şagirdlər yanaşı oturur,
internet lazım deyil, oflayn rejimlə yaxşı uyğunlaşır. İnternetlə duel (kod/QR, uzaqdan) ikinci addım.
İkisi eyni duel məntiqini işlədir, yalnız "mesaj kanalı" fərqlidir (`DuelChannel` interfeysi: Nearby və ya Realtime).

---

## 3. Üç ayrı tətbiq: PrepAZ İbtidai, PrepAZ 5–9, PrepAZ Abituriyent
**Tarix:** 2026-11-03 · **Vəziyyət:** fikir (müzakirə olunub, qərar verilməyib)

### Nə istənir
- Yaşa görə ayrı tətbiqlər: **İbtidai** (1–4), **5–9**, **Abituriyent** (indiki PrepAZ).

### Lehinə
- Hər yaş üçün öz dizaynı olur. İbtidai uşaq üçün böyük düymələr, şəkillər, səs, oyun lazımdır. Abituriyent üçün isə ciddi və sürətli tətbiq.
- Play Store-da ayrıca səhifə olur: axtarışda daha yaxşı tapılır, reklam dəqiq auditoriyaya yönəlir.
- **Uşaq qaydaları:** 13 yaşdan kiçiklər üçün tətbiq Google Play **Families** siyasətinə tabedir (reklam, məlumat toplama,
  giriş üsulları, valideyn razılığı üzrə sərt tələblər). İbtidai ayrıca olsa, bu tələblər yalnız ona aid olur, Abituriyent sərbəst qalır.
  Bu, ayrı tətbiq üçün ən güclü səbəbdir.

### Əleyhinə / risklər
- 3 tətbiq = 3 buraxılış, 3 Play Store səhifəsi, 3 dəfə yoxlama. Bunu yüngülləşdirmək üçün: **bir kod bazası, Flutter flavor-ları**
  (`az.prepaz.ibtidai`, `az.prepaz.orta`, `az.prepaz`), ortaq `core/` və `features/`, hər flavor-un öz teması, fənləri və mətnləri.
- **Bir Supabase, bir hesab:** şagird 9-cu sinifdən Abituriyentə keçəndə hesabı, seriyası, tarixçəsi itməməlidir.
  `subjects` / mövzular sinif səviyyəsi ilə işarələnir (`grade_level`), hər tətbiq yalnız özününkünü göstərir.
- **Ən böyük iş məzmundur.** Buraxılış/qəbul üçün DİM materialları var. İbtidai və 5–9 üçün mənbə yoxdur:
  dərsliklərdən köçürməyə razılıq YOXDUR. Suallar ya özümüz yazmalıyıq, ya da müəllimlər/nəşriyyatlarla razılaşma lazımdır.
- **Sərhəd aydın olmalıdır:** 9-cu sinif buraxılış imtahanı hansı tətbiqdədir? 10–11-ci sinif harada? Təklif: 5–9 = sinif
  materialı + 9-cu sinif buraxılışı; Abituriyent = 10–11 + 11-ci sinif buraxılışı + qəbul.
- İbtidai şagird tətbiqi əsasən valideyn telefonundan istifadə edir: valideyn hesabı / valideyn nəzarəti lazımdır.

### Ardıcıllıq təklifi
1. Abituriyent (indiki PrepAZ) tam bitsin və Play Store-a çıxsın.
2. Kod flavor-lara hazırlansın (rənglər, fənlər, mətnlər konfiqurasiyadan gəlsin), baza `grade_level` alsın.
3. Sonra **5–9** (dizayn Abituriyentə yaxındır, iş azdır). İbtidai ən sonda (dizayn, səs və Families qaydaları tamamilə ayrı iş tələb edir).
- Qeyd: `applicationId` Play Store-a çıxandan sonra dəyişmir. İndiki `az.prepaz` Abituriyent olaraq qalır.

---

## 4. Mövzular-da yalnız kitab sualları
**Tarix:** 2026-11-03 · **Vəziyyət:** qərar verilib (variant A), sonra edilir

- Mövzular bölməsində yalnız kitab sualları (`KT...`) görünsün. DİM imtahan sualları (`KIM-`, `BIO-`) orada olmasın,
  digər bölmələrdə (Bugünkü məşq, Zəif yerlərim, Səhvlər dəftəri) qalsın.
- Tövsiyə: koda görə yox, `questions`-da ayrıca işarə (məs. `kitab` / `imtahan`), migration köhnələri `KT%` ilə işarələyir.
- Dəyişən yerlər: Mövzular siyahısı və testləri, oflayn yükləmə (`get_download_catalog`, ölçü/say), mövzu irəliləyişi (`topic_progress`).
- Açıq suallar: (1) ana ekrandakı zəif mövzular da `topic_progress`-dən oxunur: bütün suallarla qalsın, yoxsa yalnız kitab?
  (2) biologiyada kitab sualı yoxdur: Mövzular boş qalsın, yoxsa kitab yoxdursa DİM sualları görünsün?
