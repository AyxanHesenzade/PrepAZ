import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format_bytes.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/message_banner.dart';
import '../../home/domain/subject.dart';
import '../domain/offline_models.dart';
import 'download_controller.dart';
import 'offline_providers.dart';

/// Fənnin mövzularını telefona yükləmək: ölçü, vəziyyət, yüklə / davam et / yenilə / sil.
class DownloadScreen extends ConsumerWidget {
  const DownloadScreen({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(downloadCatalogProvider(subject.id));
    final stored =
        ref.watch(storedTopicsProvider(subject.id)).asData?.value ??
        const <StoredTopic>[];
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: SafeArea(
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => stored.isEmpty
              ? ErrorView(
                  message: AppStrings.offlineNeedInternetToDownload,
                  onRetry: () =>
                      ref.invalidate(downloadCatalogProvider(subject.id)),
                )
              : _Body(subject: subject, server: const [], stored: stored, offline: true),
          data: (server) => _Body(subject: subject, server: server, stored: stored),
        ),
      ),
    );
  }
}

/// Bir sətir: serverdəki mövzu, telefondakı surəti, ya da ikisi.
class _Row {
  _Row({required this.topicId, required this.name, this.section, this.server, this.stored});

  final int topicId;
  final String name;
  final String? section;
  final CatalogTopic? server;
  final StoredTopic? stored;

  int get questions => server?.questionCount ?? stored?.questionCount ?? 0;
  int get bytes => server?.imageBytes ?? stored?.imageBytes ?? 0;
  TopicDownloadState get state => downloadStateOf(server, stored);
}

List<_Row> _rowsOf(List<CatalogTopic> server, List<StoredTopic> stored) {
  final storedById = {for (final t in stored) t.topicId: t};
  final rows = [
    for (final t in server)
      _Row(
        topicId: t.topicId,
        name: t.topicName,
        section: t.sectionName,
        server: t,
        stored: storedById[t.topicId],
      ),
  ];
  final listed = {for (final r in rows) r.topicId};
  // Serverdə artıq görünməyən, amma telefonda olan mövzu da silə bilmək üçün göstərilir.
  for (final t in stored.where((t) => !listed.contains(t.topicId))) {
    rows.add(_Row(topicId: t.topicId, name: t.topicName, section: t.sectionName, stored: t));
  }
  return rows;
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.subject,
    required this.server,
    required this.stored,
    this.offline = false,
  });

  final Subject subject;
  final List<CatalogTopic> server;
  final List<StoredTopic> stored;

  /// Kataloq alınmadı: yalnız telefondakılar göstərilir.
  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(downloadsControllerProvider);
    final controller = ref.read(downloadsControllerProvider.notifier);
    final rows = _rowsOf(server, stored);
    final text = Theme.of(context).textTheme;

    final pending = [
      for (final r in rows)
        if (r.server != null && r.state != TopicDownloadState.ready && !controller.isBusy(r.topicId)) r,
    ];
    final pendingBytes = pending.fold<int>(0, (sum, r) => sum + r.bytes);

    final children = <Widget>[];
    String? lastSection = '\u0000';
    for (final row in rows) {
      if (row.section != lastSection) {
        lastSection = row.section;
        if (row.section != null) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.s),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.subjectAccent(subject.slug, subject.id),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  AppSpacing.gapS,
                  Expanded(child: Text(row.section!, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                ],
              ),
            ),
          );
        }
      }
      children.add(
        _TopicTile(
          row: row,
          activity: activity[row.topicId],
          onDownload: () => controller.download(subjectId: subject.id, topic: row.server!),
          onCancel: () => controller.cancel(row.topicId),
          onDelete: () => _confirmDelete(context, controller, row),
        ),
      );
    }

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _Hero(
          subject: subject,
          topics: stored.length,
          bytes: stored.fold<int>(0, (sum, t) => sum + t.imageBytes),
        ),
        AppSpacing.gapM,
        if (offline) ...[
          MessageBanner(AppStrings.offlineNoInternet),
          AppSpacing.gapM,
        ],
        if (pending.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: FilledButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: Text(AppStrings.downloadAll(formatBytes(pendingBytes))),
              onPressed: () => _confirmAll(context, controller, pending, pendingBytes),
            ),
          ),
        if (rows.isEmpty) Center(child: Text(AppStrings.offlineNothing)),
        ...children,
      ],
    );
  }

  Future<void> _confirmAll(
    BuildContext context,
    DownloadsController controller,
    List<_Row> pending,
    int bytes,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.downloadAllTitle(pending.length, formatBytes(bytes))),
        content: Text(AppStrings.downloadAllBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(AppStrings.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(AppStrings.downloadAction)),
        ],
      ),
    );
    if (ok != true) return;
    await controller.downloadAll(subjectId: subject.id, topics: [for (final r in pending) r.server!]);
  }

  Future<void> _confirmDelete(BuildContext context, DownloadsController controller, _Row row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.downloadDeleteTitle(row.name)),
        content: Text(AppStrings.downloadDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(AppStrings.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.downloadDeleteConfirm),
          ),
        ],
      ),
    );
    if (ok == true) await controller.delete(row.topicId);
  }
}

