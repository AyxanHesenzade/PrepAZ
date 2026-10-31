import 'app_language.dart';

/// Bütün istifadəçi mətnləri bir yerdədir: Azərbaycan, rus və ingilis dilində.
/// Hazırkı dil [language]-dədir (ayarlar onu dəyişir). Mətnlər getter-dir, ona görə `const` yazmaq olmur.
abstract final class AppStrings {
  static AppLanguage language = AppLanguage.az;

  static String _t(String az, String ru, String en) => switch (language) {
    AppLanguage.az => az,
    AppLanguage.ru => ru,
    AppLanguage.en => en,
  };

  static const appName = 'PrepAZ';

  // Ümumi
  static String get retry => _t('Yenidən cəhd et', 'Повторить', 'Try again');
  static String get unknownError => _t(
    'Xəta baş verdi. İnterneti yoxlayıb yenidən cəhd edin.',
    'Произошла ошибка. Проверьте интернет и попробуйте снова.',
    'Something went wrong. Check your internet connection and try again.',
  );
  static String get loadFailed =>
      _t('Məlumat yüklənmədi.', 'Не удалось загрузить данные.', "Couldn't load data.");

  /// Yalnız proqramçı üçündür (env faylı yoxdur), tərcümə olunmur.
  static const configMissing =
      'Supabase konfiqurasiyası tapılmadı.\n\n'
      'Belə işə salın:\nflutter run --dart-define-from-file=env/test.json';

  // Auth
  static String get signInTitle =>
      _t('Hesabınıza daxil olun', 'Войдите в свой аккаунт', 'Sign in to your account');
  static String get signUpTitle =>
      _t('Yeni hesab yaradın', 'Создайте новый аккаунт', 'Create a new account');
  static String get signInAction => _t('Daxil ol', 'Войти', 'Sign in');
  static String get signUpAction => _t('Hesab yarat', 'Создать аккаунт', 'Create account');
  static String get signInTab => _t('Daxil ol', 'Вход', 'Sign in');
  static String get signUpTab => _t('Qeydiyyat', 'Регистрация', 'Sign up');
  static String get switchToSignIn => _t(
    'Hesabınız var? Daxil olun',
    'Уже есть аккаунт? Войдите',
    'Already have an account? Sign in',
  );
  static String get switchToSignUp => _t(
    'Hesabınız yoxdur? Yeni hesab yaradın',
    'Нет аккаунта? Создайте новый',
    "Don't have an account? Create one",
  );
  static String get email => _t('E-poçt', 'Эл. почта', 'Email');
  static String get password => _t('Parol', 'Пароль', 'Password');
  static String get signOut => _t('Çıxış', 'Выйти', 'Sign out');
  static String get showPassword =>
      _t('Parolu göstər', 'Показать пароль', 'Show password');
  static String get hidePassword =>
      _t('Parolu gizlət', 'Скрыть пароль', 'Hide password');
  static String get signInGuideTitle =>
      _t('Necə daxil olum?', 'Как войти?', 'How do I sign in?');
  static String get signInGuideForm => _t(
    'E-poçtunuzu və PrepAZ üçün yaratdığınız parolu yazın.',
    'Введите почту и пароль, который вы создали для PrepAZ.',
    'Enter your email and the password you created for PrepAZ.',
  );
  static String get signInGuideTap => _t(
    '"Daxil ol" düyməsinə basın.',
    'Нажмите «Войти».',
    'Tap "Sign in".',
  );
  static String get signInGuideNewUser => _t(
    'Yeni qeydiyyatdan keçmisiniz? Əvvəl e-poçtunuza gələn məktubdakı linkə basın, sonra bura qayıdıb daxil olun.',
    'Только что зарегистрировались? Сначала нажмите на ссылку в письме, затем вернитесь сюда и войдите.',
    'Just signed up? First tap the link in the email we sent you, then come back here and sign in.',
  );
  static String get emailExample => 'ad@gmail.com';
  static String get emailSignInHelper => _t(
    'Qeydiyyatda yazdığınız e-poçt',
    'Почта, указанная при регистрации',
    'The email you signed up with',
  );
  static String get passwordSignInHelper => _t(
    'PrepAZ üçün yaratdığınız parol',
    'Пароль, который вы создали для PrepAZ',
    'The password you created for PrepAZ',
  );
  static String get emailSignUpHelper => _t(
    'Təsdiq məktubu bura gələcək. Açıb oxuya bildiyiniz e-poçtu yazın.',
    'Письмо придёт сюда. Укажите почту, к которой у вас есть доступ.',
    "The confirmation email goes here. Use an address you can open.",
  );
  static String passwordSignUpHelper(int min) => _t(
    'PrepAZ üçün yeni parol yaradın, ən azı $min simvol. E-poçtunuzun parolunu yazmayın.',
    'Придумайте новый пароль для PrepAZ, не менее $min символов. Не используйте пароль от почты.',
    'Create a new password for PrepAZ, at least $min characters. Not your email password.',
  );
  static String get signUpGuideTitle => _t(
    'Hesab yaratmaq 3 addımdır',
    'Создать аккаунт: 3 шага',
    'Creating an account takes 3 steps',
  );
  static String get signUpGuideForm => _t(
    'E-poçtunuzu yazın, yeni parol yaradın və "Hesab yarat" düyməsinə basın.',
    'Введите почту, придумайте пароль и нажмите «Создать аккаунт».',
    'Enter your email, create a password and tap "Create account".',
  );
  static String get signUpGuideLink => _t(
    'E-poçtunuza gələn məktubu açın və içindəki linkə basın.',
    'Откройте письмо на почте и нажмите на ссылку в нём.',
    'Open the email we send you and tap the link inside.',
  );
  static String get signUpGuideReturn => _t(
    'PrepAZ-a qayıdın: hesabınız hazırdır.',
    'Вернитесь в PrepAZ: аккаунт готов.',
    'Come back to PrepAZ: your account is ready.',
  );

