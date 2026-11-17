# PrepAZ — plan və fikirlər

Bütün gələcək planlar, fikirlər və açıq qərarlar YALNIZ bu fayldadır (köhnə `PLAN.md`, `PLAN_DUEL.md`, `IDEAS.md`, `FIKIRLER.md` buraya birləşdirilib, 2026-11-17).
Hazır olan işlərin texniki təfərrüatı `CLAUDE.md`-dədir; burada yalnız "nə edək, nə vaxt, niyə" var.

**İşarələr:** ✅ hazırdır · 🟢 qərar verilib, edilməyib · 💡 fikir (qərar yoxdur) · ⏸ sonraya saxlanılıb · ❌ rədd edilib · ❓ sahibin qərarı lazımdır
**İş həcmi:** S = 1–2 gün · M = bir həftəyə qədər · L = bir neçə həftə

---

## 0. Açıq suallar (əvvəl bunu oxu)

| # | Sual | Bölmə |
|---|---|---|
| 1 | Müəllim qrupları: sahib öz fikrini yazacaq | 5 |

## Qəbul edilmiş qərarlar (jurnal)

| Tarix | Qərar |
|---|---|
| 2026-11-17 | **Xal = XP.** Yeni funksiya yoxdur: Yarışın mövcud xalının adı "XP" olur. Təkrar düz cavab XP vermir (indiki qayda). Səviyyə, ayrıca XP sistemi yoxdur (3.1). |
| 2026-11-17 | **Duel ssenarisi** (4.2): Bluetooth məcburi, otaq + yaxındakı otaqlar, parolsuz; otağı yaradan fənn, sual sayı (məs. 30) və sual başına vaxt (30–300 san) seçir; **sualları server təsadüfi seçir**, çatışmayanlar başlanğıcda internetlə yüklənir və telefonda qalır; sual eyni anda açılır, birinci düz cavab verən udur, hər kəsə 1 cəhd, **pas keçmək yoxdur**; sonda çox sual udan qalibdir; düz cavablar adi qayda ilə XP verir; **dueldən çıxana 30–50 XP cəza**. |
| 2026-11-17 | **XP-nin yeganə azalma yolu: dueldən çıxma cəzası.** "Xal = XP, yeni funksiya yox" qərarına istisnadır: bazada cəza qeydi lazımdır. |
| 2026-11-17 | **Duel XP-si:** yalnız qalib alır, udduğu sual sayı qədər (16:14 → 16 və 0); bərabərlikdə hər birinə yarısının tam hissəsi (15:15 → 7). Çıxana **−50 XP**, qalan o ana qədər uddularını alır. Cəza 60 san gözləmədən sonra, çıxanın öz telefonu yazır. Suallar **tam təsadüfi**. |
| 2026-11-17 | **Duel XP-si duel bitəndə bir dəfə verilir**, duel cavabları adi XP vermir. **Duel sayına limit yoxdur** (XP üçün yenə düz cavab lazımdır). |
| 2026-11-17 | **Seriya qoruyucusu hələ yoxdur** (3.2 sonraya). |
| 2026-11-17 | **"Günün 3 tapşırığı" rədd edildi.** |
| 2026-11-17 | **Duelin ilk versiyası Bluetooth ilə** (Nearby Connections, yanaşı oturub). İnternet yalnız başlanğıcda sualları yükləmək üçün lazımdır. Uzaqdan (internetlə) duel sonra (4.2). |
| 2026-11-17 | **Mövzular indiki kimi qalır**: bütün suallar (kitab + DİM) görünür. "Yalnız kitab sualları" (köhnə 6.6) ləğv edildi. |
| 2026-11-17 | Yay imtahan dövrünün defolt tarixi **15 iyun** hələlik qalır. |
| 2026-11-17 | **Sınaq imtahanı (D) sonraya**: tam sınaq üçün bütün fənlər bazada olmalıdır. Tək fənn üzrə məşq üçün "Bugünkü məşq" kifayətdir. |
| 2026-11-17 | **Müəllim qrupları sonraya**: əvvəl 11 fənnin hamısı bazada olmalıdır (aşağıda, faza A). Sonra qruplar açılır. |
| 2026-11-17 | Google web client secret yenilənib. |
| 2026-11-12 | Yarışda yalnız ümumi reytinq, həftəlik cədvəl yoxdur. |
| 2026-10-30 | Duel yalnız dostlar arasında, mükafat yox, mesajlaşma yox. |

