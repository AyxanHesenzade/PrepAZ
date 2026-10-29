import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/home_screen.dart';
import 'auth_providers.dart';
import 'auth_screen.dart';

/// Daxil olubsa ana səhifə, yoxsa giriş ekranı.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(isSignedInProvider);
    return signedIn.when(
      data: (isSignedIn) => isSignedIn ? const HomeScreen() : const AuthScreen(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const AuthScreen(),
    );
  }
}