  // E-poçt təsdiqi
  static String get confirmTitle => _t(
    'Son addım: e-poçtunuzu təsdiqləyin',
    'Последний шаг: подтвердите почту',
    'Last step: confirm your email',
  );
  static String get confirmHeadline => _t(
    'Az qaldı!',
    'Почти готово!',
    'Almost there!',
  );
  static String get confirmSentTo => _t(
    'Təsdiq məktubunu bu ünvana göndərdik:',
    'Мы отправили письмо с подтверждением на адрес:',
    'We sent a confirmation email to:',
  );
  static String get confirmStepOpen => _t(
    'E-poçtunuzu açın. Məktub görünmürsə, 1–2 dəqiqə gözləyin və Spam qovluğuna baxın.',
    'Откройте почту. Если письма нет, подождите 1–2 минуты и проверьте папку «Спам».',
    "Open your email. If it isn't there, wait 1–2 minutes and check your Spam folder.",
  );
  static String get confirmStepTap => _t(
    'Məktubdakı təsdiq linkinə basın. Boş səhifə açılsa, narahat olmayın: hesabınız təsdiqlənib.',
    'Нажмите на ссылку в письме. Если откроется пустая страница, не волнуйтесь: аккаунт подтверждён.',
    "Tap the link in the email. If a blank page opens, don't worry: your account is confirmed.",
  );
  static String get confirmStepReturn => _t(
    'PrepAZ-a qayıdın: özü daxil olacaq. Olmasa, aşağıdakı düyməyə basın.',
    'Вернитесь в PrepAZ: вход выполнится сам. Если нет, нажмите кнопку ниже.',
    "Come back to PrepAZ and you'll be signed in. If not, tap the button below.",
  );
  static String get confirmCheckAction =>
      _t('Təsdiqlədim, davam et', 'Я подтвердил(а), продолжить', "I've confirmed, continue");
  static String get confirmResendAction =>
      _t('Məktub gəlmədi? Yenidən göndər', 'Письмо не пришло? Отправить снова', "Didn't get it? Send again");
  static String get confirmBackAction =>
      _t('Geri qayıt və e-poçtu dəyiş', 'Назад: изменить адрес', 'Go back and change email');
  static String get confirmationResent => _t(
    'Məktubu yenidən göndərdik. Gələnlər və Spam qovluğuna baxın.',
    'Письмо отправлено снова. Проверьте «Входящие» и «Спам».',
    'Sent again. Check your Inbox and Spam folders.',
  );
  static String get emailStillNotConfirmed => _t(
    'E-poçt hələ təsdiqlənməyib. Məktubdakı linkə basıb yenidən yoxlayın.',
    'Почта ещё не подтверждена. Нажмите на ссылку в письме и проверьте снова.',
    "Your email isn't confirmed yet. Tap the link in the email, then try again.",
  );
  static String get emailRateLimit => _t(
    'Çox tez-tez məktub istənildi. Bir az gözləyib yenidən cəhd edin.',
    'Слишком много запросов письма. Подождите немного и попробуйте снова.',
    'Too many emails requested. Please wait a while and try again.',
  );