---

## 1. Yol xəritəsi (fazalar)

Hədəf: **qəbul imtahanı** (11-ci sinif buraxılışı da onun içindədir). Şagird istənilən fənni görə bilir, qrup seçimi yoxdur.
Yayım: Play Store-a qədər APK link ilə (`app_config.update_url`).

| Faza | Nə | Vəziyyət |
|---|---|---|
| **A. Məzmun** | 11 fənn (aşağıda), hər fənn üçün 1500+ sual | 🟢 gedir (ayrı agent): kimya, biologiya, riyaziyyat başlanıb |
| **A+. Tədris (mövzu izahları)** | Ayrıca "Tədris" bölməsi: hər mövzuda "Oxu". Dərslik yalnız mənbə/plan, mətn öz sözlərimizlə, müəllim yoxlayır | 💡 A-dan sonra |
| **B. Hədəf** | İmtahan dövrü, gündəlik hədəf, "N gün qalıb" | ✅ (migration 010) |
| **C. Statistika** | "İrəliləyiş" tabı | ✅ (migration 018, Supabase-də işlədilməlidir) |
| **D. Sınaq imtahanı** | Taymer, mövzu bölgüsü ilə sual seçimi, bal, səhvlərin təhlili | ⏸ bütün fənlər bazada olandan sonra; DİM-in bal düsturu lazımdır |
| **E. Oflayn və bildirişlər** | Mövzu yükləmə, internetsiz həll, axşam xatırlatması | ✅ ilk versiya. Qalıb: "Bugünkü məşq" və "Səhvlər dəftəri" oflayn, yüklənmiş mövzunun avtomatik yenilənməsi |
| **F. Buraxılış** | Real Supabase, məxfilik siyasəti, veb "hesabı sil" linki, öz SMTP, Google consent "Publish", Play App Signing SHA-1, Play Store | 🟢 sonra |
| **G. Premium və müəllimlər** | Sınaq imtahanı və statistikanın bir hissəsi premium; müəllim qrupları (5) | ⏸ gəlir modeli seçilməyib |

**Fənlər (hədəf, 11):** kimya, biologiya, riyaziyyat, fizika, coğrafiya, ədəbiyyat, tarix (ümumi və Azərbaycan tarixi), Azərbaycan dili, ingilis dili, rus dili, informatika.
Hər yeni fənn: `tools/dim/common/subjects.py`-a sətir + bazada `subjects` sətri. Tətbiqdə fənn rəngi (`AppColors.subjectAccent`), ikonu (`subjectIcon`) və köməkçinin fənn sözləri (`cheer<Fənn>`) əlavə olunur.

**İş ritmi:** suallar ayrı agentlə paralel gedir; feature tərəfində bir-bir faza/fikir götürülür.

---

## 2. Blokerlər

1. **DİM-in bal düsturu**: D fazasından əvvəl.
2. **Mənbə razılıqlarının yazılı surəti** (DİM, Araz, Güvən): F fazasından əvvəl.
3. **Məxfilik mətni**: Yarışdakı ad/soyad toplanması və nik-adın açıq görünməsi hələ yazılmayıb (F-dən əvvəl).

---

## 3. Uşaqları tətbiqdə saxlamaq (retention)

