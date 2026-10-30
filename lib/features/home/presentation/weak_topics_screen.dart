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

/// Fənn üzrə bütün cavab verilmiş mövzular, ən zəifi yuxarıda. Mövzuya basanda yalnız o mövzu məşq olunur.
class WeakTopicsScreen extends ConsumerWidget {
  const WeakTopicsScreen({super.key, required this.subject});

  final Subject subject;

  Future<void> _practise(BuildContext context, WidgetRef ref, TopicMastery topic) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(subject: subject, kind: QuizKind.topic, topicId: topic.topicId),
      ),
    );
    ref.invalidate(masteryProvider(subject.id));
    ref.invalidate(streakDaysProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = masteryProvider(subject.id);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.weakPlacesTitle)),
      body: SafeArea(
        child: AsyncValueView<List<TopicMastery>>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          builder: (topics) {
            if (topics.isEmpty) {
              return const Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(AppStrings.noMasteryYet, textAlign: TextAlign.center),
                ),
              );
            }
            return ListView(
              padding: AppSpacing.pagePadding,
              children: [
                const Text(AppStrings.weakPlacesHint),
                AppSpacing.gapM,
                for (final topic in topics)
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _practise(context, ref, topic),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(child: MasteryRow(mastery: topic)),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
