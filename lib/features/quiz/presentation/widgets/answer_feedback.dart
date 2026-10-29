import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/math_text.dart';
import '../../domain/answer_result.dart';
import '../../domain/question.dart';
import 'question_image.dart';

/// Cavabdan sonra: düz/səhv, düzgün cavab və müəllimin yazdığı həll.
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({super.key, required this.result});

  final AnswerResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final question = result.question;
    final pending = question.type == QuestionType.yazili;
    final title = pending
        ? AppStrings.writtenPending
        : result.isCorrect
            ? AppStrings.correct
            : AppStrings.wrong(question.correctAnswer);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: result.isCorrect ? AppColors.success.withValues(alpha: 0.12) : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (question.hasSolution) ...[
            AppSpacing.gapS,
            Text(AppStrings.solution, style: const TextStyle(fontWeight: FontWeight.w500)),
            AppSpacing.gapXs,
            if (question.hasSolutionImage)
              QuestionImage(question.solutionImagePath!)
            else
              MathText(question.solution!),
          ],
          if (!result.isCorrect && !pending) ...[
            AppSpacing.gapS,
            Text(
              AppStrings.savedForReview,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
