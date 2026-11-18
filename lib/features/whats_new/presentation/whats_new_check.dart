import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_version.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../tour/presentation/tour_controller.dart';
import '../domain/release_note.dart';
import 'whats_new_providers.dart';
import 'whats_new_sheet.dart';

/// Yeniləmədən sonra ilk açılışda "Yeniliklər" panelini BİR DƏFƏ göstərir.
/// Yeni istifadəçiyə göstərilmir (öyrədici turu görür), tur gedərkən açılmır.
class WhatsNewCheck extends ConsumerStatefulWidget {
  const WhatsNewCheck({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WhatsNewCheck> createState() => _WhatsNewCheckState();
}

class _WhatsNewCheckState extends ConsumerState<WhatsNewCheck> {
  @override
  void initState() {
    super.initState();
    if (ref.read(whatsNewEnabledProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    final AppVersion version;
    try {
      version = await ref.read(appVersionProvider.future);
    } on Object {
      return;
    }
    if (!mounted) return;
    final settings = ref.read(settingsControllerProvider);
    final notes = notesToShow(
      currentBuild: version.build,
      lastSeenBuild: settings.whatsNewSeenBuild,
      isNewUser: !settings.tourSeen,
      all: ref.read(releaseNotesProvider),
    );
    if (settings.whatsNewSeenBuild != version.build) {
      // göstərməzdən ƏVVƏL yazılır: tətbiq bağlansa da panel təkrar çıxmır
      await ref
          .read(settingsControllerProvider.notifier)
          .setWhatsNewSeen(version.build);
    }
    if (notes.isEmpty || !mounted) return;
    if (ref.read(tourControllerProvider) != null) return;
    await showWhatsNewSheet(context, notes);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
