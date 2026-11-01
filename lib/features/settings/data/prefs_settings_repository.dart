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

  final SharedPreferences _prefs;

  @override
  AppSettings load() {
    final theme = _prefs.getString(_themeKey);
    return AppSettings(
      language: AppLanguage.fromCode(_prefs.getString(_languageKey)),
      themeMode: AppThemeMode.values.firstWhere((m) => m.name == theme, orElse: () => AppThemeMode.system),
      tourSeen: _prefs.getBool(_tourSeenKey) ?? false,
      pendingLegalVersion: _prefs.getInt(_pendingLegalKey) ?? 0,
    );
  }

  @override
  Future<void> save(AppSettings settings) => guard(() async {
        await _prefs.setString(_languageKey, settings.language.code);
        await _prefs.setString(_themeKey, settings.themeMode.name);
        await _prefs.setBool(_tourSeenKey, settings.tourSeen);
        await _prefs.setInt(_pendingLegalKey, settings.pendingLegalVersion);
      });
}
