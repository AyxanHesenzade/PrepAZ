import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/client_id.dart';
import 'log_event.dart';

/// `log_events` RPC (migration 019). `guard` İŞLƏDİLMİR: log xətası yenə loga düşüb dövr yaratmasın.
/// İstifadəçi serverdə sessiyadan götürülür; girişdən əvvəlki hadisələr yalnız [deviceId] ilə bağlanır.
class SupabaseLogSink implements LogSink {
  SupabaseLogSink(
    this._db, {
    required this.deviceId,
    required this.version,
    required this.platform,
  });

  final SupabaseClient _db;
  final String deviceId;
  final String version;
  final String platform;

  @override
  Future<void> send(List<LogEvent> events) => _db.rpc<dynamic>(
    'log_events',
    params: {
      'p_events': [for (final e in events) e.toJson()],
      'p_device': deviceId,
      'p_version': version,
      'p_platform': platform,
    },
  );
}

class PrefsLogStore implements LogStore {
  PrefsLogStore(this._prefs);

  static const _queueKey = 'log.queue';
  static const _deviceKey = 'log.device_id';

  final SharedPreferences _prefs;

  /// Quraşdırma üçün təsadüfi kimlik (telefonun real ID-si deyil). Girişsiz hadisələri birləşdirir.
  static String deviceId(SharedPreferences prefs) {
    final saved = prefs.getString(_deviceKey);
    if (saved != null) return saved;
    final id = newClientId();
    prefs.setString(_deviceKey, id);
    return id;
  }

  @override
  List<LogEvent> load() {
    try {
      final raw = jsonDecode(_prefs.getString(_queueKey) ?? '[]') as List;
      return [for (final e in raw) LogEvent.fromJson((e as Map).cast<String, dynamic>())];
    } on Object {
      return [];
    }
  }

  @override
  Future<void> save(List<LogEvent> events) =>
      _prefs.setString(_queueKey, jsonEncode([for (final e in events) e.toJson()]));
}
