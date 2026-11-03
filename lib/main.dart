import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';
import 'features/browse/data/prefs_topic_draft_repository.dart';
import 'features/browse/presentation/browse_providers.dart';
import 'features/offline/data/file_image_store.dart';
import 'features/offline/data/local_database.dart';
import 'features/offline/presentation/offline_providers.dart';
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
  // Yüklənmiş mövzuların şəkilləri sistemin təmizləyə bilməyəcəyi qovluqda saxlanır (cache yox).
  final support = await getApplicationSupportDirectory();

  // retry: null — uğursuz sorğu öz-özünə təkrarlanmır, istifadəçi "Yenidən cəhd et" basır.
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        settingsRepositoryProvider.overrideWithValue(PrefsSettingsRepository(prefs)),
        topicDraftRepositoryProvider.overrideWithValue(
          PrefsTopicDraftRepository(prefs, () => Supabase.instance.client.auth.currentUser?.id),
        ),
        mascotMotionProvider.overrideWithValue(true),
        localDatabaseProvider.overrideWithValue(LocalDatabase.open()),
        imageStoreProvider.overrideWithValue(
          FileImageStore(Directory('${support.path}${Platform.pathSeparator}offline_images')),
        ),
      ],
      child: const PrepAzApp(),
    ),
  );
}