  // Validasiya
  static String get invalidEmail =>
      _t(
        'E-poçtu tam yazın, məsələn: ad@gmail.com',
        'Введите полный адрес, например: ad@gmail.com',
        'Enter your full email, for example: ad@gmail.com',
      );
  static String shortPassword(int min) =>
      _t('Ən azı $min simvol', 'Не менее $min символов', 'At least $min characters');

  // Auth xətaları
  static String get invalidCredentials => _t(
    'E-poçt və ya parol yanlışdır.',
    'Неверная эл. почта или пароль.',
    'Incorrect email or password.',
  );
  static String get userAlreadyExists => _t(
    'Bu e-poçtla hesab artıq var. Daxil olun.',
    'Аккаунт с этой почтой уже существует. Войдите.',
    'An account with this email already exists. Please sign in.',
  );
  static String get emailNotConfirmed => _t(
    'E-poçt hələ təsdiqlənməyib. Gələn məktubdakı linkə basın.',
    'Почта ещё не подтверждена. Перейдите по ссылке из письма.',
    "Email isn't confirmed yet. Tap the link in the email we sent.",
  );
  static String get weakPassword =>
      _t('Parol çox zəifdir.', 'Слишком слабый пароль.', 'The password is too weak.');

  // Ana səhifə
  static String get homeTitle => _t('Salam!', 'Привет!', 'Hi there!');
  static String get subjects => _t('Fənlər', 'Предметы', 'Subjects');
  static String get streakEmpty => _t(
    'Bu gün ilk məşqinlə seriyaya başla',
    'Начни серию с первой тренировки сегодня',
    'Start your streak with your first practice today',
  );
  static String streak(int days) => _t(
    'Seriya: $days gün ardıcıl',
    'Серия: $days дн. подряд',
    'Streak: $days ${days == 1 ? 'day' : 'days'} in a row',
  );
  static String get noSubjects =>
      _t('Hələ fənn əlavə olunmayıb.', 'Предметы пока не добавлены.', 'No subjects yet.');

  // Zəif mövzular
  static String get noMasteryYet => _t(
    'Hələ cavab yoxdur. Məşq etdikcə zəif mövzular burada görünəcək.',
    'Ответов пока нет. По мере практики здесь появятся слабые темы.',
    'No answers yet. Weak topics will appear here as you practice.',
  );
  static String get weakTopics => _t('Zəif mövzular', 'Слабые темы', 'Weak topics');

