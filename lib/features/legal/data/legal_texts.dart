import '../../../core/constants/app_language.dart';
import '../domain/legal_document.dart';

/// Hüquqi mətnlər. Mahiyyət dəyişəndə `currentLegalVersion` və `AppStrings.legalLastUpdated` da dəyişir.
List<LegalSection> legalSections(LegalDocument document, AppLanguage language) => switch ((document, language)) {
  (LegalDocument.terms, AppLanguage.az) => _termsAz,
  (LegalDocument.terms, AppLanguage.ru) => _termsRu,
  (LegalDocument.terms, AppLanguage.en) => _termsEn,
  (LegalDocument.privacy, AppLanguage.az) => _privacyAz,
  (LegalDocument.privacy, AppLanguage.ru) => _privacyRu,
  (LegalDocument.privacy, AppLanguage.en) => _privacyEn,
};

const _termsAz = [
  LegalSection(
    '1. Ümumi',
    'PrepAZ buraxılış və qəbul imtahanlarına hazırlıq üçün mobil tətbiqdir. Tətbiqin sahibi: Ayxan Həsənzadə (fiziki şəxs). '
        'Tətbiqdən istifadə etməklə bu şərtləri qəbul edirsiniz.',
  ),
  LegalSection(
    '2. Yaş',
    '18 yaşdan kiçik istifadəçilər tətbiqdən valideyn və ya qanuni nümayəndəsinin razılığı ilə istifadə edir.',
  ),
  LegalSection(
    '3. Hesab',
    'Qeydiyyat üçün işlək e-poçt və şifrə lazımdır. Şifrənizin qorunmasına özünüz cavabdehsiniz. Hesabınızı başqasına verməyin.',
  ),
  LegalSection(
    '4. Xidmət',
    'PrepAZ suallar, izahlar, səhvlər dəftəri və gündəlik hədəflər təqdim edir. Xidmətin funksiyaları dəyişə və ya müvəqqəti dayana bilər. '
        'Yeniləmə tələb olunarsa, tətbiqin köhnə versiyası işləməyə bilər.',
  ),
  LegalSection(
    '5. Nəticəyə zəmanət yoxdur',
    'Tətbiq hazırlığa kömək edir, amma imtahanda müəyyən bal və ya qəbul zəmanəti vermir. Tətbiqdəki faizlər, "zəif mövzular" və imtahana '
        'qalan günlər yalnız bələdçidir. Rəsmi tarix və qaydaları rəsmi mənbələrdən yoxlayın.',
  ),
  LegalSection(
    '6. Məzmun',
    'Sualları diqqətlə yoxlayırıq, lakin səhv ola bilər. Səhv görsəniz, "Xəta bildir" düyməsi ilə bizə yazın.',
  ),
  LegalSection(
    '7. Əqli mülkiyyət',
    'Tətbiqin dizaynı, kodu və adı qorunur. Sualları və izahları icazəsiz köçürmək, yaymaq, satmaq və ya avtomatik toplamaq olmaz. '
        'Məzmun yalnız şəxsi hazırlıq üçündür.',
  ),
  LegalSection(
    '8. Qadağandır',
    'Tətbiqin təhlükəsizliyini pozmaq, başqasının hesabına girmək, tətbiqi kopyalamaq və ya dəyişdirmək, yalançı və ya təhqiredici bildirişlər göndərmək.',
  ),
  LegalSection(
    '9. Tövsiyə olunan müəllimlər',
    'Müəllim məlumatları tanışlıq üçündür. Müəllimlə razılaşma, ödəniş və dərsin keyfiyyəti sizinlə müəllim arasındadır, PrepAZ bu razılaşmanın tərəfi deyil.',
  ),
  LegalSection(
    '10. Ödəniş',
    'Tətbiq hazırda pulsuzdur. Gələcəkdə ödənişli funksiyalar əlavə oluna bilər: qiymət və şərtlər ödənişdən əvvəl göstəriləcək.',
  ),
  LegalSection(
    '11. Hesabın dayandırılması',
    'Şərtləri pozan hesab dayandırıla bilər. Hesabınızı istənilən vaxt yan menyudakı "Hesabı sil" bölməsindən silə bilərsiniz (Məxfilik siyasəti, bənd 6).',
  ),
  LegalSection(
    '12. Məsuliyyət',
    'Tətbiq "olduğu kimi" təqdim olunur. Qanunun icazə verdiyi həddə internet, cihaz və ya xidmət fasiləsindən yaranan itkilərə görə məsuliyyət daşımırıq.',
  ),
  LegalSection(
    '13. Dəyişikliklər və qanun',
    'Şərtlər dəyişə bilər, vacib dəyişikliklər tətbiqdə bildiriləcək. Azərbaycan Respublikasının qanunvericiliyi tətbiq olunur.',
  ),
  LegalSection(
    '14. Əlaqə',
    'Yan menyuda "Tətbiqdə xəta bildir" bölməsindən bizə yaza bilərsiniz.',
  ),
];

