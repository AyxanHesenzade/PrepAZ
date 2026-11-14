import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pressable.dart';
import '../../browse/domain/browse_topic.dart';
import '../../browse/presentation/topic_questions_screen.dart';
import '../../home/domain/subject.dart';
import '../../home/domain/topic_mastery.dart';
import '../../home/presentation/home_providers.dart';
import '../../home/presentation/widgets/mastery_row.dart';
import '../domain/subject_stats.dart';
import 'stats_providers.dart';
import 'widgets/stat_tiles.dart';
import 'widgets/stats_header.dart';
import 'widgets/week_chart.dart';

/// Alt menyudakı "İrəliləyiş": fənn üzrə ümumi rəqəmlər, son 7 gün və mövzular.
class StatsTab extends ConsumerStatefulWidget {
  const StatsTab({super.key});

  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab> {
  int? _subjectId;

  Future<void> _refresh(int subjectId) {
    ref.invalidate(masteryProvider(subjectId));
    return ref.refresh(subjectStatsProvider(subjectId).future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: ref.watch(subjectsProvider),
          onRetry: () => ref.invalidate(subjectsProvider),
          builder: (subjects) {
            if (subjects.isEmpty) {
              return Center(child: Text(AppStrings.noSubjects));
            }
            final subject = subjects.firstWhere(
              (s) => s.id == _subjectId,
              orElse: () => subjects.first,
            );
            final accent = AppColors.subjectAccent(subject.slug, subject.id);
            final stats = ref.watch(subjectStatsProvider(subject.id));
            return RefreshIndicator(
              onRefresh: () => _refresh(subject.id),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m + 4,
                  AppSpacing.m,
                  AppSpacing.m + 4,
                  AppSpacing.l,
                ),
                children: [
                  FadeSlideIn(
                    child: StatsHeader(
                      subjects: subjects,
                      selected: subject,
                      stats: stats.asData?.value,
                      onSubjectChanged: (id) => setState(() => _subjectId = id),
                    ),
                  ),
                  AppSpacing.gapL,
                  AsyncValueView(
                    value: stats,
                    onRetry: () =>
                        ref.invalidate(subjectStatsProvider(subject.id)),
                    builder: (s) => s.isEmpty
                        ? FadeSlideIn(
                            index: 1,
                            child: _EmptyStats(accent: accent),
                          )
                        : _StatsBody(
                            subject: subject,
                            stats: s,
                            accent: accent,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.subject,
    required this.stats,
    required this.accent,
  });

  final Subject subject;
  final SubjectStats stats;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          index: 1,
          child: StatTiles(stats: stats, accent: accent),
        ),
        AppSpacing.gapM,
        FadeSlideIn(
          index: 2,
          child: WeekChart(stats: stats, accent: accent),
        ),
        AppSpacing.gapM,
        FadeSlideIn(
          index: 3,
          child: _TopicsCard(subject: subject, topicsTotal: stats.topicsTotal),
        ),
      ],
    );
  }
}

/// Mövzular üzrə vəziyyət: ən zəifi birinci. Mövzuya basanda onun testləri açılır.
class _TopicsCard extends ConsumerWidget {
  const _TopicsCard({required this.subject, required this.topicsTotal});

  final Subject subject;
  final int topicsTotal;

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    TopicMastery m,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicQuestionsScreen(
          subjectId: subject.id,
          topic: BrowseTopic(
            id: m.topicId,
            name: m.topicName,
            questionCount: m.total,
          ),
        ),
      ),
    );
    // mövzuda test həll edilmiş ola bilər
    ref.invalidate(masteryProvider(subject.id));
    ref.invalidate(subjectStatsProvider(subject.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // köməkçi blokdur: yüklənmirsə gizlənir, ekranın qalanını pozmur
    final topics = ref.watch(masteryProvider(subject.id)).asData?.value;
    if (topics == null || topics.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.statsTopicsTitle,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.gapXs,
          Text(
            topicsTotal > 0
                ? '${AppStrings.statsTopicsStarted(topics.length, topicsTotal)} · ${AppStrings.statsTopicsHint}'
                : AppStrings.statsTopicsHint,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          AppSpacing.gapS,
          for (final m in topics)
            Pressable(
              onTap: () => _open(context, ref, m),
              child: MasteryRow(mastery: m),
            ),
        ],
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 56, color: accent),
          AppSpacing.gapM,
          Text(
            AppStrings.statsEmptyTitle,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.gapS,
          Text(
            AppStrings.statsEmptyText,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
