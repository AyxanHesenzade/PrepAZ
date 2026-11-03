import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../home/domain/subject.dart';

/// Mövzular siyahısının başında: istifadəçiyə internetsiz həll etməyin mümkün olduğunu göstərir.
/// Fənnin öz rəngində gradient kartdır. Hələ heç nə yüklənməyibsə göstərilir, ilk mövzu yüklənəndə yox olur.
class OfflineHintCard extends StatelessWidget {
  const OfflineHintCard({super.key, required this.subject, required this.onOpen});

  final Subject subject;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final dark = Color.lerp(accent, Colors.black, 0.35)!;
    final text = Theme.of(context).textTheme;
    return FadeSlideIn(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.m + 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, dark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 28),
                ),
                AppSpacing.gapM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.offlineTitle,
                        style: text.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      AppSpacing.gapXs,
                      Text(
                        AppStrings.offlineHintBody,
                        style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapM,
            Pressable(
              onTap: onOpen,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_rounded, color: dark, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.offlineHintAction,
                      style: text.titleSmall?.copyWith(color: dark, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
