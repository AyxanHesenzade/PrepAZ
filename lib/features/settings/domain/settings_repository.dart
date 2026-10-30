import 'app_settings.dart';

abstract interface class SettingsRepository {
  /// Yadda saxlanmış ayarlar (yoxdursa ilkin dəyərlər). Sinxrondur ki, tətbiq ilk kadrdan düzgün dildə açılsın.
  AppSettings load();

  Future<void> save(AppSettings settings);
}
