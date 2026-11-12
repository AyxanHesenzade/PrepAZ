import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(updateInfoProvider).asData?.value ?? UpdateInfo.none;
    if (info.kind == UpdateKind.required) return ForceUpdateScreen(url: info.url);
    return child;
  }
}

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.system_update_rounded, size: 72, color: scheme.primary),
                  AppSpacing.gapL,
                  Text(AppStrings.updateRequiredTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  AppSpacing.gapM,
                  Text(AppStrings.updateRequiredText, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                  if (url != null && url!.trim().isNotEmpty) ...[
                    AppSpacing.gapXl,
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => openUpdateLink(url),
                        icon: const Icon(Icons.download_rounded),
                        label: Text(AppStrings.updateNow),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

