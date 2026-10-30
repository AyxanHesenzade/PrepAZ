import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/soft_progress_bar.dart';

/// Ana ekranda imtahana qalan gün və bu günkü hədəf zolağı. [daysLeft] null olanda seçim təklif edir.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.daysLeft,
    required this.answeredToday,
    required this.dailyGoal,
    required this.onTap,
  });

  final int? daysLeft;
  final int answeredToday;
  final int dailyGoal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final reached = answeredToday >= dailyGoal;
    final title = switch (daysLeft) {
      null => AppStrings.goalDateUnknown,
      0 => AppStrings.goalExamToday,
      final d => AppStrings.goalDaysLeft(d),
    };
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: scheme.primary),
                AppSpacing.gapS,
                Expanded(child: Text(title, style: text.titleMedium)),
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
            AppSpacing.gapM,
            SoftProgressBar(
              value: dailyGoal == 0 ? 0 : answeredToday / dailyGoal,
              color: reached ? AppColors.success : scheme.primary,
            ),
            AppSpacing.gapS,
            Text(
              reached
                  ? AppStrings.goalReached
                  : AppStrings.goalToday(answeredToday, dailyGoal),
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
