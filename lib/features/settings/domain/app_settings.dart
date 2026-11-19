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
    this.downloadNudgeCount = 0,
    this.downloadNudgeAt,
    this.hiddenSubjectIds = const {},
  });

  /// Ana ekranda gizlədilən fənlər (filtr). Gizlədilənlər saxlanır ki, yeni əlavə olunan fənn özü görünsün.
  final Set<int> hiddenSubjectIds;

  final AppLanguage language;
  final AppThemeMode themeMode;
  final bool tourSeen;
  final int pendingLegalVersion;
  final int whatsNewSeenBuild;

  /// Köməkçi "mövzunu yüklə" sözünü neçə dəfə deyib və sonuncu nə vaxt (null = heç vaxt).
  final int downloadNudgeCount;
  final DateTime? downloadNudgeAt;

  AppSettings copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    bool? tourSeen,
    int? pendingLegalVersion,
    int? whatsNewSeenBuild,
    int? downloadNudgeCount,
    DateTime? downloadNudgeAt,
    Set<int>? hiddenSubjectIds,
  }) => AppSettings(
    hiddenSubjectIds: hiddenSubjectIds ?? this.hiddenSubjectIds,
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    tourSeen: tourSeen ?? this.tourSeen,
    pendingLegalVersion: pendingLegalVersion ?? this.pendingLegalVersion,
    whatsNewSeenBuild: whatsNewSeenBuild ?? this.whatsNewSeenBuild,
    downloadNudgeCount: downloadNudgeCount ?? this.downloadNudgeCount,
    downloadNudgeAt: downloadNudgeAt ?? this.downloadNudgeAt,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.themeMode == themeMode &&
      other.tourSeen == tourSeen &&
      other.pendingLegalVersion == pendingLegalVersion &&
      other.whatsNewSeenBuild == whatsNewSeenBuild &&
      other.downloadNudgeCount == downloadNudgeCount &&
      other.downloadNudgeAt == downloadNudgeAt &&
      other.hiddenSubjectIds.length == hiddenSubjectIds.length &&
      other.hiddenSubjectIds.containsAll(hiddenSubjectIds);

  @override
  int get hashCode => Object.hash(
    language,
    themeMode,
    tourSeen,
    pendingLegalVersion,
    whatsNewSeenBuild,
    downloadNudgeCount,
    downloadNudgeAt,
    Object.hashAllUnordered(hiddenSubjectIds),
  );
}