  // Zəif yerlərim
  static String get weakPlacesTitle =>
      _t('Zəif yerlərim', 'Мои слабые места', 'My weak spots');
  static String get weakPlacesHint => _t(
    'Ən zəif mövzu yuxarıdadır. Mövzuya basıb yalnız onu məşq et.',
    'Самая слабая тема вверху. Нажми на тему и тренируй только её.',
    'The weakest topic is at the top. Tap a topic to practice just that one.',
  );
  static String get noQuestionsInTopic => _t(
    'Bu mövzuda hələ sual yoxdur.',
    'В этой теме пока нет вопросов.',
    'No questions in this topic yet.',
  );

  // Mövzular (cavablar yazılmır)
  static String get topicsTitle => _t('Mövzular', 'Темы', 'Topics');
  static String get topicsHint => _t(
    'Mövzunu aç, sualları ardıcıl həll et və istədiyin suala keç. Bu bölmədə cavablar yadda saxlanmır.',
    'Открой тему, решай вопросы по порядку и переходи к любому из них. В этом разделе ответы не сохраняются.',
    "Open a topic, solve questions in order and jump to any one. Answers aren't saved in this section.",
  );
  static String get searchTopics => _t('Mövzu axtar', 'Поиск темы', 'Search topics');
  static String get noTopicsFound =>
      _t('Belə mövzu tapılmadı.', 'Такой темы не найдено.', 'No such topic found.');
  static String questionCount(int n) => _t('$n sual', '$n вопр.', '$n questions');
  static String get jumpToQuestion =>
      _t('Suala keç', 'Перейти к вопросу', 'Jump to question');
  static String get previousQuestion => _t('Əvvəlki', 'Назад', 'Previous');
  static String get showAnswer => _t('Cavabı göstər', 'Показать ответ', 'Show answer');

  // Səhvlər dəftəri
  static String get mistakesBook =>
      _t('Səhvlər dəftəri', 'Тетрадь ошибок', 'Mistakes notebook');
  static String get mistakesEmpty => _t(
    'Dəftər boşdur. Səhv cavab verdiyin suallar burada toplanacaq.',
    'Тетрадь пуста. Вопросы, на которые ты ответил неверно, появятся здесь.',
    'The notebook is empty. Questions you answer wrong will be collected here.',
  );
  static String get mistakesHint => _t(
    'Hər sual 1, 3, 7 və 14 gün sonra təkrar olunur. Ardıcıl 4 dəfə düz cavab verəndə dəftərdən çıxır.',
    'Каждый вопрос повторяется через 1, 3, 7 и 14 дней. После 4 верных ответов подряд он исчезает из тетради.',
    'Each question repeats after 1, 3, 7 and 14 days. After 4 correct answers in a row it leaves the notebook.',
  );
  static String get repeatMistakes =>
      _t('Səhvləri təkrar et', 'Повторить ошибки', 'Repeat mistakes');
  static String get dueToday => _t('Bu gün təkrar', 'Повтор сегодня', 'Review today');
  static String dueInDays(int days) =>
      _t('$days gün sonra təkrar', 'Повтор через $days дн.', 'Review in $days days');
  static String rightAnswer(String right) =>
      _t('Düzgün cavab: $right', 'Правильный ответ: $right', 'Correct answer: $right');
  static String get noMistakes => _t(
    'Səhvlər dəftərin boşdur.',
    'Твоя тетрадь ошибок пуста.',
    'Your mistakes notebook is empty.',
  );