Məqsəd: şagird tətbiqi hər gün açsın. Mövcud hissələrin üstündə qurulur: seriya, köməkçi (mascot), gündəlik hədəf, `topic_progress`, axşam xatırlatması, Yarış.
Məhdudiyyətlər: çat yoxdur, AI yoxdur, həftəlik reytinq yoxdur, yalnız Android.
**Auditoriya: 15–17 yaş (9–11-ci sinif).** Uşaq üslubu (papaq geyindirmək, oyuncaq kimi mükafat) yox; status, müqayisə, paylaşma, imtahan nəticəsinə yaxınlıq.

### 3.1 Xalın adı XP olur 🟢 · S
- **Sahibin qərarı (2026-11-17):** ayrıca XP sistemi qurulmur. Yarışdakı mövcud xal sadəcə **"XP"** adlanır.
- Qayda dəyişmir: XP = ən azı bir dəfə düz həll edilmiş fərqli aktiv test (`get_leaderboard`, migration 017). Təkrar düz cavab XP vermir, səhv XP azaltmır.
- Səviyyə, zolaq, gündəlik tapşırıq YOXDUR.
- İş: yalnız mətnlər (`AppStrings`-də "xal" → "XP", üç dildə), Yarış ekranı, məxfilik/şərt mətnlərində xal sözü keçirsə. Baza dəyişmir.
- **Duel qurulanda XP-nin ikinci mənbəyi yaranır** (4.2): XP = həll edilmiş testlər + duel XP-si (yalnız qalibə) − dueldən çıxma cəzaları. `get_leaderboard` dəyişir (migration).

### 3.2 Seriya qoruyucusu ⏸ · S–M (sahib: hələ yox)
- 7 günlük seriyaya 1 "dondurma": bir gün buraxılanda seriya qırılmır. Axşam xatırlatması: "Seriyan təhlükədədir, qoruyucun var".
- Niyə: uşaqlar tətbiqi ən çox seriya qırılan gün atır.
- Texniki: seriya serverdədir → migration (`profiles.streak_freezes` + trigger), `planReminders` yenilənir.

### 3.3 Həftənin xülasəsi (paylaşılan kart) 💡 · S–M
- Bazar günü: "Bu həftə 84 test, 76% düz, ən güclü mövzun: Faiz". Kart şəkil kimi WhatsApp/Instagram-a paylaşılır, üstündə tətbiq linki olur.
- Niyə: həm saxlayır, həm pulsuz reklamdır. `get_my_stats` və `share_plus` hazırdır.

### 3.4 Digərləri 💡
| Fikir | Qısa | Həcm |
|---|---|---|
| **Köməkçi böyüyür** | XP-yə görə köməkçiyə papaq, eynək, rəng açılır. ⚠ 15–17 yaş üçün uşaqvari ola bilər; varsa, sadə "nişan/rəng" kimi | M |
| **Nişanlar (medallar)** | "7 gün ardıcıl", "İlk 100 düz", "Fəsli bitirdi", "Gecə bayquşu" | S |
| **Mövzu xəritəsi** | Fəsillər yol kimi, hər mövzu rəngli (zəif / davam edir / yaxşı), "növbəti dayanacaq" | M |
| **Blitz: 60 saniyə** | Avtobus üçün qısa raund, yüklənmiş mövzudan oflayn, şəxsi rekord | S |
| **Ağıllı xatırlatma vaxtı** | 20:00 əvəzinə şagirdin adətən oxuduğu saat; ayarlarda söndürmə/saat seçimi | S |
| **Geri sayım mərhələləri** | "İmtahana 100 gün" kimi günlərdə xüsusi ekran + plan | S |
| **Köməkçinin sözləri hər yerdə** | İndi yalnız "Bugünkü məşq"-dədir; Mövzular, Səhvlər dəftəri də (sahib istəyib) | S |

---

## 4. Yarış və duel

