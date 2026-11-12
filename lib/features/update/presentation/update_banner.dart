import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pressable.dart';
import '../domain/app_config.dart';
import 'update_gate.dart';
import 'update_providers.dart';

/// Ana ekranın başında, yalnız yeni (məcburi olmayan) versiya olanda: sadə gradient kart, başlıq və "Yenilə" düyməsi.
/// Yoxlama oxunmayıbsa və ya yeniləmə yoxdursa heç nə göstərilmir.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(updateInfoProvider).asData?.value ?? UpdateInfo.none;
    if (info.kind != UpdateKind.optional) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final base = Theme.of(context).colorScheme.primary;
    final hsl = HSLColor.fromColor(base);
    final deep = hsl.withLightness((hsl.lightness * 0.6).clamp(0.1, 0.5)).toColor();
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.m),
        child: Pressable(
          onTap: info.hasUrl ? () => openUpdateLink(info.url) : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.m + 2, AppSpacing.m, AppSpacing.m, AppSpacing.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.l),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [deep, base],
              ),
              boxShadow: [
                BoxShadow(color: base.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
                AppSpacing.gapM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.updateAvailableTitle,
                        style: text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.updateAvailableText,
                        style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                if (info.hasUrl) ...[
                  AppSpacing.gapM,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      AppStrings.updateNow,
                      style: text.titleSmall?.copyWith(color: deep, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
