import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../quiz/domain/quiz_request.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../domain/subject.dart';
import '../domain/topic_mastery.dart';
import 'home_providers.dart';
import 'widgets/mastery_row.dart';

/// Fənn üzrə cavab verilmiş mövzular qruplarla: zəif, yaxşı, davam edən. Mövzuya basanda yalnız o mövzu məşq olunur.
class WeakTopicsScreen extends ConsumerWidget {
  const WeakTopicsScreen({super.key, required this.subject});

  final Subject subject;

  Future<void> _practise(
    BuildContext context,
    WidgetRef ref,
    TopicMastery topic,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          subject: subject,
          kind: QuizKind.topic,
          topicId: topic.topicId,
        ),
      ),
    );
    ref.invalidate(masteryProvider(subject.id));
    ref.invalidate(streakDaysProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = masteryProvider(subject.id);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.weakPlacesTitle)),
      body: SafeArea(
        child: AsyncValueView<List<TopicMastery>>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          builder: (topics) {
            if (topics.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(
                    AppStrings.noMasteryYet,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView(
              padding: AppSpacing.pagePadding,
              children: [
                Text(
                  AppStrings.weakPlacesHint(TopicMastery.minAnswers, TopicMastery.strongPct),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                for (final (title, group) in [
                  (AppStrings.weakTopics, topics.where((t) => t.isWeak).toList()),
                  (AppStrings.strongTopics, topics.reversed.where((t) => t.isStrong).toList()),
                  (AppStrings.inProgressTopics, topics.where((t) => !t.isWeak && !t.isStrong).toList()),
                ])
                  if (group.isNotEmpty) ...[
                    AppSpacing.gapL,
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    AppSpacing.gapS,
                    for (final topic in group)
                      _TopicCard(topic: topic, onTap: () => _practise(context, ref, topic)),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});

  final TopicMastery topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.l),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              Expanded(child: MasteryRow(mastery: topic)),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
