import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_language.dart';
import '../../../core/constants/app_strings.dart';
import '../data/in_memory_settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// `main.dart` burada SharedPreferences-li repository verir; testlərdə fake.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => InMemorySettingsRepository());

final settingsControllerProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final settings = ref.read(settingsRepositoryProvider).load();
    AppStrings.language = settings.language;
    return settings;
  }

  Future<void> setLanguage(AppLanguage language) => _update(state.copyWith(language: language));

  Future<void> setThemeMode(AppThemeMode mode) => _update(state.copyWith(themeMode: mode));

  Future<void> setTourSeen() => _update(state.copyWith(tourSeen: true));

  Future<void> acceptLegal(int version) => _update(state.copyWith(pendingLegalVersion: version));

  Future<void> clearPendingLegal() => _update(state.copyWith(pendingLegalVersion: 0));

  Future<void> _update(AppSettings next) async {
    if (next == state) return;
    AppStrings.language = next.language;
    state = next;
    try {
      await ref.read(settingsRepositoryProvider).save(next);
    } catch (_) {
      // saxlanmasa da ayar bu sessiyada işləyir; istifadəçiyə xəta göstərməyə dəyməz
    }
  }
}

extension AppThemeModeFlutter on AppThemeMode {
  ThemeMode get flutter => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