const _termsRu = [
  LegalSection(
    '1. Общие положения',
    'PrepAZ — мобильное приложение для подготовки к выпускным и вступительным экзаменам. Владелец приложения: Айхан Гасанзаде (физическое лицо). '
        'Используя приложение, вы принимаете эти условия.',
  ),
  LegalSection(
    '2. Возраст',
    'Пользователи младше 18 лет используют приложение с согласия родителя или законного представителя.',
  ),
  LegalSection(
    '3. Аккаунт',
    'Для регистрации нужны действующий e-mail и пароль. Вы сами отвечаете за сохранность пароля. Не передавайте аккаунт другим людям.',
  ),
  LegalSection(
    '4. Сервис',
    'PrepAZ предоставляет вопросы, объяснения, тетрадь ошибок и ежедневные цели. Функции сервиса могут меняться или временно приостанавливаться. '
        'Если потребуется обновление, старая версия приложения может перестать работать.',
  ),
  LegalSection(
    '5. Результат не гарантируется',
    'Приложение помогает готовиться, но не гарантирует определённый балл или поступление. Проценты, «слабые темы» и количество дней до экзамена '
        'носят справочный характер. Официальные даты и правила проверяйте в официальных источниках.',
  ),
  LegalSection(
    '6. Содержание',
    'Мы внимательно проверяем вопросы, но в них возможны ошибки. Если вы заметили ошибку, напишите нам кнопкой «Сообщить об ошибке».',
  ),
  LegalSection(
    '7. Интеллектуальная собственность',
    'Дизайн, код и название приложения защищены. Запрещено без разрешения копировать, распространять, продавать или автоматически собирать вопросы и объяснения. '
        'Материалы предназначены только для личной подготовки.',
  ),
  LegalSection(
    '8. Запрещено',
    'Нарушать безопасность приложения, входить в чужой аккаунт, копировать или изменять приложение, отправлять ложные или оскорбительные сообщения.',
  ),
  LegalSection(
    '9. Рекомендованные преподаватели',
    'Сведения о преподавателях даны для ознакомления. Договорённость, оплата и качество занятий — вопрос между вами и преподавателем, PrepAZ не является стороной этой договорённости.',
  ),
  LegalSection(
    '10. Оплата',
    'Сейчас приложение бесплатно. В будущем могут появиться платные функции: цена и условия будут показаны до оплаты.',
  ),
  LegalSection(
    '11. Блокировка аккаунта',
    'Аккаунт, нарушающий условия, может быть заблокирован. Вы можете в любой момент удалить аккаунт в боковом меню, раздел «Удалить аккаунт» (Политика конфиденциальности, п. 6).',
  ),
  LegalSection(
    '12. Ответственность',
    'Приложение предоставляется «как есть». В пределах, допустимых законом, мы не отвечаем за потери из-за перебоев интернета, устройства или сервиса.',
  ),
  LegalSection(
    '13. Изменения и право',
    'Условия могут меняться, о важных изменениях будет сообщено в приложении. Применяется законодательство Азербайджанской Республики.',
  ),
  LegalSection(
    '14. Контакты',
    'Написать нам можно в боковом меню, раздел «Сообщить об ошибке в приложении».',
  ),
];

