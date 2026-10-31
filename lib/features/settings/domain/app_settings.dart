import '../../../core/constants/app_language.dart';

/// Görünüş rejimi. Flutter-in ThemeMode-u domain-ə girmir, presentation-da çevrilir.
enum AppThemeMode { system, light, dark }

/// İstifadəçinin tətbiq ayarları: interfeys dili, gündüz/gecə rejimi və öyrədici turun göstərilib-göstərilmədiyi.
class AppSettings {
  const AppSettings({
    this.language = AppLanguage.az,
    this.themeMode = AppThemeMode.system,
    this.tourSeen = false,
  });

  final AppLanguage language;
  final AppThemeMode themeMode;
  final bool tourSeen;

  AppSettings copyWith({AppLanguage? language, AppThemeMode? themeMode, bool? tourSeen}) => AppSettings(
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    tourSeen: tourSeen ?? this.tourSeen,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.themeMode == themeMode &&
      other.tourSeen == tourSeen;

  @override
  int get hashCode => Object.hash(language, themeMode, tourSeen);
}
