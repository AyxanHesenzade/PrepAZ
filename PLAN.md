# PrepAZ — plan (2026-10-30)

Hədəf: **qəbul imtahanı** (11-ci sinif buraxılışı onun içindədir). Şagird istənilən fənni görə bilir, qrup seçimi yoxdur.
Yayım: Play Store-a qədər Google Drive ilə APK.

## Hazır olanlar
Gündəlik məşq, zəif mövzular, səhvlər dəftəri (aralıqlı təkrar), seriya, "Mövzular" (axtarış, ardıcıl həll, suala keçid),
tövsiyə olunan müəllimlər, məcburi yeniləmə ekranı, xəta bildirişi, 3 dil, admin panel (suallar, müəllimlər, bildirişlər, tənzimləmələr).
Kitab 1-dən 206 şəkil-sual (bölmə 1–5), üstəgəl yüklənməyi gözləyən 47 açıq sual.

## Fazalar

| Faza | Nə | Hazır sayılır |
|---|---|---|
| **A. Məzmun** | Kimya, sonra biologiya, sonra riyaziyyat. Kitab 1-in qalan bölmələri, yarımçıq 82 kimya və 38 biologiya sualı | Hər fənn üçün 1500+ sual |
| **A+. Mövzu izahları** | A bitəndən sonra. Dərslik yalnız mənbə və plan kimi, mətn öz sözlərimizlə | Hər mövzuda "Oxu" düyməsi |
| **B. Hədəf** (kod hazır, migration 010 işlədilməli) | İlk açılışda imtahan dövrü seçimi, gündəlik hədəf, "təxminən N gün qalıb" | Ana ekranda geri sayım |
| **C. Statistika** | Fənn və mövzu faizi, həftəlik irəliləyiş, zəif mövzular | Ayrıca ekran |
| **D. Sınaq imtahanı** | Taymer, mövzu bölgüsü ilə sual seçimi, bal, səhvlərin təhlili | Bir tam sınaq həll edilir |
| **E. Oflayn və bildirişlər** | drift (SQLite) + "əvvəlcədən yüklə", seriya xatırlatması | İnternetsiz məşq edilir |
| **F. Buraxılış** | Real Supabase, məxfilik siyasəti, "hesabı sil", admin panel hostinqi, Play Store | Mağazada yayımlanır |
| **G. Premium və müəllimlər** | Sınaq imtahanı və statistikanın bir hissəsi premium, müəllim bölməsi genişlənir | Gəlir modeli seçilir |

## Qərarlar

### A. Məzmun
- Mənbələr: DİM (razılaşma var), Araz və Güvən (sahib bildirir ki, razılıq alınıb; yazılı razılığın surətini saxlamaq tövsiyə olunur).
- Dərsliklər üçün razılıq YOXDUR: mətn köçürülmür, izahlar öz sözlərimizlə yazılır, müəllim yoxlayır.
- Şəkil-suallarda ədədi, çoxseçimli və uyğunlaşdırma cavabları dəstəklənir (1.3.0, migration 014).

### B. Hədəf
- İmtahan dövrləri bazada saxlanır, admin paneldən dəyişir. Şagird dəqiq tarix yazmır, dövr seçir. İstəsə öz tarixini də yaza bilər.
- Defolt: qış dövrü üçün **15 fevral**. Yay dövrü (iyun–avqust) üçün defolt **15 iyun** (FƏRZDİR, sahib təsdiq etməyib).
- Real tarixi DİM elan edəndə admin paneldə bir yerdən yenilənir, hamıda dəyişir.
- Gündəlik hədəf defolt 20 sual.

### C. Statistika
- Serverdə hesablanır (SQL görünüşləri və ya RPC). Yerli baza lazım deyil, çünki cavablar artıq Supabase-dədir.

### E. Oflayn
- Yerli baza: **drift (SQLite)**. Isar (inkişaf dayanıb) və Hive (sorğu çətindir) seçilmədi.
- **"Əvvəlcədən yüklə"** variantı: internet olanda növbəti günlərin gündəlik dəsti, səhvlər dəftəri və seçilmiş mövzular şəkillərlə yüklənir. Oflayn cavablar növbəyə yığılır, internet gələndə göndərilir. Düz/səhv qərarını yenə server verir.
- Tam offline-first (alqoritmi telefonda təkrarlamaq) edilmir: server və telefon fərqli nəticə verə bilər.
- Yaddaş: bir şəkil təxminən 59 KB. "Bütün fənni yüklə" yox, "bu mövzunu yüklə" və ya "növbəti 3 günü yüklə".

## Blokerlər
1. **DİM-in bal düsturu** (D fazasından əvvəl lazımdır).
2. **Yay dövrünün defolt tarixi** təsdiq edilməlidir (B fazası).
3. **Mənbə razılıqlarının surəti** saxlanmalıdır (F fazasından əvvəl).

## Paralel xırda işlər
- Yeni APK (build 3): müəllimlər, mövzular, yeniləmə və bildirişlər testçilərə çatsın.
- `PrepAzAdmin` qovluğunun repoya daxil edilməsi.
- Yazılı razılığın surəti.

## İş ritmi
Cavab açarı şəkillərini göndərdikcə A fazasında bir və ya iki bölmə yükləyirik. Bir neçə bölmədən sonra B, C, D fazalarından biri kod tərəfində irəliləyir.
