import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';
import 'features/settings/data/prefs_settings_repository.dart';
import 'features/settings/presentation/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const ConfigMissingApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseKey,
  );
  final prefs = await SharedPreferences.getInstance();

  // retry: null — uğursuz sorğu öz-özünə təkrarlanmır, istifadəçi "Yenidən cəhd et" basır.
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        settingsRepositoryProvider.overrideWithValue(PrefsSettingsRepository(prefs)),
        mascotMotionProvider.overrideWithValue(true),
      ],
      child: const PrepAzApp(),
    ),
  );
}
