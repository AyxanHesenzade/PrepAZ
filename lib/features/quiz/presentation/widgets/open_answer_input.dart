import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/question.dart';
import 'letter_options.dart';
import 'option_tile.dart';

/// Açıq sualın cavabı: uyğunlaşdırmada cədvəl, qalan tiplərdə yazı xanası.
/// Sual dəyişəndə `key` sayəsində təzədən yaranır.
class OpenAnswerInput extends StatelessWidget {
  const OpenAnswerInput({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final Question question;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (question.isMatching) {
      return MatchingGrid(
        question: question,
        value: value,
        onChanged: enabled ? onChanged : null,
      );
    }
    return _AnswerField(
      question: question,
      initial: value,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class _AnswerField extends StatefulWidget {
  const _AnswerField({
    required this.question,
    required this.initial,
    required this.enabled,
    required this.onChanged,
  });

  final Question question;
  final String initial;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<_AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<_AnswerField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.question.type;
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      keyboardType: switch (type) {
        QuestionType.aciqEded => const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        QuestionType.coxluSecim => TextInputType.number,
        _ => TextInputType.text,
      },
      inputFormatters: type == QuestionType.coxluSecim
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: AppStrings.yourAnswerField,
        helperText: type == QuestionType.coxluSecim
            ? AppStrings.multiAnswerHint
            : null,
      ),
    );
  }
}

/// Uyğunlaşdırma: hər sətirdə bir neçə hərf seçilə bilər. Cavab `E;A;BC` şəklindədir
/// (sətirlər yerinə görə, boş sətir boş qalır), hamısı boşdursa boş sətir.
class MatchingGrid extends StatelessWidget {
  const MatchingGrid({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final Question question;
  final String value;

  /// null olanda toxunmaq olmur (cavab artıq yoxlanıb).
  final ValueChanged<String>? onChanged;

  List<String> get _rows => question.options.keys.toList();

  List<String> get _picked {
    final parts = value.split(';');
    return [
      for (var i = 0; i < _rows.length; i++)
        i < parts.length ? parts[i] : '',
    ];
  }

  void _toggle(int row, String letter) {
    final picked = _picked;
    final letters = picked[row].split('').where((l) => l.isNotEmpty).toSet();
    if (!letters.remove(letter)) letters.add(letter);
    picked[row] = (letters.toList()..sort()).join();
    onChanged!(picked.every((p) => p.isEmpty) ? '' : picked.join(';'));
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final picked = _picked;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.matchingHint, style: text.bodySmall),
        AppSpacing.gapS,
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('${rows[i]}.', style: text.titleMedium),
                ),
                for (final letter in question.options[rows[i]]!.split(''))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: LetterButton(
                        letter: letter.toLowerCase(),
                        height: 48,
                        status: picked[i].contains(letter)
                            ? OptionStatus.selected
                            : OptionStatus.idle,
                        onTap: onChanged == null
                            ? null
                            : () => _toggle(i, letter),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