const _termsEn = [
  LegalSection(
    '1. General',
    'PrepAZ is a mobile app for preparing for school-leaving and university entrance exams. The app is owned by Ayxan Hasanzade (an individual). '
        'By using the app, you accept these terms.',
  ),
  LegalSection(
    '2. Age',
    'Users under 18 use the app with the consent of a parent or legal guardian.',
  ),
  LegalSection(
    '3. Account',
    'You need a working email address and a password to register. You are responsible for keeping your password safe. Do not share your account.',
  ),
  LegalSection(
    '4. Service',
    'PrepAZ provides questions, explanations, a mistakes notebook and daily goals. Features may change or be temporarily unavailable. '
        'If an update is required, older versions of the app may stop working.',
  ),
  LegalSection(
    '5. No guarantee of results',
    'The app helps you prepare but does not guarantee a particular score or admission. Percentages, "weak topics" and the days left until the exam '
        'are for guidance only. Check official dates and rules with official sources.',
  ),
  LegalSection(
    '6. Content',
    'We check questions carefully, but they may contain mistakes. If you find one, tell us with the "Report" button.',
  ),
  LegalSection(
    '7. Intellectual property',
    'The app\'s design, code and name are protected. You may not copy, distribute, sell or automatically collect questions and explanations without permission. '
        'Content is for personal preparation only.',
  ),
  LegalSection(
    '8. Prohibited',
    'Breaking the app\'s security, accessing another person\'s account, copying or modifying the app, sending false or abusive reports.',
  ),
  LegalSection(
    '9. Recommended teachers',
    'Teacher details are for information only. Any agreement, payment and lesson quality are between you and the teacher. PrepAZ is not a party to that agreement.',
  ),
  LegalSection(
    '10. Payment',
    'The app is currently free. Paid features may be added in the future: prices and terms will be shown before you pay.',
  ),
  LegalSection(
    '11. Account suspension',
    'Accounts that break these terms may be suspended. You can delete your account at any time from the side menu, under "Delete account" (Privacy Policy, section 6).',
  ),
  LegalSection(
    '12. Liability',
    'The app is provided "as is". To the extent the law allows, we are not liable for losses caused by internet, device or service interruptions.',
  ),
  LegalSection(
    '13. Changes and governing law',
    'These terms may change, and important changes will be announced in the app. The laws of the Republic of Azerbaijan apply.',
  ),
  LegalSection(
    '14. Contact',
    'You can write to us from the side menu, under "Report an app problem".',
  ),
];

const _privacyAz = [
  LegalSection(
    '1. Topladığımız məlumatlar',
    '• Hesab: e-poçt və şifrə (şifrə açıq mətn kimi saxlanmır).\n'
        '• Təhsil məlumatları: cavablarınız, səhvləriniz, seriyanız, mövzu nəticələriniz.\n'
        '• Hədəf: seçdiyiniz imtahan dövrü və gündəlik sual hədəfi.\n'
        '• Bildirişlər: xəta bildirişinin mətni, sual kodu, tətbiq versiyası.\n'
        '• Razılıq: qəbul etdiyiniz sənəd versiyası və vaxtı.\n'
        '• Telefonda: dil, görünüş və öyrədicinin göstərilməsi kimi ayarlar.',
  ),
  LegalSection(
    '2. Toplamadıqlarımız',
    'Kameraya, kontaktlara, məkana və fayllara giriş istəmirik. Reklam və analitika xidməti işlətmirik.',
  ),
  LegalSection(
    '3. Məqsəd',
    'Hesabınızı işlətmək, nəticələrinizi saxlamaq, zəif mövzularınızı göstərmək və gündəlik suallarınızı seçmək, xətaları düzəltmək, təhlükəsizliyi qorumaq.',
  ),
  LegalSection(
    '4. Harada saxlanır',
    'Məlumatlar Supabase xidmətində, Avropa İttifaqında (Frankfurt, Almaniya) saxlanır, yəni Azərbaycandan kənara ötürülür. '
        'Bağlantı şifrələnir, digər istifadəçilər sizin məlumatınızı görə bilmir.',
  ),
  LegalSection(
    '5. Paylaşma',
    'Məlumatınızı satmırıq və reklam üçün vermirik. Yalnız xidmətin işləməsi üçün lazım olan texniki provayderlə (Supabase) və qanunla tələb olunarsa, səlahiyyətli orqanla paylaşırıq.',
  ),
  LegalSection(
    '6. Saxlama müddəti və silmə',
    'Məlumatlar hesab açıq qaldıqca saxlanır. Yan menyudakı "Hesabı sil" bölməsindən hesabınızı silə bilərsiniz: hesabınız və ona bağlı məlumatlar '
        'dərhal silinir, bu geri qaytarılmır. Ehtiyat nüsxələrdə qalan məlumat 30 gün ərzində silinir.',
  ),
  LegalSection(
    '7. Hüquqlarınız',
    'Məlumatınızı görmək, düzəltmək, silmək və razılığı geri götürmək. Razılığı geri götürmək hesabın silinməsi deməkdir.',
  ),
  LegalSection(
    '8. 18 yaşdan kiçiklər',
    'Tətbiq şagirdlər üçün olduğundan, 18 yaşdan kiçiklər valideyn razılığı ilə istifadə edir. Valideyn hesabın silinməsini "Tətbiqdə xəta bildir" bölməsindən də istəyə bilər.',
  ),
  LegalSection(
    '9. Dəyişikliklər və əlaqə',
    'Vacib dəyişikliklər tətbiqdə bildiriləcək. Əlaqə: yan menyuda "Tətbiqdə xəta bildir" bölməsi. Məlumatlara cavabdeh şəxs: Ayxan Həsənzadə.',
  ),
];

