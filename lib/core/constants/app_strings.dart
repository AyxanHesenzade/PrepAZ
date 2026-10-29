/// Bütün istifadəçi mətnləri bir yerdədir. Sonra l10n-ə keçmək asan olsun.
abstract final class AppStrings {
  static const appName = 'PrepAZ';

  // Ümumi
  static const retry = 'Yenidən cəhd et';
  static const unknownError = 'Xəta baş verdi. İnterneti yoxlayıb yenidən cəhd edin.';
  static const loadFailed = 'Məlumat yüklənmədi.';
  static const configMissing = 'Supabase konfiqurasiyası tapılmadı.\n\n'
      'Belə işə salın:\nflutter run --dart-define-from-file=env/test.json';

  // Auth
  static const signInTitle = 'Hesabınıza daxil olun';
  static const signUpTitle = 'Yeni hesab yaradın';
  static const signInAction = 'Daxil ol';
  static const signUpAction = 'Qeydiyyat';
  static const switchToSignIn = 'Hesabım var — daxil ol';
  static const switchToSignUp = 'Hesabım yoxdur — qeydiyyat';
  static const email = 'E-poçt';
  static const password = 'Parol';
  static const signOut = 'Çıxış';
  static const confirmEmailNotice =
      'Hesab yaradıldı. E-poçtunuza gələn linklə təsdiqləyin, sonra daxil olun.';

  // Validasiya
  static const invalidEmail = 'Düzgün e-poçt yazın';
  static String shortPassword(int min) => 'Ən azı $min simvol';

  // Auth xətaları
  static const invalidCredentials = 'E-poçt və ya parol yanlışdır.';
  static const userAlreadyExists = 'Bu e-poçtla hesab artıq var. Daxil olun.';
  static const emailNotConfirmed = 'E-poçt hələ təsdiqlənməyib. Gələn məktubdakı linkə basın.';
  static const weakPassword = 'Parol çox zəifdir.';

  // Ana səhifə
  static const homeTitle = 'Bugün';
  static const subjects = 'Fənlər';
  static const streakEmpty = 'Bu gün ilk məşqinlə seriyaya başla';
  static String streak(int days) => 'Seriya: $days gün ardıcıl';
  static const noSubjects = 'Hələ fənn əlavə olunmayıb.';

  // Zəif mövzular
  static const noMasteryYet = 'Hələ cavab yoxdur. Məşq etdikcə zəif mövzular burada görünəcək.';
  static const weakTopics = 'Zəif mövzular';

  // Məşq
  static const startQuiz = 'Bugünkü məşqə başla';
  static String questionOf(int n, int total) => 'Sual $n / $total';
  static const check = 'Yoxla';
  static const dontKnow = 'Bilmirəm';
  static const nextQuestion = 'Növbəti sual';
  static const toResult = 'Nəticəyə bax';
  static const yourAnswerField = 'Cavabınız';
  static const noQuestionsLeft =
      'Bu gün üçün yeni sual qalmadı. Əla iş!\nSəhv etdiyin suallar təkrar vaxtı çatanda burada görünəcək.';
  static const correct = 'Düzdür!';
  static String wrong(String right) => 'Səhvdir. Düzgün cavab: $right';
  static const writtenPending = 'Bu cavab sonra yoxlanılacaq';
  static const solution = 'Həll:';
  static const savedForReview = 'Bu sual təkrar üçün yadda saxlandı: sabah yenidən görəcəksən.';
  static const imageFailed = 'Şəkil yüklənmədi';

  // Nəticə
  static String resultTitle(String subject) => '$subject: nəticə';
  static String percentCorrect(int pct) => '$pct% düz';
  static const allCorrect = 'Hamısı düzdür. Sabah daha çətin suallar gələcək!';
  static String wrongTitle(int n) => 'Səhvlər dəftərinə düşənlər ($n)';
  static const wrongHint = 'Bunları 1, 3, 7 və 14 gün sonra yenidən görəcəksən.';
  static String yourVsRight(String given, String right) => 'Sənin cavabın: $given  ·  Düzgün: $right';
  static const backHome = 'Ana səhifəyə qayıt';
}