### 4.1 Liderlər cədvəli ✅
- Hazırdır: hər fənn üzrə ümumi reytinq, yalnız nik-ad görünür (migration 017). Həftəlik cədvəl yoxdur (sahibin qərarı).
- 💡 Qalan: admin paneldə nik-ad moderasiyası (gizlətmə), şübhəli hesablar (qısa vaxtda həddən artıq xal), istifadəçi çoxalanda materialized view.

### 4.2 Duel: Bluetooth ilə 🟢 · L
**Sahibin qərarları:** yalnız dostlar arasında, mükafat yox, mesajlaşma yox (2026-10-30); **ilk versiya Bluetooth ilə** (2026-11-17).

**Sahibin ssenarisi (2026-11-17):**

1. **Qoşulma.** İki dost yanaşı oturur. Bluetooth **məcburidir**: söndürülübsə, tətbiq yandırmağı istəyir, yandırmadan duelə girmək olmur.
   Biri **otaq yaradır**, o biri "Yaxındakı otaqlar" siyahısında otağın adını görür və qoşulur. Parol, kod lazım deyil.
2. **Ayarlar (otağı yaradan seçir).**
   - **Fənn** (məs. kimya): duel həmişə bir fənn üzrədir.
   - **Sual sayı** (məs. 30).
   - **Sual başına vaxt:** ən az 30 san, ən çox 300 san.
3. **Suallar.** Seçilmiş fənndən **təsadüfi** götürülür. Başlanğıcda hər iki telefonda internet olur:
   - **sualları sistem (server) seçir**, oyunçu yox: otağı yaradan telefon serverdən "fənn + say" üzrə təsadüfi sual ID-lərini alır və o birinə göndərir;
   - hər telefon **yalnız özündə olmayan** sualları (şəkli ilə) yükləyir;
   - yüklənən sual **həqiqətən telefonda qalır** (oflayn bazaya yazılır, sonra da internetsiz açılır);
   - hər iki telefon "hazıram" deyəndən sonra duel başlayır. Bundan sonra internet lazım deyil, hər şey Bluetooth ilə gedir.
4. **Gediş.** Hər sual **iki telefonda eyni anda** açılır.
   - **Kim birinci düz cavab versə, sualı o udur.**
   - Hər oyunçunun hər sualda **1 cəhdi** var. Biri səhv etsə, o biri vaxt bitənə qədər cavab verə bilər.
   - **İkisi də səhv** etsə və ya vaxt bitsə → növbəti sual.
   - **Pas keçmək yoxdur.** Geri qayıtmaq da yoxdur.
5. **Nəticə və XP.** Sonda **kim çox sual udubsa**, duelin qalibi odur.
   - **XP-ni yalnız qalib alır:** udduğu sual sayı qədər. Məs. 16:14 → qalib 16 XP, uduzan 0 XP.
   - **Bərabər hesab:** hər ikisi yarısının tam hissəsi qədər alır. 15:15 → hər birinə 7, 14:14 → 7, 13:13 → 6.
   - Duel XP-si adi "ilk düz cavab" qaydasından asılı deyil: əvvəl həll etdiyin sualı dueldə udsan da sayılır.
6. **Dueldən çıxmaq.**
   - Çıxan oyunçudan **50 XP silinir** (XP 0-dan aşağı düşmür) və o, bu dueldən heç nə almır.
   - Qalan oyunçu o ana qədər udduğu sualların XP-sini alır.
   - Cəza yalnız "Dueldən çıx" təsdiqlənəndə və ya tətbiq bağlanıb **60 san** ərzində geri qayıdılmayanda yazılır. Qısa qopmada (batareya, Bluetooth, zəng) 60 san gözlənilir, qayıtsa duel davam edir.
   - Cəzanı **çıxanın öz telefonu** yazır (rəqib başqasının XP-sini sildirə bilməsin).

