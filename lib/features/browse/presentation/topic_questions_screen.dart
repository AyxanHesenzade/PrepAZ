import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/math_text.dart';
import '../../../core/widgets/message_banner.dart';
import '../../quiz/presentation/widgets/letter_options.dart';
import '../../quiz/presentation/widgets/open_answer_input.dart';
import '../../quiz/presentation/widgets/option_tile.dart';
import '../../quiz/presentation/widgets/question_code_label.dart';
import '../../quiz/presentation/widgets/question_image.dart';
import '../domain/browse_topic.dart';
import 'topic_exam_controller.dart';
import 'topic_exam_state.dart';
import 'widgets/topic_result_view.dart';

/// Mövzunun testləri qaldığı yerdən. Düz/səhv göstərilmir, nəticə "Bitir"-dən sonra açılır.
class TopicQuestionsScreen extends ConsumerWidget {
  const TopicQuestionsScreen({
    super.key,
    required this.subjectId,
    required this.topic,
  });

  final int subjectId;
  final BrowseTopic topic;

  TopicExamKey get _key => (subjectId: subjectId, topicId: topic.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = topicExamControllerProvider(_key);
    final exam = ref.watch(provider);
    final s = exam.asData?.value;
    final solving = s != null && !s.finished && !s.isCompleted;
    return PopScope(
      canPop: s?.isSending != true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(topic.name),
          actions: [
            if (solving && s.given.isNotEmpty)
              TextButton(
                onPressed: s.isSending ? null : () => _finish(context, ref, s),
                child: Text(AppStrings.finishAction),
              ),
          ],
        ),
        body: SafeArea(
          child: AsyncValueView<TopicExamState>(
            value: exam,
            onRetry: () => ref.invalidate(provider),
            builder: (state) {
              final controller = ref.read(provider.notifier);
              if (state.finished) {
                return TopicResultView(
                  state: state,
                  onContinue: _hasMore(state) ? controller.continueSolving : null,
                );
              }
              if (state.all.isEmpty) {
                return Center(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: Text(AppStrings.noQuestionsInTopic),
                  ),
                );
              }
              if (state.isCompleted) {
                return _Completed(state: state, onRestart: controller.restart);
              }
              return _Exam(
                state: state,
                controller: controller,
                onFinish: () => _finish(context, ref, state),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Bu dəfə göndərilməyən testlər qalıb.
  bool _hasMore(TopicExamState s) =>
      s.all.any((q) => !s.latest.containsKey(q.id) && !s.results.containsKey(q.id));

  Future<void> _finish(BuildContext context, WidgetRef ref, TopicExamState s) async {
    final open = s.unanswered.length;
    if (open > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          content: Text(AppStrings.finishConfirm(open)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(AppStrings.continueSolving),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(AppStrings.finishAction),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(topicExamControllerProvider(_key).notifier).finish();
  }
}

class _Exam extends StatelessWidget {
  const _Exam({
    required this.state,
    required this.controller,
    required this.onFinish,
  });

  final TopicExamState state;
  final TopicExamController controller;
  final VoidCallback onFinish;

  Future<void> _jump(BuildContext context) async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _JumpSheet(state: state),
    );
    if (chosen != null) controller.go(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final q = state.current;
    final scheme = Theme.of(context).colorScheme;
    final picked = state.given[q.id];
    final canFinish = state.isLast && state.unanswered.isEmpty;

    OptionStatus statusOf(String letter) =>
        letter == picked ? OptionStatus.selected : OptionStatus.idle;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: state.numberOf(q) / state.all.length,
                ),
              ),
              AppSpacing.gapS,
              Text(
                AppStrings.questionOf(state.numberOf(q), state.all.length),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        if (state.isSending)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Text(AppStrings.sendingAnswers),
          ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: MessageBanner.error(AppStrings.answersNotSent),
          ),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(q.id),
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuestionCodeLabel(question: q),
                AppSpacing.gapXs,
                if (q.body.trim().isNotEmpty)
                  MathText(
                    q.body,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(height: 1.4),
                  ),
                if (q.hasImage) ...[
                  AppSpacing.gapM,
                  QuestionImage(q.imagePath!),
                ],
                AppSpacing.gapL,
                if (q.isClosed && q.isImageOnly)
                  LetterOptions(
                    letters: q.options.keys.toList(),
                    statusOf: statusOf,
                    onTap: controller.answer,
                  )
                else if (q.isClosed)
                  for (final e in q.options.entries)
                    OptionTile(
                      letter: e.key,
                      text: e.value,
                      status: statusOf(e.key),
                      onTap: () => controller.answer(e.key),
                    )
                else
                  OpenAnswerInput(
                    key: ValueKey('typed-${q.id}'),
                    question: q,
                    value: picked ?? '',
                    onChanged: controller.answer,
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: state.index == 0 || state.isSending
                    ? null
                    : () => controller.go(state.index - 1),
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(AppStrings.previousQuestion),
              ),
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: state.isSending ? null : () => _jump(context),
                    child: Text(AppStrings.jumpToQuestion),
                  ),
                ),
              ),
              if (canFinish)
                FilledButton(
                  onPressed: state.isSending ? null : onFinish,
                  child: Text(AppStrings.finishAction),
                )
              else
                TextButton.icon(
                  onPressed: state.isSending ? null : controller.next,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: Text(AppStrings.nextQuestion),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Completed extends StatelessWidget {
  const _Completed({required this.state, required this.onRestart});

  final TopicExamState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.topicDone,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacing.gapS,
            Text(
              AppStrings.topicCorrectOf(state.correctBefore, state.all.length),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapL,
            AppButton(label: AppStrings.restartTopic, onPressed: onRestart),
          ],
        ),
      ),
    );
  }
}

/// Nömrə şəbəkəsi: cavablananlar rəngli, hazırkı test çərçivəli. Düz/səhv göstərilmir.
class _JumpSheet extends StatelessWidget {
  const _JumpSheet({required this.state});

  final TopicExamState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          0,
          AppSpacing.m,
          AppSpacing.m,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 56,
            mainAxisSpacing: AppSpacing.s,
            crossAxisSpacing: AppSpacing.s,
          ),
          itemCount: state.questions.length,
          itemBuilder: (context, i) {
            final q = state.questions[i];
            final answered = state.given.containsKey(q.id);
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.m),
              onTap: () => Navigator.of(context).pop(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: answered
                      ? scheme.primary.withValues(alpha: 0.2)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(
                    color: i == state.index ? scheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text('${state.numberOf(q)}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
