import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_language.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/legal/presentation/legal_acceptance_recorder.dart';
import 'features/update/presentation/update_gate.dart';
import 'features/settings/presentation/settings_providers.dart';

class PrepAzApp extends ConsumerWidget {
  const PrepAzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp(
      // dil dəyişəndə bütün ağac təzədən qurulur ki, hər mətn yeni dildə görünsün
      key: ValueKey(settings.language),
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode.flutter,
      locale: settings.language.locale,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const UpdateGate(child: LegalAcceptanceRecorder(child: AuthGate())),
    );
  }
}

/// env/*.json verilməyibsə, tətbiq çökmür, nə etmək lazım olduğunu göstərir.
class ConfigMissingApp extends StatelessWidget {
  const ConfigMissingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(AppStrings.configMissing, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
