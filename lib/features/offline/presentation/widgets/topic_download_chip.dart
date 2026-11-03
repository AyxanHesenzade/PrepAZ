import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../home/domain/subject.dart';
import '../../domain/offline_models.dart';
import '../download_controller.dart';
import '../offline_providers.dart';

/// Mövzu siyahısında hər mövzunun yanındakı yükləmə düyməsi. Bir toxunuşla yükləyir, ayrıca ekrana getmək lazım deyil.
///
/// - yüklənməyib: `⬇ 3.1 MB` (ölçü görünür, istifadəçi nə qədər trafik gedəcəyini bilir)
/// - yüklənir: dairəvi irəliləyiş (toxunanda dayanır)
/// - yarımçıq: `Davam et`, yenilənmə var: `Yenilə`
/// - hazır: yaşıl `✓ Telefonda`
/// Kataloq alınmayıbsa (internet yoxdur) və mövzu yüklənməyibsə, heç nə göstərilmir.
class TopicDownloadChip extends ConsumerWidget {
  const TopicDownloadChip({super.key, required this.subject, required this.topicId});

  final Subject subject;
  final int topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final catalog = ref.watch(downloadCatalogProvider(subject.id)).asData?.value;
    final storedTopics = ref.watch(storedTopicsProvider(subject.id)).asData?.value;
    final server = catalog?.where((t) => t.topicId == topicId).firstOrNull;
    final stored = storedTopics?.where((t) => t.topicId == topicId).firstOrNull;
    final activity = ref.watch(downloadsControllerProvider)[topicId];
    final controller = ref.read(downloadsControllerProvider.notifier);

    if (activity != null && !activity.failed) {
      return _Ring(
        fraction: activity.fraction,
        color: accent,
        onStop: () => controller.cancel(topicId),
      );
    }
    void download() => controller.download(subjectId: subject.id, topic: server!);
    if (activity?.failed ?? false) {
      return _Pill(
        icon: Icons.refresh_rounded,
        label: AppStrings.retry,
        color: AppColors.danger,
        onTap: server == null ? null : download,
      );
    }
    if (server == null && stored == null) return const SizedBox.shrink();
    if (server == null) return _ready(); // serverdə artıq yoxdur, amma telefonda işləyir

    return switch (downloadStateOf(server, stored)) {
      TopicDownloadState.ready => _ready(),
      TopicDownloadState.updateAvailable => _Pill(
        icon: Icons.sync_rounded,
        label: AppStrings.downloadUpdate,
        color: accent,
        onTap: download,
      ),
      TopicDownloadState.incomplete => _Pill(
        icon: Icons.downloading_rounded,
        label: AppStrings.downloadResume,
        color: AppColors.warning,
        onTap: download,
      ),
      TopicDownloadState.notDownloaded => _Pill(
        icon: Icons.download_rounded,
        label: formatBytes(server.imageBytes),
        color: accent,
        onTap: download,
      ),
    };
  }

  Widget _ready() => const _Pill(
    icon: Icons.check_circle_rounded,
    label: null, // mətn AppStrings-dən build-də alınır (dil dəyişəndə yenilənsin)
    color: AppColors.success,
    filled: false,
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.filled = true,
  });

  final IconData icon;

  /// null = "Telefonda" (hazır vəziyyət).
  final String? label;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final text = label ?? AppStrings.onPhoneLabel;
    final pill = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m - 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? (isLight ? 0.13 : 0.22) : 0.0),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    return onTap == null ? pill : Pressable(onTap: onTap, child: pill);
  }
}

/// Yüklənərkən: dairə və içində faiz. Toxunanda dayandırır.
class _Ring extends StatelessWidget {
  const _Ring({required this.fraction, required this.color, required this.onStop});

  final double fraction;
  final Color color;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.downloadStop,
      child: Pressable(
        onTap: onStop,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.18),
                ),
              ),
              Icon(Icons.close_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
