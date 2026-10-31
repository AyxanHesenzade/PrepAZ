import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers.dart';
import '../../../../core/widgets/mascot/mascot.dart';
import '../../../../core/widgets/mascot/mascot_behavior.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../tour/presentation/tour_controller.dart';

/// Ana ekranın başlığında sağda dayanan balaca köməkçi. Basanda öyrədici tur yenidən açılır.
class HeaderMascot extends ConsumerWidget {
  const HeaderMascot({super.key});

  static const _size = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: AppStrings.tourReplay,
      child: Pressable(
        onTap: ref.read(tourControllerProvider.notifier).replay,
        child: Mascot(
          behavior: const IdleMascot(),
          size: _size,
          animate: ref.watch(mascotMotionProvider),
        ),
      ),
    );
  }
}
