import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_language.dart';
import '../../../core/error/app_exception.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Ayarlar telefonda SharedPreferences-də saxlanır.
class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository(this._prefs);

  static const _languageKey = 'settings.language';
  static const _themeKey = 'settings.theme';
  static const _tourSeenKey = 'settings.tour_seen';
  static const _pendingLegalKey = 'settings.legal_pending';
  static const _whatsNewKey = 'settings.whats_new_seen';
  static const _nudgeCountKey = 'settings.download_nudge_count';
  static const _nudgeAtKey = 'settings.download_nudge_at';
  static const _hiddenSubjectsKey = 'settings.hidden_subjects';

  final SharedPreferences _prefs;

  @override
  AppSettings load() {
    final theme = _prefs.getString(_themeKey);
    return AppSettings(
      language: AppLanguage.fromCode(_prefs.getString(_languageKey)),
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == theme,
        orElse: () => AppThemeMode.system,
      ),
      tourSeen: _prefs.getBool(_tourSeenKey) ?? false,
      pendingLegalVersion: _prefs.getInt(_pendingLegalKey) ?? 0,
      whatsNewSeenBuild: _prefs.getInt(_whatsNewKey) ?? 0,
      downloadNudgeCount: _prefs.getInt(_nudgeCountKey) ?? 0,
      downloadNudgeAt: switch (_prefs.getInt(_nudgeAtKey)) {
        final ms? when ms > 0 => DateTime.fromMillisecondsSinceEpoch(ms),
        _ => null,
      },
      hiddenSubjectIds: {
        for (final s in _prefs.getStringList(_hiddenSubjectsKey) ?? const <String>[])
          ?int.tryParse(s),
      },
    );
  }

  @override
  Future<void> save(AppSettings settings) => guard(() async {
    await _prefs.setString(_languageKey, settings.language.code);
    await _prefs.setString(_themeKey, settings.themeMode.name);
    await _prefs.setBool(_tourSeenKey, settings.tourSeen);
    await _prefs.setInt(_pendingLegalKey, settings.pendingLegalVersion);
    await _prefs.setInt(_whatsNewKey, settings.whatsNewSeenBuild);
    await _prefs.setInt(_nudgeCountKey, settings.downloadNudgeCount);
    await _prefs.setInt(_nudgeAtKey, settings.downloadNudgeAt?.millisecondsSinceEpoch ?? 0);
    await _prefs.setStringList(_hiddenSubjectsKey, [for (final id in settings.hiddenSubjectIds) '$id']);
  });
}
