import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/subject_stats.dart';

/// Üç kiçik kart: düz cavab faizi, cavab sayı, ən uzun seriya.
class StatTiles extends StatelessWidget {
  const StatTiles({super.key, required this.stats, required this.accent});

  final SubjectStats stats;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tile(
            icon: Icons.check_circle_rounded,
            color: AppColors.forMastery(stats.accuracyPct),
            value: '${stats.accuracyPct}%',
            label: AppStrings.statsAccuracy,
          ),
        ),
        AppSpacing.gapS,
        Expanded(
          child: _Tile(
            icon: Icons.edit_note_rounded,
            color: accent,
            value: '${stats.answered}',
            label: AppStrings.statsAnswered,
          ),
        ),
        AppSpacing.gapS,
        Expanded(
          child: _Tile(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.streak,
            value: AppStrings.statsDays(stats.bestStreak),
            label: AppStrings.statsBestStreak,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s + 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          AppSpacing.gapS,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
