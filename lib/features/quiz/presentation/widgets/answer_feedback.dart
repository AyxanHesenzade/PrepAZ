import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
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

    final accent = pending
        ? scheme.outline
        : result.isCorrect
        ? AppColors.success
        : scheme.error;
    final icon = pending
        ? Icons.hourglass_empty_rounded
        : result.isCorrect
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m + 2),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent),
                AppSpacing.gapS,
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (question.hasSolution) ...[
              AppSpacing.gapM,
              Text(
                AppStrings.solution,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              AppSpacing.gapS,
              if (question.hasSolutionImage)
                QuestionImage(question.solutionImagePath!)
              else
                MathText(question.solution!),
            ],
            if (!result.isCorrect && !pending) ...[
              AppSpacing.gapM,
              Text(
                AppStrings.savedForReview,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
