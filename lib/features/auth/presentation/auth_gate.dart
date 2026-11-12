import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../offline/presentation/offline_sync.dart';
import '../../reminders/presentation/reminder_providers.dart';
import '../../shell/presentation/main_shell.dart';
import 'auth_providers.dart';
import 'auth_screen.dart';

/// Daxil olubsa əsas ekran (alt menyu ilə), yoxsa giriş ekranı.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // çıxışda (və hesab silinəndə) xatırlatmalar da silinsin
    ref.listen(isSignedInProvider, (prev, next) {
      if (prev?.value == true && next.value == false) {
        ref.read(reminderSchedulerProvider).cancelAll().ignore();
      }
    });
    final signedIn = ref.watch(isSignedInProvider);
    return signedIn.when(
      data: (isSignedIn) =>
          isSignedIn ? const AnswerSyncGate(child: MainShell()) : const AuthScreen(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const AuthScreen(),
    );
  }
}
