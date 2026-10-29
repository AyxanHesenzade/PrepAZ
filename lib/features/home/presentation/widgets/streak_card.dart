import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: scheme.onPrimaryContainer, size: 32),
            AppSpacing.gapM,
            Expanded(
              child: Text(
                days == 0 ? AppStrings.streakEmpty : AppStrings.streak(days),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
