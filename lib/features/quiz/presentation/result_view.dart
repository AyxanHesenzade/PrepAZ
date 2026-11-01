import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
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
        AppSpacing.gapM,
        Center(
          child: SizedBox(
            width: 184,
            height: 184,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: total == 0 ? 0 : correct / total),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      color: AppColors.forMastery(percent),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                  ),
                ),
                Text('$correct / $total', style: text.displaySmall),
              ],
            ),
          ),
        ),
        AppSpacing.gapM,
        Center(
          child: Text(
            AppStrings.percentCorrect(percent),
            style: text.titleMedium,
          ),
        ),
        AppSpacing.gapL,
        if (wrong.isEmpty)
          Center(child: Text(AppStrings.allCorrect, style: text.bodyLarge))
        else ...[
          Text(AppStrings.wrongTitle(wrong.length), style: text.titleMedium),
          AppSpacing.gapXs,
          Text(
            AppStrings.wrongHint,
            style: text.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapM,
          for (final result in wrong) _WrongAnswerCard(result: result),
        ],
        AppSpacing.gapL,
        AppButton(
          label: AppStrings.backHome,
          onPressed: () => Navigator.of(context).pop(),
        ),
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
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.body.trim().isNotEmpty) MathText(question.body),
            // şəkil-sualda sualın özü şəkildir: kiçildilmir
            if (question.hasImage) ...[
              AppSpacing.gapS,
              QuestionImage(
                question.imagePath!,
                compact: !question.isImageOnly,
              ),
            ],
            AppSpacing.gapS,
            Text(
              AppStrings.yourVsRight(
                question.formatAnswer(result.given),
                question.rightAnswerText,
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
