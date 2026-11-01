import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import 'legal_providers.dart';

/// Qeydiyyatda verilən razılıq hesab açılana qədər telefonda gözləyir, daxil olanda bazaya yazılır.
/// Yazılmasa (internet yox / cədvəl yox), heç nə bloklanmır, növbəti açılışda təkrarlanır.
class LegalAcceptanceRecorder extends ConsumerStatefulWidget {
  const LegalAcceptanceRecorder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LegalAcceptanceRecorder> createState() => _LegalAcceptanceRecorderState();
}

class _LegalAcceptanceRecorderState extends ConsumerState<LegalAcceptanceRecorder> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(isSignedInProvider, (_, next) {
      if (next.value == true) _record();
    }, fireImmediately: true);
  }

  Future<void> _record() async {
    final version = ref.read(settingsControllerProvider).pendingLegalVersion;
    if (version == 0) return;
    try {
      await ref.read(legalRepositoryProvider).recordAcceptance(version);
      await ref.read(settingsControllerProvider.notifier).clearPendingLegal();
    } catch (_) {
      // növbəti açılışda yenidən yazılacaq
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
