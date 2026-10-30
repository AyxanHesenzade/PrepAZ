import 'dart:ui' show Locale;

/// Tətbiq interfeysinin dili (sualların dili bundan asılı deyil).
enum AppLanguage {
  az('az', 'Azərbaycanca'),
  ru('ru', 'Русский'),
  en('en', 'English');

  const AppLanguage(this.code, this.nativeName);

  final String code;

  /// Dilin öz adı: hər dildə eyni göstərilir ki, istifadəçi tanıyıb seçə bilsin.
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.az);
}
