import '../../../core/constants/app_language.dart';
import '../../../core/constants/app_strings.dart';
import '../domain/release_note.dart';

String _t(String az, String ru, String en) => switch (AppStrings.language) {
  AppLanguage.az => az,
  AppLanguage.ru => ru,
  AppLanguage.en => en,
};

/// HƏR buraxılış üçün bir sətir (yeni build əlavə edəndə buraya da yaz; test yoxlayır).
/// Yenilik yoxdursa `items: () => const []`. Ən yenisi yuxarıda.
/// Mətn qısa olsun (bir sətir, emoji ilə), şagird nə qazandığını görsün. Yalnız HAZIRDA işləyən şeylər.
final releaseNotes = <ReleaseNote>[
  ReleaseNote(
    build: 13,
    version: '1.7.0',
    items: () => [
      _t(
        '🔑 Parolu unutmusan? Giriş ekranında "Parolu unutmusunuz?" düyməsinə bas, e-poçtuna gələn kodla yeni parol qoy.',
        '🔑 Забыл пароль? Нажми «Забыли пароль?» на экране входа и задай новый по коду из письма.',
        '🔑 Forgot your password? Tap "Forgot your password?" on the sign-in screen and set a new one with the code we email you.',
      ),
      _t(
        '✨ Yeniləmədən sonra nələrin dəyişdiyini burada göstərəcəyik.',
        '✨ После обновлений здесь будет видно, что нового.',
        "✨ After each update we'll show you what's new right here.",
      ),
    ],
  ),
];
