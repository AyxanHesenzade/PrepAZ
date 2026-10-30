# PrepAZ — reytinq və duel planı (2026-10-30)

Əsas plan ([PLAN.md](PLAN.md)) bitəndən sonra başlayır. Bu fayl ayrıca saxlanır.

## Sahibin qərarları
- Duel yalnız **dostlar** arasında olur (təsadüfi rəqib yoxdur).
- Mükafat yoxdur, yalnız **xal**.
- Xal sistemi **hamıya açıqdır**: hər fənn üzrə ayrıca liderlər cədvəli (biologiya birincisi, kimya birincisi və s.). Birincilər bir yerdə görünür.
- **Mesajlaşma yoxdur**: nə çat, nə də duel daxilində mesaj.

## Nə düzəldəcəyik

### 1. Liderlər cədvəli
- Hər fənn üçün ayrıca cədvəl, həftəlik və ümumi (aylıq da ola bilər).
- Həftəlik sıfırlanma vacibdir: yoxsa ilk gün başlayanlar həmişə birinci qalır, yeni gələnlər həvəssiz olur.
- "Birincilər" yeri: hər fənnin həftəlik birincisi bir ekranda görünür.
- Cədvəldə yalnız **ləqəb** və xal göstərilir. Real ad və foto yoxdur.

### 2. Dostlar
- Dost əlavə etmək: dəvət kodu və ya linki.
- Dost siyahısı yalnız ləqəblə.

### 3. Asinxron duel (birinci buraxılış)
- A dostuna 10 sualdan ibarət duel göndərir və öz hissəsini həll edir.
- B 24 saat ərzində eyni suallara cavab verir.
- Qalib düz sayına, bərabərlikdə vaxta görə təyin olunur.
- Eyni vaxtda onlayn olmaq lazım deyil, internet zəif olanda da işləyir.
- Duel suallarını server seçir: heç kimin əvvəl görmədiyi (və ya hər ikisinin görmədiyi), eyni çətinlik aralığında.

### 4. Canlı duel (sonra, istəyə görə)
- İki dost eyni anda qoşulur, canlı yarışır.
- Supabase Realtime, bağlantı kəsilməsinin idarəsi lazımdır, daha mürəkkəbdir. Asinxron işləyəndən sonra əlavə edilir.

## Xal sistemi (düstur açıqdır, H fazasında dəqiqləşir)
Məqsəd: eyni suallara dəfələrlə cavab verib xal yığmaq mümkün olmasın.
- Xal sualın **ilk dəfə düz** cavablandığı anda yazılır, çətinlikdən asılı olaraq.
- Üstəgəl: duel qələbəsi, sınaq imtahanı nəticəsi (D fazasından sonra).
- Səhv cavab xalı azaltmır, amma xal da vermir.
- Sual təkrar edilsə xal verilmir (təkrar məşq xal vermir, yalnız öyrənmə üçündür).

## Ön şərtlər (əsas planın fazaları)
| Nə lazımdır | Hansı faza |
|---|---|
| Sınaq taymeri və bal məntiqi | D |
| Bildirişlər ("sənə duel göndərildi") | E |
| Kifayət qədər sual, təkrarsız dəst üçün | A |
| Real Supabase, məxfilik siyasəti | F |

## Ədalət və təhlükəsizlik
- **Cavab gizlənməlidir:** indi sual sətri `correct_answer`-i də daşıyır, dəyişdirilmiş tətbiq onu oxuya bilər. Duel və xal yarışı üçün sualı serverdən cavabsız almaq və vaxtı serverdə ölçmək lazımdır. Adi məşqdə problem yoxdur.
- **Xal serverdə hesablanır**, tətbiq yalnız göstərir.
- **Yetkinlik yaşına çatmayanlar var:** real ad və foto yoxdur, çat yoxdur, profil minimaldır.
- **Ləqəb moderasiyası:** təhqiramiz ləqəblər admin paneldən gizlədilə və ya dəyişdirilə bilməlidir. Ləqəb dəyişmək sayı məhdudlaşdırılmalıdır.
- **Qeyri-adi nəticələr:** çox qısa müddətdə həddindən artıq xal toplayan hesablar admin paneldə işarələnir.

## Admin paneldə lazım olacaq
- Ləqəblər siyahısı və gizlətmə.
- Şübhəli hesablar.
- Xalı əl ilə düzəltmək (xəta olarsa).
- Liderlər cədvəlinin həftəlik sıfırlanma vaxtı.

## Açıq suallar
1. Xal düsturu: çətinliyə görə neçə xal, duel qələbəsi neçə xal.
2. Həftəlik sıfırlanma hansı gün və saatda olsun.
3. Ləqəbi şagird özü seçir, yoxsa tətbiq təklif edir? (Moderasiyanı asanlaşdırır.)
