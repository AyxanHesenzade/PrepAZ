import '../../../core/constants/app_language.dart';

/// Görünüş rejimi. Flutter-in ThemeMode-u domain-ə girmir, presentation-da çevrilir.
enum AppThemeMode { system, light, dark }

/// İstifadəçinin tətbiq ayarları: interfeys dili və gündüz/gecə rejimi.
class AppSettings {
  const AppSettings({this.language = AppLanguage.az, this.themeMode = AppThemeMode.system});

  final AppLanguage language;
  final AppThemeMode themeMode;

  AppSettings copyWith({AppLanguage? language, AppThemeMode? themeMode}) =>
      AppSettings(language: language ?? this.language, themeMode: themeMode ?? this.themeMode);

  @override
  bool operator ==(Object other) =>
      other is AppSettings && other.language == language && other.themeMode == themeMode;

  @override
  int get hashCode => Object.hash(language, themeMode);
}
