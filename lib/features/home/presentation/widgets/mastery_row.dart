import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/soft_progress_bar.dart';
import '../../domain/topic_mastery.dart';

class MasteryRow extends StatelessWidget {
  const MasteryRow({super.key, required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rated = mastery.isWeak || mastery.isStrong;
    final color = rated
        ? AppColors.forMastery(mastery.masteryPct)
        : Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s - 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(mastery.topicName, style: text.bodyMedium)),
              Text(
                '${mastery.masteryPct}% · ${mastery.correct}/${mastery.total}',
                style: text.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
          AppSpacing.gapS,
          SoftProgressBar(value: mastery.masteryPct / 100, color: color),
        ],
      ),
    );
  }
}

/// Başlıq və altında mövzular: "Zəif mövzular", "Yaxşı bildiyin mövzular".
class MasteryGroup extends StatelessWidget {
  const MasteryGroup({super.key, required this.title, required this.topics});

  final String title;
  final List<TopicMastery> topics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapXs,
        for (final topic in topics) MasteryRow(mastery: topic),
      ],
    );
  }
}