/// Üstdə: gradient kart. Telefonda nə qədər mövzu və yer tutduğu bir baxışda görünür.
class _Hero extends StatelessWidget {
  const _Hero({required this.subject, required this.topics, required this.bytes});

  final Subject subject;
  final int topics;
  final int bytes;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final dark = Color.lerp(accent, Colors.black, 0.35)!;
    final text = Theme.of(context).textTheme;
    return FadeSlideIn(
      child: Container(
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
                  child: Text(
                    AppStrings.offlineTitle,
                    style: text.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            AppSpacing.gapM,
            Text(
              AppStrings.offlineIntro,
              style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
            ),
            AppSpacing.gapM,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s + 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.smartphone_rounded, color: Colors.white, size: 18),
                  AppSpacing.gapS,
                  Flexible(
                    child: Text(
                      topics == 0 ? AppStrings.offlineStatsEmpty : AppStrings.offlineStats(topics, formatBytes(bytes)),
                      style: text.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mövzunun solunda: vəziyyəti rəng və işarə ilə göstərən dairə.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.state, required this.busy, required this.failed});

  final TopicDownloadState state;
  final bool busy;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;
    final (icon, color) = failed
        ? (Icons.error_outline_rounded, AppColors.danger)
        : busy
        ? (Icons.downloading_rounded, primary)
        : switch (state) {
            TopicDownloadState.ready => (Icons.check_rounded, AppColors.success),
            TopicDownloadState.updateAvailable => (Icons.sync_rounded, primary),
            TopicDownloadState.incomplete => (Icons.downloading_rounded, AppColors.warning),
            TopicDownloadState.notDownloaded => (Icons.cloud_download_outlined, outline),
          };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.row,
    required this.activity,
    required this.onDownload,
    required this.onCancel,
    required this.onDelete,
  });

  final _Row row;
  final TopicActivity? activity;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final busy = activity != null && !activity!.failed;
    final state = row.state;
    final hasCopy = row.stored != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusDot(state: state, busy: busy, failed: activity?.failed ?? false),
                AppSpacing.gapM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: text.titleSmall),
                      AppSpacing.gapXs,
                      Text(
                        AppStrings.topicSizeLine(row.questions, formatBytes(row.bytes)),
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (busy)
                  IconButton(
                    tooltip: AppStrings.downloadStop,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onCancel,
                  )
                else ...[
                  _action(context, state),
                  if (hasCopy)
                    IconButton(
                      tooltip: AppStrings.downloadDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: onDelete,
                    ),
                ],
              ],
            ),
            if (busy) ...[
              AppSpacing.gapS,
              LinearProgressIndicator(value: activity!.fraction),
              AppSpacing.gapXs,
              Text(
                AppStrings.downloadingPercent((activity!.fraction * 100).round()),
                style: text.bodySmall,
              ),
            ] else if (activity?.failed ?? false) ...[
              AppSpacing.gapS,
              Text(activity!.error!, style: text.bodySmall?.copyWith(color: scheme.error)),
            ] else if (state == TopicDownloadState.updateAvailable) ...[
              AppSpacing.gapS,
              Text(AppStrings.downloadUpdateAvailable, style: text.bodySmall?.copyWith(color: scheme.primary)),
            ] else if (state == TopicDownloadState.incomplete) ...[
              AppSpacing.gapS,
              Text(AppStrings.downloadIncomplete, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context, TopicDownloadState state) {
    if (activity?.failed ?? false) {
      return FilledButton.tonal(onPressed: onDownload, child: Text(AppStrings.retry));
    }
    // Serverdə artıq olmayan mövzunu yükləmək/yeniləmək olmaz: yalnız silinir.
    if (row.server == null) return const SizedBox.shrink();
    return switch (state) {
      TopicDownloadState.notDownloaded =>
        FilledButton.tonal(onPressed: onDownload, child: Text(AppStrings.downloadAction)),
      TopicDownloadState.incomplete =>
        FilledButton.tonal(onPressed: onDownload, child: Text(AppStrings.downloadResume)),
      TopicDownloadState.updateAvailable =>
        FilledButton.tonal(onPressed: onDownload, child: Text(AppStrings.downloadUpdate)),
      TopicDownloadState.ready => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
          AppSpacing.gapXs,
          Text(AppStrings.downloadedLabel),
        ],
      ),
    };
  }
}
