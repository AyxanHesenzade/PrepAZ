import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../reports/presentation/report_sheet.dart';
import '../../domain/question.dart';

/// Sualın kodu (məs. KIM-0012) və "Xəta bildir" düyməsi. Kod toxunanda kopyalanır;
/// bildirişlə birlikdə sualın id-si və kodu avtomatik göndərilir.
class QuestionCodeLabel extends StatelessWidget {
  const QuestionCodeLabel({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final label = question.reportCode;
    final outline = Theme.of(context).colorScheme.outline;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: outline);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () => showReportSheet(context, question: question),
          style: TextButton.styleFrom(
            foregroundColor: outline,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            textStyle: small,
          ),
          icon: const Icon(Icons.flag_outlined, size: 16),
          label: Text(AppStrings.reportButton),
        ),
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: label));
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(AppStrings.codeCopied)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(AppStrings.questionCode(label), style: small, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}
