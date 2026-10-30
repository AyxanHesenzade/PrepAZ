import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Yaddaşda saxlayır (testlər və `main.dart`-ın override etmədiyi hallar üçün).
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.current = const AppSettings()]);

  AppSettings current;

  @override
  AppSettings load() => current;

  @override
  Future<void> save(AppSettings settings) async => current = settings;
}
