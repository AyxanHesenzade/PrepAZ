import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_config.dart';
import '../domain/app_config_repository.dart';

class SupabaseAppConfigRepository implements AppConfigRepository {
  const SupabaseAppConfigRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<AppConfig?> getConfig() async {
    try {
      final row = await _db.from('app_config').select().eq('id', 1).maybeSingle();
      if (row == null) return null;
      return appConfigFromRow(row);
    } catch (_) {
      // internet yoxdur və ya cədvəl hələ yoxdur: istifadəçi bloklanmır
      return null;
    }
  }
}

AppConfig appConfigFromRow(Map<String, dynamic> row) => AppConfig(
      minVersion: row['min_version'] as String,
      latestVersion: row['latest_version'] as String,
      updateUrl: row['update_url'] as String?,
    );
