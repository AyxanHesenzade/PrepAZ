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
    final color = AppColors.forMastery(mastery.masteryPct);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s - 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(mastery.topicName, style: text.bodyMedium)),
              Text(
                '${mastery.masteryPct}%',
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
