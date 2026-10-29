import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/subject.dart';
import '../../domain/topic_mastery.dart';
import 'mastery_row.dart';

/// Fənn kartı: ən zəif 3 mövzu və məşqə başlama düyməsi.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.weakTopics,
    required this.onStart,
  });

  /// Ən zəifdən başlayaraq, artıq sıralanmış.
  static const maxTopicsShown = 3;

  final Subject subject;
  final List<TopicMastery> weakTopics;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final shown = weakTopics.take(maxTopicsShown).toList();
    return Card(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject.name, style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapS,
            if (shown.isEmpty)
              const Text(AppStrings.noMasteryYet)
            else ...[
              Text(AppStrings.weakTopics, style: Theme.of(context).textTheme.labelMedium),
              for (final topic in shown) MasteryRow(mastery: topic),
            ],
            AppSpacing.gapM,
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(onPressed: onStart, child: const Text(AppStrings.startQuiz)),
            ),
          ],
        ),
      ),
    );
  }
}
