import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/math_text.dart';
import '../../quiz/domain/question.dart';
import '../../quiz/presentation/widgets/letter_options.dart';
import '../../quiz/presentation/widgets/option_tile.dart';
import '../../quiz/presentation/widgets/question_code_label.dart';
import '../../quiz/presentation/widgets/question_image.dart';
import '../domain/browse_topic.dart';
import 'browse_providers.dart';

/// Mövzunun sualları ardıcıl. İstənilən suala keçmək olur. Cavab yalnız ekranda göstərilir, bazaya yazılmır.
class TopicQuestionsScreen extends ConsumerWidget {
  const TopicQuestionsScreen({super.key, required this.topic});

  final BrowseTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = browseQuestionsProvider(topic.id);
    return Scaffold(
      appBar: AppBar(title: Text(topic.name)),
      body: SafeArea(
        child: AsyncValueView<List<Question>>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          builder: (questions) {
            if (questions.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text(AppStrings.noQuestionsInTopic),
                ),
              );
            }
            return _Browser(questions: questions);
          },
        ),
      ),
    );
  }
}

class _Browser extends StatefulWidget {
  const _Browser({required this.questions});

  final List<Question> questions;

  @override
  State<_Browser> createState() => _BrowserState();
}

class _BrowserState extends State<_Browser> {
  int _index = 0;

  /// Sual id -> seçilən hərf. Yalnız bu ekranın yaddaşında.
  final _picked = <String, String>{};
  final _revealed = <String>{};

  List<Question> get _questions => widget.questions;

  bool _isRight(Question q, String letter) =>
      letter.toUpperCase() == q.correctAnswer.toUpperCase();

  void _go(int i) => setState(() => _index = i.clamp(0, _questions.length - 1));

  Future<void> _jump() async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _JumpSheet(
        questions: _questions,
        current: _index,
        statusOf: (q) {
          final p = _picked[q.id];
          return p == null ? null : _isRight(q, p);
        },
      ),
    );
    if (chosen != null) _go(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final scheme = Theme.of(context).colorScheme;
    final picked = _picked[q.id];
    final showResult = picked != null || _revealed.contains(q.id);

    OptionStatus statusOf(String letter) {
      if (!showResult) return OptionStatus.idle;
      if (_isRight(q, letter)) return OptionStatus.correct;
      if (letter == picked) return OptionStatus.wrong;
      return OptionStatus.idle;
    }

    void pick(String letter) => setState(() => _picked[q.id] = letter);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                ),
              ),
              AppSpacing.gapS,
              Text(
                AppStrings.questionOf(_index + 1, _questions.length),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
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
                    onTap: pick,
                  )
                else if (q.isClosed)
                  for (final e in q.options.entries)
                    OptionTile(
                      letter: e.key,
                      text: e.value,
                      status: statusOf(e.key),
                      onTap: () => pick(e.key),
                    )
                else if (!showResult)
                  OutlinedButton(
                    onPressed: () => setState(() => _revealed.add(q.id)),
                    child: Text(AppStrings.showAnswer),
                  ),
                if (showResult) ...[
                  AppSpacing.gapM,
                  _Verdict(
                    question: q,
                    picked: picked,
                    right: picked != null && _isRight(q, picked),
                  ),
                ],
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
                onPressed: _index == 0 ? null : () => _go(_index - 1),
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(AppStrings.previousQuestion),
              ),
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: _jump,
                    child: Text(AppStrings.jumpToQuestion),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _index == _questions.length - 1
                    ? null
                    : () => _go(_index + 1),
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

class _Verdict extends StatelessWidget {
  const _Verdict({
    required this.question,
    required this.picked,
    required this.right,
  });

  final Question question;
  final String? picked;
  final bool right;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = picked == null
        ? scheme.outline
        : (right ? AppColors.success : scheme.error);
    final title = picked == null
        ? AppStrings.rightAnswer(question.correctAnswer)
        : right
        ? AppStrings.correct
        : AppStrings.wrong(question.correctAnswer);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
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
        ],
      ),
    );
  }
}

/// Nömrə şəbəkəsi: cavablananlar yaşıl/qırmızı, hazırkı sual çərçivəli.
class _JumpSheet extends StatelessWidget {
  const _JumpSheet({
    required this.questions,
    required this.current,
    required this.statusOf,
  });

  final List<Question> questions;
  final int current;

  /// null = cavablanmayıb, true = düz, false = səhv.
  final bool? Function(Question) statusOf;

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
          itemCount: questions.length,
          itemBuilder: (context, i) {
            final s = statusOf(questions[i]);
            final color = s == null
                ? scheme.surfaceContainerHighest
                : (s ? AppColors.success : scheme.error).withValues(alpha: 0.2);
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.m),
              onTap: () => Navigator.of(context).pop(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(
                    color: i == current ? scheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text('${i + 1}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