**Texniki qeydlər:**
- Android **Nearby Connections** (Bluetooth + Wi-Fi Direct). Paket (məs. `nearby_connections`) başlayanda yenidən yoxlanmalıdır. İcazələr: Android 12+ "yaxındakı cihazlar", köhnə Android-də yer (location).
- Telefonlar arasında yalnız kiçik mesajlar gedir: ayarlar, sual ID-ləri, "hazıram", cavab + vaxt, "sualı udu". Şəkil göndərilmir.
- **Sual seçimi serverdə:** yeni RPC (məs. `pick_duel_questions(subject, count)`), yalnız aktiv suallar, tam təsadüfi (sahibin qərarı). Bunu otağı yaradan çağırır (başlanğıcda internet var).
- **Hakim otağı yaradan telefondur:** "kim birinci" qərarını o verir (iki telefonun saatı fərqli ola bilər, ona görə vaxt hakimin aldığı ana görə ölçülür). Yoxlama telefonda (`AnswerChecker`).
- **Tək sualın yüklənməsi yenidir:** indi oflayn yükləmə vahidi mövzudur (`TopicDownloader`). Duel üçün "bu ID-ləri yüklə" yolu lazımdır. Ehtimal: yeni RPC (ID siyahısı ilə sual sətirləri) + mövcud şəkil yükləyicisi + `LocalDatabase`-də mövzudan asılı olmayan sual sətri. Yarımçıq yüklənmiş sual "yüklənib" sayılmır (şəkil də gəlməlidir).
- **Duel XP-si bazada yenidir.** İndi XP yalnız `answers`-dən hesablanır. Lazım olacaq: `duel_results` (hər oyunçunun öz sətri: duel ID, fənn, aldığı XP, cəza) + `get_leaderboard`: **XP = həll edilmiş testlər + duel XP-si − cəzalar** (0-dan aşağı düşmür). Nəticə internetsiz yaranır, `AnswerOutbox` kimi növbə ilə serverə gedir; duel ID ilə təkrar göndərmə təhlükəsizdir.
- **Duel cavabları adi XP-yə sayılmır:** `answers`-də duel işarəsi (məs. `duel_id`), `get_leaderboard`-un "həll edilmiş test" hissəsi onları istisna edir.
- Qopma: rəqib çıxdı / əlaqə kəsildi → 60 san gözlənilir, sonra duel bitir, o ana qədərki hesab göstərilir.
- Nəticə ekranı: kim qalib, hesab (məs. 17:11), hər sual üzrə kim udub, doğru cavab və izah; köməkçi qalibi təbrik edir.
- Ədalət: dostlar yanaşı oturur, cavab telefonda yoxlanır. Bu, v1 üçün qəbul olunur.
- Arxitektura: duel məntiqi kanaldan asılı olmasın (`DuelChannel` interfeysi: indi Nearby, sonra Realtime).

**Duel cavabları və XP (sahibin qərarı, 2026-11-17):**
- Dueldə XP-ni **yalnız qalib** alır, düz cavab verdiyi (udduğu) sual sayı qədər, **duel bitəndə bir dəfə** (sual-sual yox).
- Duel cavabları **adi XP vermir** ("həll edilmiş test" XP-sinə sayılmır), yoxsa uduzan da XP alar, qalibin XP-si ikiqat sayılar.
- Duel cavabları `answers`-ə **"duel" işarəsi ilə** yazılır: seriya, statistika, səhvlər dəftəri işləyir (təklif, etiraz olunmayıb).
- **Duel sayına limit yoxdur.** Səbəb (sahib): XP üçün yenə də düz cavab vermək lazımdır.

<details><summary>Sahibin orijinal mətni (Duel.md, 2026-11-17)</summary>

