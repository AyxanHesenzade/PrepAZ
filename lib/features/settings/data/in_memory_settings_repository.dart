import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Yaddaşda saxlayır (testlər və `main.dart`-ın override etmədiyi hallar üçün).
/// Tur defolt olaraq görülmüş sayılır: onun animasiyası sonsuzdur, adi testlərdə açılmamalıdır.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.current = const AppSettings(tourSeen: true)]);

  AppSettings current;

  @override
  AppSettings load() => current;

  @override
  Future<void> save(AppSettings settings) async => current = settings;
}
