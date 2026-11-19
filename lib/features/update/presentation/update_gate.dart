import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_version.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/mascot/mascot.dart';
import '../../../core/widgets/mascot/mascot_behavior.dart';
import '../../../core/widgets/pressable.dart';
import '../domain/app_config.dart';
import 'update_providers.dart';

Future<void> openUpdateLink(String? url) async {
  final uri = Uri.tryParse(url ?? '');
  if (uri == null || !uri.hasScheme) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Açılışda versiyanı yoxlayır: köhnədirsə məcburi yeniləmə ekranı (bağlanmır).
/// Yeni (məcburi olmayan) versiya barədə xəbər ana ekrandakı `UpdateBanner`-dədir.
/// Yoxlama bitənə və ya alınmayana qədər tətbiq gözləmədən açılır.
class UpdateGate extends ConsumerWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  /// Yalnız debug-da: `--dart-define=PREVIEW_FORCE_UPDATE=true` ekranı bazaya toxunmadan göstərir
  /// (`min_version`-u qaldırmaq bütün testerləri bağlayardı). Release build-də heç vaxt işləmir.
  static const _preview = kDebugMode && bool.fromEnvironment('PREVIEW_FORCE_UPDATE');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(updateInfoProvider).asData?.value ?? UpdateInfo.none;
    if (_preview) return ForceUpdateScreen(url: info.url ?? 'https://prepaz.az');
    if (info.kind == UpdateKind.required) return ForceUpdateScreen(url: info.url);
    return child;
  }
}

/// Bağlanmayan ekran: brend rəngində gradient, köməkçi, qısa başlıq, 3 addım və iri ağ düymə.
/// Gündüz/gecə rejimində eyni görünür (fon həmişə gradientdir).
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final hasUrl = url != null && url!.trim().isNotEmpty;
    final version = ref.watch(appVersionProvider).asData?.value;
    const white70 = Color(0xB3FFFFFF);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brandStart, AppColors.brandEnd],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.l),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight - AppSpacing.l * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          AppSpacing.gapXl,
                          _MascotBadge(animate: ref.watch(mascotMotionProvider)),
                          AppSpacing.gapL,
                          Text(
                            AppStrings.updateRequiredTitle,
                            textAlign: TextAlign.center,
                            style: text.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          AppSpacing.gapS,
                          Text(
                            AppStrings.updateRequiredText,
                            textAlign: TextAlign.center,
                            style: text.bodyLarge?.copyWith(color: white70, height: 1.4),
                          ),
                          if (version != null) ...[
                            AppSpacing.gapM,
                            _GlassChip(label: AppStrings.updateYourVersion(version.version)),
                          ],
                          if (hasUrl) ...[
                            AppSpacing.gapXl,
                            const _Steps(),
                          ],
                        ],
                      ),
                      Column(
                        children: [
                          AppSpacing.gapXl,
                          if (hasUrl) _UpdateButton(onTap: () => openUpdateLink(url)),
                          AppSpacing.gapM,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_rounded, size: 16, color: white70),
                              AppSpacing.gapXs,
                              Flexible(
                                child: Text(
                                  AppStrings.updateDataSafe,
                                  style: text.bodyMedium?.copyWith(color: white70, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Köməkçi şüşə dairənin içində, küncündə yeniləmə nişanı.
class _MascotBadge extends StatelessWidget {
  const _MascotBadge({required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            // ağ dairə: mavi köməkçi mavi fonda itməsin; ətrafında yumşaq parıltı
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 10, strokeAlign: BorderSide.strokeAlignOutside),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.25), blurRadius: 40, spreadRadius: 4)],
            ),
          ),
          Mascot(behavior: const IdleMascot(), size: 104, animate: animate),
          Positioned(
            right: 4,
            bottom: 8,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.streak,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandEnd, width: 3),
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// "1 bas → 2 yüklə → 3 quraşdır": nömrəli dairələr şüşə kartda.
class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    final steps = AppStrings.updateSteps;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          for (final (i, step) in steps.indexed) ...[
            if (i > 0) AppSpacing.gapS,
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Text(
                    '${i + 1}',
                    style: text.titleSmall?.copyWith(color: AppColors.brandEnd, fontWeight: FontWeight.w800),
                  ),
                ),
                AppSpacing.gapM,
                Expanded(
                  child: Text(
                    step,
                    style: text.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 60,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_rounded, color: AppColors.brandEnd, size: 24),
            AppSpacing.gapS,
            Text(
              AppStrings.updateNow,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.brandEnd,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

