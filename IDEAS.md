# PrepAZ — ideyalar (2026-10-30)

Qərar verilməmiş ideyalar. Qərar veriləndə [PLAN.md](PLAN.md)-yə və ya ayrıca plan faylına köçürülür.
Reytinq və duel planı: [PLAN_DUEL.md](PLAN_DUEL.md).

## Qeydiyyat və giriş (qərar gözləyir)
Hazırda: e-poçt + parol. Test Supabase-də e-poçt təsdiqinin açıq olub-olmadığı yoxlanmalıdır.

| Variant | Üstünlük | Problem |
|---|---|---|
| **E-poçta link (magic link)** | Parol yoxdur | Link tətbiqə qayıtmalıdır (deep link quraşdırması). Brauzerdə/kompüterdə açılsa daxil olmur. Spam qovluğu. |
| **E-poçta 6 rəqəmli kod** | Deep link yoxdur, kodu tətbiqdə yazırsan | Poçt göndərişi lazımdır |
| **Google ilə giriş** | Bir toxunuş, parol və poçt gözləmək yoxdur | İOS-da Apple ilə giriş də tələb olunur |
| **Qonaq rejimi** | Hesabsız 10–20 sual, sonra "irəliləyişi saxla" | Qonaq məlumatını hesaba köçürmək lazımdır |

- Supabase-in standart e-poçt göndərişinin saatlıq limiti çox aşağıdır. Real istifadəçilər üçün öz SMTP xidməti (məs. Resend, Brevo) qoşulmalıdır.
- Liderlər cədvəli və duel üçün **təsdiqlənmiş hesab** lazımdır (saxta hesabla xal yığmaq olmasın).
- **Təklif:** Google ilə giriş + e-poçt kodu, parol sonra istəyə görə, qonaq rejimi də düşünülür.

## Ən güclü ideyalar
1. **İmtahan zamanı lazım olan cədvəllər (kimya):** Mendeleyev cədvəli, duzların həllolma cədvəli, metalların gərginlik sırası, əsas düsturlar. Oflayn işləyir, qurmaq asandır, tətbiqi gündəlik açmağa səbəb verir. Biologiya və riyaziyyat üçün də düstur/qayda cədvəlləri.
2. **Müəllim sinifləri:** müəllim sinif kodu yaradır, şagirdlər qoşulur, müəllim onların statistikasını (zəif mövzularını) görür. Tövsiyə olunan müəllimlər bölməsi ilə birləşir, gələcəkdə gəlir mənbəyi ola bilər. Şagirdin razılığı və məxfilik qaydaları lazımdır.
3. **Düstur kartları (flashcards):** "bu düsturu bilirsənmi?", səhv edilənlər səhvlər dəftərinin məntiqi ilə təkrarlanır.

## Digər ideyalar
- **Medallar və hədəflər:** "7 gün ardıcıl", "100 düz cavab", seriyanı qorumaq üçün bir dəfəlik "buraxma" hüququ.
- **Keçmiş DİM variantları:** hər imtahanı olduğu kimi həll etmək (sınaq imtahanı fazasından sonra).
- **Valideyn hesabatı:** həftəlik qısa xülasə. Yetkinlik yaşına çatmayanlar üçün şagirdin razılığı ilə.
- **AI izahı** (səhvin səbəbini izah edir): MVP-də yoxdur. Səhv izah riski var; müəllimlə yoxlanmış izahlar daha etibarlıdır.
- **Sual işarələmək:** sonra baxmaq üçün saxlanılan suallar.
- **Çətinliyin avtomatik hesablanması:** sual real cavablarda neçə faiz düz bilinirsə, çətinlik ona görə yenilənir (əl ilə yazılan çətinlikdən daha dəqiqdir).