const _privacyRu = [
  LegalSection(
    '1. Какие данные мы собираем',
    '• Аккаунт: e-mail и пароль (пароль не хранится в открытом виде).\n'
        '• Учебные данные: ваши ответы, ошибки, серия, результаты по темам.\n'
        '• Цель: выбранный экзаменационный период и дневная цель по вопросам.\n'
        '• Сообщения: текст сообщения об ошибке, код вопроса, версия приложения.\n'
        '• Согласие: принятая версия документов и время.\n'
        '• На телефоне: настройки языка, оформления и показа обучения.',
  ),
  LegalSection(
    '2. Что мы не собираем',
    'Мы не запрашиваем доступ к камере, контактам, местоположению и файлам. Мы не используем рекламные и аналитические сервисы.',
  ),
  LegalSection(
    '3. Цель',
    'Работа вашего аккаунта, сохранение результатов, показ слабых тем и подбор ежедневных вопросов, исправление ошибок, обеспечение безопасности.',
  ),
  LegalSection(
    '4. Где хранятся данные',
    'Данные хранятся в сервисе Supabase в Европейском союзе (Франкфурт, Германия), то есть передаются за пределы Азербайджана. '
        'Соединение шифруется, другие пользователи не видят ваши данные.',
  ),
  LegalSection(
    '5. Передача данных',
    'Мы не продаём ваши данные и не передаём их для рекламы. Мы передаём их только техническому поставщику, необходимому для работы сервиса (Supabase), и уполномоченным органам, если этого требует закон.',
  ),
  LegalSection(
    '6. Срок хранения и удаление',
    'Данные хранятся, пока аккаунт открыт. Аккаунт можно удалить в боковом меню, раздел «Удалить аккаунт»: аккаунт и связанные с ним данные '
        'удаляются сразу и безвозвратно. Данные в резервных копиях удаляются в течение 30 дней.',
  ),
  LegalSection(
    '7. Ваши права',
    'Просматривать, исправлять и удалять свои данные, отзывать согласие. Отзыв согласия означает удаление аккаунта.',
  ),
  LegalSection(
    '8. Пользователи младше 18 лет',
    'Приложение предназначено для школьников, поэтому пользователи младше 18 лет используют его с согласия родителя. Родитель также может запросить удаление аккаунта в разделе «Сообщить об ошибке в приложении».',
  ),
  LegalSection(
    '9. Изменения и контакты',
    'О важных изменениях будет сообщено в приложении. Контакты: боковое меню, раздел «Сообщить об ошибке в приложении». Ответственное за данные лицо: Айхан Гасанзаде.',
  ),
];

const _privacyEn = [
  LegalSection(
    '1. Data we collect',
    '• Account: email and password (the password is not stored in plain text).\n'
        '• Study data: your answers, mistakes, streak and topic results.\n'
        '• Goal: your chosen exam period and daily question goal.\n'
        '• Reports: the report text, question code and app version.\n'
        '• Consent: the document version you accepted and when.\n'
        '• On your phone: language, appearance and tutorial settings.',
  ),
  LegalSection(
    '2. What we do not collect',
    'We do not ask for access to your camera, contacts, location or files. We do not use advertising or analytics services.',
  ),
  LegalSection(
    '3. Purpose',
    'Running your account, saving your results, showing your weak topics and choosing your daily questions, fixing problems and keeping the service secure.',
  ),
  LegalSection(
    '4. Where data is stored',
    'Data is stored with Supabase in the European Union (Frankfurt, Germany), which means it is transferred outside Azerbaijan. '
        'The connection is encrypted, and other users cannot see your data.',
  ),
  LegalSection(
    '5. Sharing',
    'We do not sell your data or give it to advertisers. We share it only with the technical provider needed to run the service (Supabase) and with competent authorities if the law requires it.',
  ),
  LegalSection(
    '6. Retention and deletion',
    'Data is kept while your account is open. You can delete your account from the side menu, under "Delete account": your account and related data '
        'are deleted immediately and cannot be restored. Data left in backups is deleted within 30 days.',
  ),
  LegalSection(
    '7. Your rights',
    'You can view, correct and delete your data and withdraw your consent. Withdrawing consent means deleting your account.',
  ),
  LegalSection(
    '8. Users under 18',
    'The app is for school students, so users under 18 use it with a parent\'s consent. A parent can also ask for the account to be deleted under "Report an app problem".',
  ),
  LegalSection(
    '9. Changes and contact',
    'Important changes will be announced in the app. Contact: side menu, "Report an app problem". Person responsible for the data: Ayxan Hasanzade.',
  ),
];