  // İmtahan hədəfi
  static String get goalTitle => _t('İmtahan hədəfi', 'Цель экзамена', 'Exam goal');
  static String get goalPromptTitle =>
      _t('İmtahanına nə qədər qalıb?', 'Сколько осталось до экзамена?', 'How long until your exam?');
  static String get goalPromptText => _t(
    'İmtahan dövrünü seç, gündəlik hədəfini qur.',
    'Выбери период экзамена и поставь дневную цель.',
    'Pick your exam period and set a daily goal.',
  );
  static String goalDaysLeft(int days) => _t(
    '$days gün qalıb',
    'Осталось $days дн.',
    '$days ${days == 1 ? 'day' : 'days'} left',
  );
  static String get goalExamToday => _t('İmtahan bu gündür!', 'Экзамен сегодня!', 'The exam is today!');
  static String get goalDateUnknown => _t(
    'İmtahan tarixi seçilməyib',
    'Дата экзамена не выбрана',
    'No exam date selected',
  );
  static String goalToday(int done, int goal) => _t(
    'Bu gün: $done / $goal sual',
    'Сегодня: $done / $goal вопросов',
    'Today: $done / $goal questions',
  );
  static String get goalReached => _t(
    'Gündəlik hədəf tamamlandı!',
    'Дневная цель выполнена!',
    'Daily goal reached!',
  );
  static String get goalPeriod => _t('İmtahan dövrü', 'Период экзамена', 'Exam period');
  static String get goalCustomDate => _t('Öz tarixim', 'Своя дата', 'My own date');
  static String get goalDaily => _t('Gündəlik hədəf (sual)', 'Дневная цель (вопросов)', 'Daily goal (questions)');
  static String get goalSave => _t('Yadda saxla', 'Сохранить', 'Save');
  static String get goalLater => _t('Sonra', 'Позже', 'Later');
  static String get goalSaveFailed =>
      _t('Hədəf saxlanmadı.', 'Не удалось сохранить цель.', "Couldn't save the goal.");

  /// Dövrün adı: tanınan kod üçün tərcümə, yoxsa bazadakı ad.
  static String periodName(String code, String fallback) => switch (code) {
    'winter' => _t('Qış dövrü', 'Зимний период', 'Winter session'),
    'summer' => _t('Yay dövrü', 'Летний период', 'Summer session'),
    _ => fallback,
  };

  // Versiya
  static String appVersion(String version, int build) =>
      _t('Versiya $version ($build)', 'Версия $version ($build)', 'Version $version ($build)');

  // Yeniləmə
  static String get updateRequiredTitle =>
      _t('Yeniləmək lazımdır', 'Требуется обновление', 'Update required');
  static String get updateRequiredText => _t(
    'Bu versiya artıq dəstəklənmir. Davam etmək üçün tətbiqin yeni versiyasını yükləyin.',
    'Эта версия больше не поддерживается. Чтобы продолжить, установите новую версию приложения.',
    'This version is no longer supported. Please install the new version of the app to continue.',
  );
  static String get updateAvailableTitle =>
      _t('Yeni versiya var', 'Доступна новая версия', 'A new version is available');
  static String get updateAvailableText => _t(
    'PrepAZ-ın yeni versiyası çıxıb. Yeniləməyi məsləhət görürük.',
    'Вышла новая версия PrepAZ. Рекомендуем обновить приложение.',
    'A new version of PrepAZ is out. We recommend updating.',
  );
  static String get updateNow => _t('Yenilə', 'Обновить', 'Update');
  static String get updateLater => _t('Sonra', 'Позже', 'Later');

