import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/math_text.dart';
import '../../home/domain/subject.dart';
import '../../home/presentation/home_providers.dart';
import '../../quiz/domain/mistake_item.dart';
import '../../quiz/domain/quiz_request.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../quiz/presentation/widgets/question_code_label.dart';
import '../../quiz/presentation/widgets/question_image.dart';
import 'mistakes_providers.dart';

/// Səhvlər dəftəri: təkrar növbəsindəki suallar, düzgün cavab və həll ilə.
class MistakesScreen extends ConsumerWidget {
  const MistakesScreen({super.key, required this.subject});

  final Subject subject;

  Future<void> _repeat(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => QuizScreen(subject: subject, kind: QuizKind.mistakes)),
    );
    ref.invalidate(mistakesProvider(subject.id));
    ref.invalidate(masteryProvider(subject.id));
    ref.invalidate(streakDaysProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = mistakesProvider(subject.id);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.mistakesBook)),
      body: SafeArea(
        child: AsyncValueView<List<MistakeItem>>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          builder: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(AppStrings.mistakesEmpty, textAlign: TextAlign.center),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: AppSpacing.pagePadding,
                    children: [
                      const Text(AppStrings.mistakesHint),
                      AppSpacing.gapM,
                      for (final item in items) _MistakeCard(item: item),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(label: AppStrings.repeatMistakes, onPressed: () => _repeat(context, ref)),
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

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.item});

  final MistakeItem item;

  @override
  Widget build(BuildContext context) {
    final question = item.question;
    final text = Theme.of(context).textTheme;
    final today = DateTime.now();
    final due = item.isDue(today) ? AppStrings.dueToday : AppStrings.dueInDays(item.daysUntilDue(today));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(due, style: text.labelMedium)),
                Expanded(child: QuestionCodeLabel(question: question)),
              ],
            ),
            AppSpacing.gapS,
            MathText(question.body),
            if (question.hasImage) ...[AppSpacing.gapS, QuestionImage(question.imagePath!, compact: true)],
            AppSpacing.gapS,
            Text(AppStrings.rightAnswer(question.correctAnswer), style: text.titleSmall),
            if (question.hasSolution)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(AppStrings.solution),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (question.hasSolutionImage)
                      QuestionImage(question.solutionImagePath!)
                    else
                      MathText(question.solution!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
