import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_strings.dart';
import 'core/config/app_config.dart';
import 'core/config/app_version.dart';
import 'core/logging/app_log.dart';
import 'core/logging/device_info.dart';
import 'core/logging/log_data.dart';
import 'core/providers.dart';
import 'features/browse/data/prefs_topic_draft_repository.dart';
import 'features/browse/presentation/browse_providers.dart';
import 'features/offline/data/file_image_store.dart';
import 'features/offline/data/local_database.dart';
import 'features/offline/presentation/offline_providers.dart';
import 'features/reminders/data/local_reminder_scheduler.dart';
import 'features/reminders/presentation/reminder_providers.dart';
import 'features/settings/data/prefs_settings_repository.dart';
import 'features/settings/presentation/settings_providers.dart';
import 'features/whats_new/presentation/whats_new_providers.dart';

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
  await _startLogging(prefs);
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
        whatsNewEnabledProvider.overrideWithValue(true),
        reminderSchedulerProvider.overrideWithValue(
          LocalReminderScheduler(prefs, channelName: AppStrings.reminderChannel),
        ),
        localDatabaseProvider.overrideWithValue(LocalDatabase.open()),
        imageStoreProvider.overrideWithValue(
          FileImageStore(Directory('${support.path}${Platform.pathSeparator}offline_images')),
        ),
      ],
      child: const PrepAzApp(),
    ),
  );
}

/// Admin panelin "Loglar" bölməsi üçün: giriş addımları, texniki xətalar, çökmələr.
/// Log heç vaxt tətbiqi dayandırmamalıdır: hər şey try içindədir.
Future<void> _startLogging(SharedPreferences prefs) async {
  try {
    final version = AppVersion.fromJson(
      jsonDecode(await rootBundle.loadString(AppVersion.assetPath)) as Map<String, dynamic>,
    );
    final phone = await readPhoneInfo();
    final logger = EventLogger(
      sink: SupabaseLogSink(
        Supabase.instance.client,
        deviceId: PrefsLogStore.deviceId(prefs),
        // debug-dan (F5) gələnlər real istifadəçilərinkindən ayrılsın
        version: '${version.version}+${version.build}${kDebugMode ? ' debug' : ''}',
        platform: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        info: () => {...phone, ...readScreenInfo()},
      ),
      store: PrefsLogStore(prefs),
    );
    AppLog.install(logger);

    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      AppLog.flutterError(details);
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLog.crash(error, stack);
      return false; // defolt davranış (konsola yazmaq) qalsın
    };
    // arxa fona keçəndə və qayıdanda növbə göndərilir (yolda internet gəlib-gedir)
    AppLifecycleListener(
      onPause: () => unawaited(AppLog.flush()),
      onResume: () => unawaited(AppLog.flush()),
    );
    AppLog.info(
      'app_open',
      meta: {'signed_in': Supabase.instance.client.auth.currentSession != null},
    );
  } on Object {
    AppLog.uninstall();
  }
}