  // Problem bildirişi
  static String get reportButton => _t('Xəta bildir', 'Сообщить об ошибке', 'Report a problem');
  static String get reportQuestionTitle =>
      _t('Sualda xəta var?', 'Ошибка в вопросе?', 'Problem with this question?');
  static String get reportAppTitle =>
      _t('Tətbiqdə xəta bildir', 'Сообщить об ошибке в приложении', 'Report an app problem');
  static String get reportAppHint => _t(
    'Nə baş verdi? Harada və nə vaxt? Nə qədər ətraflı yazsan, o qədər tez düzəldərik.',
    'Что произошло? Где и когда? Чем подробнее, тем быстрее мы исправим.',
    'What happened? Where and when? The more detail, the faster we can fix it.',
  );
  static String reportQuestionHint(String code) => _t(
    'Sual kodu ($code) avtomatik göndəriləcək. Xətanın nə olduğunu yaz: cavab yanlışdır, şəkil kəsikdir, variant yoxdur və s.',
    'Код вопроса ($code) будет отправлен автоматически. Опишите ошибку: неверный ответ, обрезано изображение, нет варианта и т.д.',
    'The question code ($code) is sent automatically. Describe the problem: wrong answer, cut-off image, missing option, etc.',
  );
  static String get reportDescription => _t('Açıqlama', 'Описание', 'Description');
  static String reportMinHint(int n) => _t(
    'Ən azı $n simvol yaz',
    'Напишите не менее $n символов',
    'Write at least $n characters',
  );
  static String get reportSend => _t('Göndər', 'Отправить', 'Send');
  static String get reportSent =>
      _t('Təşəkkür edirik! Bildiriş göndərildi.', 'Спасибо! Сообщение отправлено.', 'Thank you! Your report was sent.');
  static String get reportTooMany => _t(
    'Çox bildiriş göndərdin. Bir az sonra yenidən cəhd et.',
    'Слишком много сообщений. Попробуйте чуть позже.',
    'Too many reports. Please try again a bit later.',
  );

  // Sual kodu
  static String questionCode(String code) =>
      _t('Sual kodu: $code', 'Код вопроса: $code', 'Question code: $code');
  static String get codeCopied => _t('Kod kopyalandı', 'Код скопирован', 'Code copied');

  // Məşq
  static String get startQuiz => _t(
    'Bugünkü məşqə başla',
    'Начать тренировку на сегодня',
    "Start today's practice",
  );
  static String questionOf(int n, int total) =>
      _t('Sual $n / $total', 'Вопрос $n / $total', 'Question $n / $total');
  static String get check => _t('Yoxla', 'Проверить', 'Check');
  static String get dontKnow => _t('Bilmirəm', 'Не знаю', "I don't know");
  static String get nextQuestion =>
      _t('Növbəti sual', 'Следующий вопрос', 'Next question');
  static String get toResult => _t('Nəticəyə bax', 'Посмотреть результат', 'See results');
  static String get yourAnswerField => _t('Cavabınız', 'Ваш ответ', 'Your answer');
  static String get noQuestionsLeft => _t(
    'Bu gün üçün yeni sual qalmadı. Əla iş!\nSəhv etdiyin suallar təkrar vaxtı çatanda burada görünəcək.',
    'На сегодня новых вопросов нет. Отличная работа!\nВопросы с ошибками появятся здесь, когда придёт время повтора.',
    "No new questions left for today. Great job!\nQuestions you got wrong will appear here when they're due for review.",
  );
  static String get correct => _t('Düzdür!', 'Верно!', 'Correct!');
  static String wrong(String right) => _t(
    'Səhvdir. Düzgün cavab: $right',
    'Неверно. Правильный ответ: $right',
    'Wrong. Correct answer: $right',
  );
  static String get writtenPending => _t(
    'Bu cavab sonra yoxlanılacaq',
    'Этот ответ будет проверен позже',
    'This answer will be checked later',
  );
  static String get solution => _t('Həll:', 'Решение:', 'Solution:');
  static String get savedForReview => _t(
    'Bu sual təkrar üçün yadda saxlandı: sabah yenidən görəcəksən.',
    'Вопрос сохранён для повторения: завтра ты увидишь его снова.',
    "Saved for review: you'll see this question again tomorrow.",
  );
  static String get imageFailed =>
      _t('Şəkil yüklənmədi', 'Не удалось загрузить изображение', 'Image failed to load');

