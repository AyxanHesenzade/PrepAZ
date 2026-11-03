import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../home/domain/subject.dart';
import '../offline_providers.dart';

/// Ana ekrandakı fənn kartında: "İnternetsiz həll et" girişi. Fənnin rəngində gradient sətirdir.
/// Alt sətir vəziyyəti göstərir: heç nə yüklənməyibsə "Mövzuları yüklə", yüklənibsə "Telefonda: 3 mövzu · 9 MB".
class OfflineEntryTile extends ConsumerWidget {
  const OfflineEntryTile({super.key, required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final dark = Color.lerp(accent, Colors.black, 0.35)!;
    final text = Theme.of(context).textTheme;
    final stored = ref.watch(storedTopicsProvider(subject.id)).asData?.value ?? const [];
    final bytes = stored.fold<int>(0, (sum, t) => sum + t.imageBytes);
    final status = stored.isEmpty
        ? AppStrings.offlineHintAction
        : AppStrings.offlineStats(stored.length, formatBytes(bytes));
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s + 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, dark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 24),
            ),
            AppSpacing.gapM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.offlineTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
