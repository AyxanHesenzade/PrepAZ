import '../../../core/constants/app_language.dart';

/// Görünüş rejimi. Flutter-in ThemeMode-u domain-ə girmir, presentation-da çevrilir.
enum AppThemeMode { system, light, dark }

/// İstifadəçinin tətbiq ayarları: interfeys dili, gündüz/gecə rejimi, öyrədici turun göstərilib-göstərilmədiyi və bazaya hələ yazılmamış razılıq versiyası (0 = yoxdur).
class AppSettings {
  const AppSettings({
    this.language = AppLanguage.az,
    this.themeMode = AppThemeMode.system,
    this.tourSeen = false,
    this.pendingLegalVersion = 0,
  });

  final AppLanguage language;
  final AppThemeMode themeMode;
  final bool tourSeen;
  final int pendingLegalVersion;

  AppSettings copyWith({AppLanguage? language, AppThemeMode? themeMode, bool? tourSeen, int? pendingLegalVersion}) => AppSettings(
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    tourSeen: tourSeen ?? this.tourSeen,
    pendingLegalVersion: pendingLegalVersion ?? this.pendingLegalVersion,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.themeMode == themeMode &&
      other.tourSeen == tourSeen &&
      other.pendingLegalVersion == pendingLegalVersion;

  @override
  int get hashCode => Object.hash(language, themeMode, tourSeen, pendingLegalVersion);
}
