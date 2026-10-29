import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/math_text.dart';
import '../domain/answer_result.dart';
import 'widgets/question_image.dart';

/// Məşqin nəticəsi: bal, faiz və səhv cavablanmış suallar.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.results});

  final List<AnswerResult> results;

  @override
  Widget build(BuildContext context) {
    final correct = results.where((r) => r.isCorrect).length;
    final total = results.length;
    final percent = total == 0 ? 0 : (100 * correct / total).round();
    final wrong = results.where((r) => !r.isCorrect).toList();
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Center(child: Text('$correct / $total', style: text.displayMedium)),
        Center(child: Text(AppStrings.percentCorrect(percent), style: text.titleMedium)),
        AppSpacing.gapL,
        if (wrong.isEmpty)
          const Center(child: Text(AppStrings.allCorrect))
        else ...[
          Text(AppStrings.wrongTitle(wrong.length), style: text.titleMedium),
          AppSpacing.gapXs,
          const Text(AppStrings.wrongHint),
          AppSpacing.gapM,
          for (final result in wrong) _WrongAnswerCard(result: result),
        ],
        AppSpacing.gapL,
        AppButton(label: AppStrings.backHome, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _WrongAnswerCard extends StatelessWidget {
  const _WrongAnswerCard({required this.result});

  final AnswerResult result;

  @override
  Widget build(BuildContext context) {
    final question = result.question;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MathText(question.body),
            if (question.hasImage) ...[AppSpacing.gapS, QuestionImage(question.imagePath!, compact: true)],
            AppSpacing.gapS,
            Text(
              AppStrings.yourVsRight(result.given ?? '-', question.correctAnswer),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
