import '../../../core/constants/app_language.dart';

/// Görünüş rejimi. Flutter-in ThemeMode-u domain-ə girmir, presentation-da çevrilir.
enum AppThemeMode { system, light, dark }

/// İstifadəçinin tətbiq ayarları: interfeys dili, gündüz/gecə rejimi, öyrədici turun göstərilib-göstərilmədiyi, bazaya hələ yazılmamış razılıq versiyası (0 = yoxdur)
/// və "Yeniliklər" pəncərəsinin son göstərildiyi build (0 = heç vaxt).
class AppSettings {
  const AppSettings({
    this.language = AppLanguage.az,
    this.themeMode = AppThemeMode.system,
    this.tourSeen = false,
    this.pendingLegalVersion = 0,
    this.whatsNewSeenBuild = 0,
  });

  final AppLanguage language;
  final AppThemeMode themeMode;
  final bool tourSeen;
  final int pendingLegalVersion;
  final int whatsNewSeenBuild;

  AppSettings copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    bool? tourSeen,
    int? pendingLegalVersion,
    int? whatsNewSeenBuild,
  }) => AppSettings(
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    tourSeen: tourSeen ?? this.tourSeen,
    pendingLegalVersion: pendingLegalVersion ?? this.pendingLegalVersion,
    whatsNewSeenBuild: whatsNewSeenBuild ?? this.whatsNewSeenBuild,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.themeMode == themeMode &&
      other.tourSeen == tourSeen &&
      other.pendingLegalVersion == pendingLegalVersion &&
      other.whatsNewSeenBuild == whatsNewSeenBuild;

  @override
  int get hashCode => Object.hash(
    language,
    themeMode,
    tourSeen,
    pendingLegalVersion,
    whatsNewSeenBuild,
  );
}
