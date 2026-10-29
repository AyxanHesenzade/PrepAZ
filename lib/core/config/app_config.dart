import 'package:flutter/foundation.dart';

import 'debug_defaults.dart';

/// Supabase bağlantısı.
///
/// - **Debug** (F5, ▶, `flutter run`): parametr verilməyibsə, TEST mühiti avtomatik götürülür.
/// - **Release** (`flutter build`): mühit mütləq verilməlidir, əks halda tətbiq "konfiqurasiya yoxdur"
///   göstərir. Beləcə test bazası təsadüfən real tətbiqə düşə bilməz:
///     flutter build apk --dart-define-from-file=env/prod.json
/// - Verilmiş `--dart-define-from-file` həmişə üstünlük təşkil edir (məs. debug-da prod-u yoxlamaq üçün).
abstract final class AppConfig {
  static const _urlFromEnv = String.fromEnvironment('SUPABASE_URL');
  static const _keyFromEnv = String.fromEnvironment('SUPABASE_KEY');

  static String get supabaseUrl =>
      _urlFromEnv.isNotEmpty ? _urlFromEnv : (kDebugMode ? DebugDefaults.supabaseUrl : '');

  static String get supabaseKey =>
      _keyFromEnv.isNotEmpty ? _keyFromEnv : (kDebugMode ? DebugDefaults.supabaseKey : '');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
