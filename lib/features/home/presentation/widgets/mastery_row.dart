import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/topic_mastery.dart';

class MasteryRow extends StatelessWidget {
  const MasteryRow({super.key, required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forMastery(mastery.masteryPct);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(mastery.topicName)),
              Text(
                '${mastery.masteryPct}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          AppSpacing.gapXs,
          LinearProgressIndicator(value: mastery.masteryPct / 100, color: color, minHeight: 6),
        ],
      ),
    );
  }
}
