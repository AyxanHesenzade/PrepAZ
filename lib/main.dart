import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const ConfigMissingApp());
    return;
  }

  await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseKey);

  // retry: null — uğursuz sorğu öz-özünə təkrarlanmır, istifadəçi "Yenidən cəhd et" basır.
  runApp(ProviderScope(retry: (_, _) => null, child: const PrepAzApp()));
}
