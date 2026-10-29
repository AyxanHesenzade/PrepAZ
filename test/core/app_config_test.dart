import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/config/app_config.dart';
import 'package:prep_az/core/config/debug_defaults.dart';

void main() {
  test('debug mode works without any --dart-define (the app opens from any Run button)', () {
    expect(AppConfig.isConfigured, isTrue);
    expect(AppConfig.supabaseUrl, DebugDefaults.supabaseUrl);
    expect(AppConfig.supabaseKey, DebugDefaults.supabaseKey);
  });

  test('debug defaults are exactly env/test.json (they must not drift apart)', () {
    final json = jsonDecode(File('env/test.json').readAsStringSync()) as Map<String, dynamic>;
    expect(DebugDefaults.supabaseUrl, json['SUPABASE_URL']);
    expect(DebugDefaults.supabaseKey, json['SUPABASE_KEY']);
  });

  test('only the public publishable key is embedded, never a service_role/secret key', () {
    expect(DebugDefaults.supabaseKey, startsWith('sb_publishable_'));
    expect(DebugDefaults.supabaseKey, isNot(contains('service_role')));
  });
}
