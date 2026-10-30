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

/// Açılışda versiyanı yoxlayır: köhnədirsə məcburi yeniləmə ekranı (bağlanmır), yeni versiya varsa bir dəfə xəbərdarlıq.
/// Yoxlama bitənə və ya alınmayana qədər tətbiq gözləmədən açılır.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate> {
  bool _noticeShown = false;

  void _maybeNotice(UpdateInfo info) {
    if (info.kind != UpdateKind.optional || _noticeShown) return;
    _noticeShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(context: context, builder: (_) => _OptionalUpdateDialog(url: info.url));
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(updateInfoProvider).asData?.value ?? UpdateInfo.none;
    if (info.kind == UpdateKind.required) return ForceUpdateScreen(url: info.url);
    _maybeNotice(info);
    return widget.child;
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

class _OptionalUpdateDialog extends StatelessWidget {
  const _OptionalUpdateDialog({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    return AlertDialog(
      title: Text(AppStrings.updateAvailableTitle),
      content: Text(AppStrings.updateAvailableText),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppStrings.updateLater)),
        if (hasUrl)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openUpdateLink(url);
            },
            child: Text(AppStrings.updateNow),
          ),
      ],
    );
  }
}