  // Nəticə
  static String resultTitle(String subject) =>
      _t('$subject: nəticə', '$subject: результат', '$subject: results');
  static String percentCorrect(int pct) =>
      _t('$pct% düz', '$pct% верно', '$pct% correct');
  static String get allCorrect => _t(
    'Hamısı düzdür. Sabah daha çətin suallar gələcək!',
    'Всё верно. Завтра будут вопросы сложнее!',
    'All correct. Tougher questions are coming tomorrow!',
  );
  static String wrongTitle(int n) => _t(
    'Səhvlər dəftərinə düşənlər ($n)',
    'Попали в тетрадь ошибок ($n)',
    'Added to mistakes notebook ($n)',
  );
  static String get wrongHint => _t(
    'Bunları 1, 3, 7 və 14 gün sonra yenidən görəcəksən.',
    'Ты увидишь их снова через 1, 3, 7 и 14 дней.',
    "You'll see these again in 1, 3, 7 and 14 days.",
  );
  static String yourVsRight(String given, String right) => _t(
    'Sənin cavabın: $given  ·  Düzgün: $right',
    'Твой ответ: $given  ·  Верно: $right',
    'Your answer: $given  ·  Correct: $right',
  );
  static String get backHome => _t('Ana səhifəyə qayıt', 'На главную', 'Back to home');

  // Öyrədici tur
  static String get tourGotIt => _t('Anladım', 'Понятно', 'Got it');
  static String get tourReplay =>
      _t('Öyrədicini yenidən aç', 'Открыть обучение снова', 'Replay the tour');
  static String get tourFinish => _t('Başlayaq!', 'Начнём!', "Let's go!");
  static String get tourWelcome => _t(
    'Salam! Mən sənin PrepAZ köməkçinəm. Gəl, tətbiqi birlikdə gəzək, bir dəqiqə çəkəcək.',
    'Привет! Я твой помощник в PrepAZ. Давай вместе посмотрим приложение, это займёт минуту.',
    "Hi! I'm your PrepAZ helper. Let's take a quick tour together, it only takes a minute.",
  );
  static String get tourOpenMenu => _t(
    'Əvvəlcə menyuya baxaq. Yuxarıda işıqlanan düyməyə bas.',
    'Сначала посмотрим меню. Нажми на подсвеченную кнопку вверху.',
    "Let's start with the menu. Tap the highlighted button at the top.",
  );
  static String get tourLanguage => _t(
    'Dil: tətbiqin dilini dəyişir. Azərbaycan, rus və ingilis dili var. Sualların dili dəyişmir.',
    'Язык: меняет язык приложения. Есть азербайджанский, русский и английский. Язык вопросов не меняется.',
    "Language: changes the app's language. Azerbaijani, Russian and English are available. Questions stay in their own language.",
  );
  static String get tourAppearance => _t(
    'Görünüş: gündüz və ya gecə rejimini seçirsən. Gözün yorulanda gecə rejimini aç.',
    'Оформление: выбираешь дневной или ночной режим. Когда устанут глаза, включи ночной.',
    'Appearance: choose light or dark mode. When your eyes get tired, turn on dark mode.',
  );
  static String get tourTeachers => _t(
    'Tövsiyə olunan müəllimlər: hazırlıq üçün müəllimlərin siyahısı. Onlarla birbaşa əlaqə saxlaya bilərsən.',
    'Рекомендуемые учителя: список учителей для подготовки. С ними можно связаться напрямую.',
    'Recommended teachers: a list of teachers for exam prep. You can contact them directly.',
  );
  static String get tourReport => _t(
    'Tətbiqdə xəta bildir: nəsə işləmirsə, buradan bizə yaz.',
    'Сообщить об ошибке: если что-то не работает, напиши нам отсюда.',
    "Report an app problem: if something doesn't work, tell us here.",
  );
  static String get tourSignOut => _t(
    'Çıxış: hesabından çıxırsan. İrəliləyişin itmir, yenidən daxil olanda yerindədir.',
    'Выйти: выход из аккаунта. Прогресс не пропадёт, он будет на месте, когда войдёшь снова.',
    "Sign out: leaves your account. Your progress stays safe for when you sign back in.",
  );
  static String get tourPractice => _t(
    'Hər gün buradan başla. Əvvəl təkrar etməli olduğun suallar, sonra zəif mövzuların gəlir.',
    'Начинай отсюда каждый день. Сначала вопросы на повторение, затем твои слабые темы.',
    'Start here every day. First come the questions to review, then your weak topics.',
  );
  static String get tourWeakPlaces => _t(
    'Zəif yerlərim: ən zəif olduğun mövzular. Mövzunu seç və yalnız onu məşq et.',
    'Мои слабые места: темы, где ты слабее всего. Выбери тему и тренируй только её.',
    'My weak spots: the topics you find hardest. Pick one and practice just that.',
  );
  static String get tourMistakes => _t(
    'Səhvlər dəftəri: səhv etdiyin suallar buraya düşür. Onları öyrənənə qədər yenidən qarşına çıxacaq.',
    'Тетрадь ошибок: сюда попадают вопросы, где ты ошибся. Они будут возвращаться, пока ты их не выучишь.',
    "Mistakes notebook: questions you got wrong land here. They come back until you've learned them.",
  );
  static String get tourTopics => _t(
    'Mövzular: fənnin bütün mövzuları. Axtar, mövzunu seç və sualları sıra ilə həll et.',
    'Темы: все темы предмета. Найди нужную тему и решай вопросы по порядку.',
    "Topics: all of the subject's topics. Search, pick one and solve its questions in order.",
  );
  static String get tourDone => _t(
    'Hazırsan! İndi ilk məşqinə başla. Uğurlar!',
    'Готово! Теперь начни первую тренировку. Удачи!',
    "You're all set! Now start your first practice. Good luck!",
  );

