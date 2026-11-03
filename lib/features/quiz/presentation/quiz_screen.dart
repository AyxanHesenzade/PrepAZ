import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/math_text.dart';
import '../../../core/widgets/soft_progress_bar.dart';
import '../../../core/widgets/message_banner.dart';
import '../../home/domain/subject.dart';
import '../domain/answer_result.dart';
import '../domain/cheer_policy.dart';
import '../domain/question.dart';
import '../domain/quiz_request.dart';
import 'cheer_text.dart';
import 'quiz_controller.dart';
import 'quiz_providers.dart';
import 'quiz_state.dart';
import 'result_view.dart';
import 'widgets/answer_feedback.dart';
import 'widgets/cheer_overlay.dart';
import 'widgets/letter_options.dart';
import 'widgets/open_answer_input.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_code_label.dart';
import 'widgets/question_image.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({
    super.key,
    required this.subject,
    this.kind = QuizKind.daily,
    this.topicId,
  });

  final Subject subject;
  final QuizKind kind;
  final int? topicId;

  QuizRequest get _request => switch (kind) {
    QuizKind.daily => QuizRequest.daily(subject.id),
    QuizKind.topic => QuizRequest.topic(subject.id, topicId!),
    QuizKind.mistakes => QuizRequest.mistakes(subject.id),
  };

  String get _emptyMessage => switch (kind) {
    QuizKind.daily => AppStrings.noQuestionsLeft,
    QuizKind.topic => AppStrings.noQuestionsInTopic,
    QuizKind.mistakes => AppStrings.noMistakes,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quizControllerProvider(_request);
    final value = ref.watch(provider);
    final title = value.maybeWhen(
      data: (s) => s.isFinished
          ? AppStrings.resultTitle(subject.name)
          : s.isEmpty
          ? subject.name
          : AppStrings.questionOf(s.index + 1, s.questions.length),
      orElse: () => subject.name,
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: AsyncValueView<QuizState>(
          value: value,
          onRetry: () => ref.invalidate(provider),
          builder: (state) {
            if (state.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(_emptyMessage, textAlign: TextAlign.center),
                ),
              );
            }
            if (state.isFinished) return ResultView(results: state.results);
            return _QuestionBody(
              state: state,
              controller: ref.read(provider.notifier),
              // Köməkçinin sözləri hələlik yalnız "Bugünkü məşq"-dədir
              cheerFor: kind == QuizKind.daily ? subject.slug : null,
              cheerRandom: ref.read(cheerRandomProvider),
              animateMascot: ref.watch(mascotMotionProvider),
            );
          },
        ),
      ),
    );
  }
}

class _QuestionBody extends StatefulWidget {
  const _QuestionBody({
    required this.state,
    required this.controller,
    required this.cheerFor,
    required this.cheerRandom,
    required this.animateMascot,
  });

  final QuizState state;
  final QuizController controller;

  /// Fənn kodu (kimya, biologiya...). null = bu məşqdə köməkçi danışmır.
  final String? cheerFor;
  final Random cheerRandom;
  final bool animateMascot;

  @override
  State<_QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<_QuestionBody> {
  final _feedbackKey = GlobalKey();
  String? _cheerMessage;
  int _cheerToken = 0;

  QuizState get state => widget.state;
  QuizController get controller => widget.controller;

  /// Uzun sualda (şəkil + 5 variant) izah ekrandan aşağıda qalır: cavabdan sonra ona sürüşdür.
  @override
  void didUpdateWidget(_QuestionBody old) {
    super.didUpdateWidget(old);
    if (!old.state.isAnswered && state.isAnswered) {
      _cheerAfterAnswer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final feedback = _feedbackKey.currentContext;
        if (feedback != null && feedback.mounted) {
          Scrollable.ensureVisible(
            feedback,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Cavabdan sonra köməkçi nə deyəcək: ardıcıl düzlərə görə (bax `CheerPolicy`). Ardıcıl səhvlərə heç nə.
  void _cheerAfterAnswer() {
    final slug = widget.cheerFor;
    if (slug == null) return;
    final cheer = CheerPolicy.after([for (final r in state.results) r.isCorrect]);
    if (cheer == null) return;
    _cheerMessage = cheerText(cheer, subjectSlug: slug, random: widget.cheerRandom);
    _cheerToken++;
  }

  @override
  Widget build(BuildContext context) {
    final question = state.current;
    final result = state.currentResult;
    final answered = result != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBody(context, question, result, answered),
        Positioned(
          top: AppSpacing.s,
          left: 0,
          right: 0,
          child: CheerOverlay(
            message: _cheerMessage,
            token: _cheerToken,
            animateMascot: widget.animateMascot,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Question question, AnswerResult? result, bool answered) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m + 4),
          child: SoftProgressBar(
            value: (state.index + (answered ? 1 : 0)) / state.questions.length,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuestionCodeLabel(question: question),
                AppSpacing.gapXs,
                if (question.body.trim().isNotEmpty)
                  MathText(
                    question.body,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(height: 1.4),
                  ),
                if (question.hasImage) ...[
                  AppSpacing.gapM,
                  QuestionImage(question.imagePath!),
                ],
                AppSpacing.gapL,
                if (question.isClosed && question.isImageOnly)
                  LetterOptions(
                    letters: question.options.keys.toList(),
                    statusOf: (letter) => _statusOf(letter, question, state),
                    onTap: answered ? null : controller.select,
                  )
                else if (question.isClosed)
                  for (final entry in question.options.entries)
                    OptionTile(
                      letter: entry.key,
                      text: entry.value,
                      status: _statusOf(entry.key, question, state),
                      onTap: answered
                          ? null
                          : () => controller.select(entry.key),
                    )
                else
                  OpenAnswerInput(
                    key: ValueKey(question.id),
                    question: question,
                    value: state.input,
                    enabled: !answered,
                    onChanged: controller.type,
                  ),
                if (result != null) ...[
                  AppSpacing.gapL,
                  KeyedSubtree(
                    key: _feedbackKey,
                    child: AnswerFeedback(result: result),
                  ),
                ],
                if (state.error != null) ...[
                  AppSpacing.gapM,
                  MessageBanner.error(state.error!),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m + 4,
            AppSpacing.s,
            AppSpacing.m + 4,
            AppSpacing.m,
          ),
          child: answered
              ? SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: state.isLast
                        ? AppStrings.toResult
                        : AppStrings.nextQuestion,
                    onPressed: controller.next,
                  ),
                )
              : Row(
                  children: [
                    TextButton(
                      onPressed: state.isSending
                          ? null
                          : () => controller.check(skip: true),
                      child: Text(AppStrings.dontKnow),
                    ),
                    AppSpacing.gapS,
                    Expanded(
                      child: AppButton(
                        label: AppStrings.check,
                        isLoading: state.isSending,
                        onPressed: state.canSubmit ? controller.check : null,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  OptionStatus _statusOf(String letter, Question question, QuizState state) {
    final result = state.currentResult;
    if (result == null) {
      return letter == state.selected
          ? OptionStatus.selected
          : OptionStatus.idle;
    }
    if (letter == question.correctAnswer.toUpperCase()) {
      return OptionStatus.correct;
    }
    if (letter == result.given) return OptionStatus.wrong;
    return OptionStatus.idle;
  }
}
