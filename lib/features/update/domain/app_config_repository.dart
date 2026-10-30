import 'app_config.dart';

abstract interface class AppConfigRepository {
  /// Tənzimləmələr. Oxuna bilməsə null: yoxlama tətbiqi bloklamamalıdır.
  Future<AppConfig?> getConfig();
}