  // Menyu
  static String get menu => _t('Menyu', 'Меню', 'Menu');
  static String get languageTitle => _t('Dil', 'Язык', 'Language');
  static String get appearance => _t('Görünüş', 'Оформление', 'Appearance');
  static String get themeLight => _t('Gündüz', 'День', 'Light');
  static String get themeDark => _t('Gecə', 'Ночь', 'Dark');
  static String get themeSystem => _t('Sistem', 'Системная', 'System');

  // Tövsiyə olunan müəllimlər
  static String get teachersTitle => _t(
    'Tövsiyə olunan müəllimlər',
    'Рекомендуемые учителя',
    'Recommended teachers',
  );
  static String get teachersIntro => _t(
    'Tətbiqin məzmun komandasında yer alan təcrübəli müəllimlər. İmtahana peşəkar hazırlıq üçün onlarla birbaşa əlaqə saxlaya bilərsiniz.',
    'Опытные преподаватели из команды, работающей над содержанием приложения. Для профессиональной подготовки к экзаменам вы можете связаться с ними напрямую.',
    "Experienced teachers from the team behind the app's content. Contact them directly for professional exam preparation.",
  );
  static String get teachersEmpty => _t(
    'Məlumat tezliklə əlavə olunacaq.',
    'Информация скоро появится.',
    'Information will be added soon.',
  );
  static String get aboutTeacher => _t('Haqqında', 'О преподавателе', 'About');
  static String get lessonInPerson => _t('Əyani', 'Очно', 'In person');
  static String get lessonOnline => _t('Online', 'Онлайн', 'Online');
  static String get lessonBoth =>
      _t('Əyani və online', 'Очно и онлайн', 'In person & online');
  static String get teacherOffer =>
      _t('Hazırlıq təklifi', 'Предложение по подготовке', 'Preparation offer');
  static String get callAction => _t('Zəng et', 'Позвонить', 'Call');
  static const whatsappAction = 'WhatsApp';
  static String get contactFailed => _t(
    'Açmaq alınmadı. Nömrə kopyalandı.',
    'Не удалось открыть. Номер скопирован.',
    "Couldn't open. The number was copied.",
  );
}
