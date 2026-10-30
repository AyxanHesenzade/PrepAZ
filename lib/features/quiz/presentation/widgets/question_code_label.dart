import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/question.dart';

/// Sualın kodu (məs. KIM-0012). Şagird problem bildirəndə bunu yazır; toxunanda kopyalanır.
class QuestionCodeLabel extends StatelessWidget {
  const QuestionCodeLabel({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final label = question.reportCode;
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          await Clipboard.setData(ClipboardData(text: label));
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text(AppStrings.codeCopied)));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            AppStrings.questionCode(label),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      ),
    );
  }
}
