import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../goal/presentation/goal_providers.dart';
import '../../../home/presentation/home_providers.dart';
import '../downloaded_subjects_screen.dart';
import '../offline_providers.dart';

/// Ana ekranın başında, yalnız internet olmayanda: "Hazırda oflayn rejimdəsən" kartı, yüklənmiş suallara keçid
/// və kartın aşağısında "İnterneti yenidən yoxla" düyməsi.
/// Heç nə yüklənməyibsə kartda düymə yoxdur, yalnız izah var.
class OfflineHomeBanner extends ConsumerWidget {
  const OfflineHomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(offlineModeProvider)) return const SizedBox.shrink();
    final hasDownloads = (ref.watch(downloadedSubjectsProvider).asData?.value ?? const []).isNotEmpty;
    final text = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    const color = AppColors.warning;
    return FadeSlideIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isLight ? 0.13 : 0.2),
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: const Icon(Icons.wifi_off_rounded, color: color, size: 24),
                    ),
                    AppSpacing.gapM,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.homeOfflineTitle,
                            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          AppSpacing.gapXs,
                          Text(
                            hasDownloads
                                ? AppStrings.homeOfflineBodyWithDownloads
                                : AppStrings.homeOfflineBodyEmpty,
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasDownloads) ...[
                  AppSpacing.gapM,
                  Pressable(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const DownloadedSubjectsScreen()),
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.homeOfflineGo,
                            style: text.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          AppSpacing.gapS,
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapL,
          const _RetryButton(),
        ],
      ),
    );
  }
}

/// "İnterneti yenidən yoxla": kartdan aşağıda ayrıca iri düymə. Yoxlanarkən dairəvi gözləmə göstərir,
/// internet hələ də yoxdursa bunu deyir; internet qayıdıbsa narıncı yer yox olur və fənn kartları geri gəlir.
class _RetryButton extends ConsumerStatefulWidget {
  const _RetryButton();

  @override
  ConsumerState<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends ConsumerState<_RetryButton> {
  bool _checking = false;
  bool _stillOffline = false;

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _stillOffline = false;
    });
    ref.invalidate(streakDaysProvider);
    ref.invalidate(userGoalProvider);
    try {
      // internet varsa, fənlər serverdən gəlir və "oflayn" siqnalı özü sönür
      ref.invalidate(subjectsProvider);
      await ref.read(subjectsProvider.future);
    } on AppException {
      // yoxlama alınmadı: aşağıda "hələ də yoxdur" deyirik
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _stillOffline = ref.read(offlineModeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = scheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          onTap: _checking ? null : _check,
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: _checking
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
                        )
                      : Icon(Icons.refresh_rounded, color: color, size: 20),
                ),
                AppSpacing.gapM,
                Text(
                  AppStrings.homeOfflineRetry,
                  style: text.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        if (_stillOffline) ...[
          AppSpacing.gapS,
          Text(
            AppStrings.homeOfflineStill,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