> 1 iki dost yan yana oturur. blutuzu açır və otaq yaradir digeride yaxniliqdaki otaqlar deyir blutuz mecbur yandirdi yox girmək olmaz daha sonra otagi adi goruru qislur sifre zad lazim deyil
> suallar verilir tesadufu olaraq her ikside intenet olur ve deyilirki bu suallar yüklınməlidir kimde hansi sual yüklu deyilse sadece olar yüklənsin amma bir meslen bir sual yuklenirse o dogurdanda yüklesnin
> ve fen uzre olsun duel evelce tbiki fen seçilmeidir kia uzre soraoda seçen edir buari kimya neçe sual olsun 30 sual her suala minum 30 samoye maks 300 san vaxr verilsin pas keçde olsun pas keçdide cavab gostreey gediyac yoxdur sonra qayida biler duhun her brin 30 sua verilr eyni suaa cavab vernek ziuduuer mesen sual iside eyni ada veirlri kim tez dogru cavablasa o udur herseni 1 sans verili ikside sehv elese diger suala kecilir
> normla xal verilri fso dule sonda kim cox duz tapibsa o olur

</details>

**Sonra (v2, internetlə):** asinxron (dost 24 saat ərzində eyni suallara cavab verir) və ya canlı (Supabase Realtime, kod/QR). Bunun üçün dost siyahısı, push (FCM), serverdə cavabsız sual və vaxt lazımdır.

---

## 5. Müəllim və şagird qrupları ⏸ (11 fənn bazada olandan sonra)

**Sahib öz fikrini yazacaq.** Aşağıdakılar köhnə müzakirədəndir, o yazandan sonra yenilənir.

**Nə istənir:** qeydiyyatda rol (müəllim/şagird); müəllim qrup yaradır, şagirdləri əlavə edir, **ev tapşırığı** verir (mövzu/testlər, son tarix), nəticələri canlı görür.

**Açıq suallar:**
1. Müəllimin təsdiqi: admin əl ilə, yoxsa mövcud `teachers` cədvəli ilə?
2. Şagirdi qrupa necə əlavə etmək. Təhlükəsiz yol: dəvət kodu/link, və ya nik-adla dəvət + şagird qəbul edir.
3. Məxfilik: şagirdlər azyaşlıdır; müəllim yalnız öz qrupunu görür, şagird qrupdan çıxa bilir; şərtlərə yeni bölmə.
4. Ödəniş: müəllim üçün pulludur? Pulsuz limit (1 qrup, 5 şagird)?
5. Oflayn tapşırıq: nəticə "canlı" yox, şagird internetə qoşulanda görünür.

**Texniki eskiz:** `profiles.role`; `groups` (dəvət kodu), `group_members` (dəvət/üzv), `assignments`; RLS; canlı nəticə Supabase Realtime ilə; push (FCM) lazımdır; müəllim üçün veb panel (PrepAzAdmin əsasında) daha rahat ola bilər. Nik-ad artıq var (`leaderboard_players`).

**Əlavə fikirlər:**
- Müəllim: qrupun zəif mövzuları, qrupda ən çox səhv edilən suallar (kodu ilə), "hər şagirdə öz zəif mövzusunu ver" düyməsi, qrup sınaq imtahanı, "3 gündür girməyib" siyahısı, səhvin altına qısa qeyd.
- Valideyn: həftəlik hesabat linki (müəllim üçün satış aləti; şagirdin razılığı ilə).
- Şagird: qrup reytinqi (müəllim söndürə bilsin), qrup məqsədi ("həftədə 500 test"), "Müəllimdən soruş" (sual kodu ilə), köməkçi müəllimin adını çəkir, qrup içində duel turniri.
- Biznes: kurs mərkəzləri üçün təşkilat planı; müəllim kartından "qrupuna qoşulmaq istəyirəm".
- Müəllimin öz sualları yalnız öz qrupu üçün (`source` məcburi qalır).

---

## 6. Məzmun və öyrənmə alətləri

### 6.1 İmtahanda lazım olan cədvəllər 💡 · S–M
Mendeleyev cədvəli, duzların həllolma cədvəli, metalların gərginlik sırası, əsas düsturlar; digər fənlər üçün qayda/düstur cədvəlləri. Oflayn işləyir, tətbiqi gündəlik açmağa səbəb olur.

