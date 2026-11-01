import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/math_text.dart';
import '../../../quiz/domain/answer_result.dart';
import '../../../quiz/presentation/widgets/question_image.dart';
import '../topic_exam_state.dart';

/// "Bitir"-dən sonra: bu dəfənin nəticəsi, mövzunun irəliləyişi və hər test üçün düz/səhv.
class TopicResultView extends StatelessWidget {
  const TopicResultView({super.key, required this.state, this.onContinue});

  final TopicExamState state;

  /// null = davam ediləcək test qalmayıb.
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final results = state.orderedResults;
    final correct = results.where((r) => r.isCorrect).length;
    final text = Theme.of(context).textTheme;
    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: results.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.l),
            child: Column(
              children: [
                Text('$correct / ${results.length}', style: text.displaySmall),
                AppSpacing.gapS,
                Text(
                  AppStrings.topicProgressChange(
                    state.correctBefore,
                    state.correctAfter,
                    state.all.length,
                  ),
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
              ],
            ),
          );
        }
        if (i == results.length + 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.gapM,
              if (onContinue != null) ...[
                AppButton(label: AppStrings.continueSolving, onPressed: onContinue),
                AppSpacing.gapS,
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.backToTopics),
              ),
            ],
          );
        }
        final result = results[i - 1];
        return _ResultCard(number: state.numberOf(result.question), result: result);
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.number, required this.result});

  final int number;
  final AnswerResult result;

  @override
  Widget build(BuildContext context) {
    final question = result.question;
    final text = Theme.of(context).textTheme;
    final color = result.isCorrect ? AppColors.success : AppColors.danger;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: color,
                ),
                AppSpacing.gapS,
                Text('$number', style: text.titleSmall),
              ],
            ),
            AppSpacing.gapS,
            if (question.body.trim().isNotEmpty) MathText(question.body),
            if (question.hasImage) ...[
              AppSpacing.gapS,
              QuestionImage(question.imagePath!, compact: !question.isImageOnly),
            ],
            AppSpacing.gapS,
            Text(
              AppStrings.yourVsRight(
                question.formatAnswer(result.given),
                question.rightAnswerText,
              ),
              style: text.labelLarge?.copyWith(color: color),
            ),
            if (question.hasSolution) ...[
              AppSpacing.gapS,
              Text(AppStrings.solution, style: text.labelLarge),
              AppSpacing.gapXs,
              if (question.hasSolutionImage)
                QuestionImage(question.solutionImagePath!)
              else
                MathText(question.solution!),
            ],
          ],
        ),
      ),
    );
  }
}
