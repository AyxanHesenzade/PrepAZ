import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format_bytes.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pressable.dart';
import '../../home/presentation/widgets/subject_card.dart';
import '../domain/offline_models.dart';
import 'downloaded_topics_screen.dart';
import 'offline_providers.dart';

/// "Yüklədiyin suallar": sualı yüklənmiş fənlərin adları. Fənnə basanda həmin fənnin yüklənmiş mövzuları açılır.
/// İnternet lazım deyil: hər şey telefondan oxunur.
class DownloadedSubjectsScreen extends ConsumerWidget {
  const DownloadedSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.downloadedTitle)),
      body: SafeArea(
        child: AsyncValueView<List<DownloadedSubject>>(
          value: ref.watch(downloadedSubjectsProvider),
          onRetry: () => ref.invalidate(downloadedSubjectsProvider),
          builder: (subjects) {
            if (subjects.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(AppStrings.downloadedEmpty, textAlign: TextAlign.center),
                ),
              );
            }
            return ListView(
              padding: AppSpacing.pagePadding,
              children: [
                Text(
                  AppStrings.downloadedPickSubject,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapM,
                for (final (i, s) in subjects.indexed)
                  FadeSlideIn(index: i, child: _SubjectTile(downloaded: s)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.downloaded});

  final DownloadedSubject downloaded;

  @override
  Widget build(BuildContext context) {
    final subject = downloaded.subject;
    final accent = AppColors.subjectAccent(subject.slug, subject.id);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final tint = Color.alphaBlend(
      accent.withValues(alpha: isLight ? 0.10 : 0.16),
      scheme.surfaceContainerLowest,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Pressable(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => DownloadedTopicsScreen(subject: subject)),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m + 2),
          decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(AppRadius.m)),
                child: Icon(SubjectCard.iconFor(subject.slug), color: Colors.white, size: 28),
              ),
              AppSpacing.gapM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: text.titleLarge),
                    AppSpacing.gapXs,
                    Text(
                      AppStrings.downloadedSubjectLine(downloaded.topics.length, formatBytes(downloaded.bytes)),
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