### 6.2 Düstur kartları (flashcards) 💡 · M
"Bu düsturu bilirsənmi?" Səhv edilən kartlar səhvlər dəftərinin məntiqi ilə (1 → 3 → 7 → 14 gün) təkrarlanır.

### 6.3 Keçmiş DİM variantları ⏸ · M
Hər imtahanı olduğu kimi həll etmək (D fazası ilə birlikdə, taymerlə).

### 6.4 Sual işarələmək 💡 · S
"Sonra baxım" üçün saxlanılan suallar.

### 6.5 Çətinliyin avtomatik hesablanması 💡 · S
Sual real cavablarda neçə faiz düz bilinirsə, çətinlik ona görə yenilənir.

### 6.6 AI izahı 💡 (MVP-də yoxdur)
Səhv izah riski var; müəllimin yoxladığı izahlar daha etibarlıdır.

### ❌ Mövzular-da yalnız kitab sualları
Ləğv edildi (2026-11-17): Mövzular indiki kimi bütün sualları göstərir.

---

## 7. Giriş və hesab
- ✅ E-poçt + parol, Google ilə giriş, hesabı silmək.
- 💡 **Parol bərpası**: hələ yoxdur (deep link olmadan: e-poçta 6 rəqəmli kod).
- 🟢 **Öz SMTP** (Resend, Brevo): Supabase-in standart poçt limiti çox aşağıdır; buraxılışdan əvvəl.
- 💡 **Qonaq rejimi:** hesabsız 10–20 sual, sonra "irəliləyişi saxla".

---

## 8. Üç ayrı tətbiq: İbtidai, 5–9, Abituriyent 💡 · L (qərar yoxdur)

- **Lehinə:** hər yaşa öz dizaynı; Play Store-da ayrıca səhifə; 13 yaşdan kiçiklər üçün Google Play **Families** qaydaları yalnız İbtidai-yə aid olur (ən güclü səbəb).
- **Risklər:** 3 buraxılış (yüngülləşdirmə: bir kod bazası, Flutter flavor-ları `az.prepaz.ibtidai`, `az.prepaz.orta`, `az.prepaz`); bir Supabase, bir hesab (`grade_level`); **ən böyük iş məzmundur**: İbtidai və 5–9 üçün razılıqlı mənbə yoxdur; valideyn hesabı lazımdır.
- **Sərhəd təklifi:** 5–9 = sinif materialı + 9-cu sinif buraxılışı; Abituriyent = 10–11 + 11-ci sinif buraxılışı + qəbul.
- **Ardıcıllıq:** Abituriyent Play Store-a çıxsın → kod flavor-lara, baza `grade_level` → 5–9 → İbtidai ən sonda.
- `az.prepaz` Abituriyent olaraq qalır (applicationId dəyişmir).

---

## 9. Texniki qərarlar arxivi (niyə belə seçilib)
- Oflayn baza: **drift (SQLite)**; Isar (inkişaf dayanıb) və Hive (sorğu çətindir) seçilmədi.
- Tam offline-first edilmir: düz/səhv qərarını həmişə server verir, telefon (`AnswerChecker`) yalnız oflayn nəticə göstərir.
- Yükləmə vahidi mövzudur ("bütün fənn" yox): bir şəkil PNG-də ~59 KB idi, WebP onun ~44%-idir.
- Statistika serverdə hesablanır (RPC), telefonda yox.
- XP (köhnə adı "Yarış xalı"): sualın ilk düz cavabında yazılır, təkrar XP vermir, səhv azaltmır, serverdə hesablanır. Ayrıca XP sistemi qurulmur. Duel əlavə edir: qalibə udduğu sual sayı qədər XP; yeganə azalma dueldən çıxma cəzasıdır (−50).
