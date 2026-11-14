import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/subject_stats.dart';

/// Son 7 günün sütun qrafiki: sütunun hündürlüyü = cavab sayı, aşağı hissəsi düz, yuxarısı səhv.
/// Altında keçən həftə ilə müqayisə.
class WeekChart extends StatelessWidget {
  const WeekChart({super.key, required this.stats, required this.accent});

  static const _barArea = 120.0;

  final SubjectStats stats;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final week = stats.thisWeek;
    final peak = week.fold(0, (m, d) => max(m, d.answered));
    final delta = stats.weekDelta;
    final deltaColor = delta > 0
        ? AppColors.success
        : delta < 0
        ? AppColors.warning
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.statsWeekTitle,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                AppStrings.statsWeekTotal(stats.thisWeekAnswered),
                style: text.labelLarge?.copyWith(color: accent),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            AppStrings.statsWeekDelta(delta),
            style: text.bodySmall?.copyWith(color: deltaColor),
          ),
          AppSpacing.gapM,
          SizedBox(
            height: _barArea + 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, day) in week.indexed)
                  Expanded(
                    child: _Bar(
                      day: day,
                      fraction: peak == 0 ? 0 : day.answered / peak,
                      isToday: i == week.length - 1,
                      accent: accent,
                      area: _barArea,
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.gapS,
          Row(
            children: [
              _LegendDot(color: accent, label: AppStrings.statsLegendCorrect),
              AppSpacing.gapM,
              _LegendDot(
                color: accent.withValues(alpha: 0.3),
                label: AppStrings.statsLegendWrong,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.day,
    required this.fraction,
    required this.isToday,
    required this.accent,
    required this.area,
  });

  final DayStat day;
  final double fraction;
  final bool isToday;
  final Color accent;
  final double area;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final rightShare = day.answered == 0 ? 0.0 : day.correct / day.answered;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          day.answered == 0 ? '' : '${day.answered}',
          style: text.labelSmall?.copyWith(
            color: isToday ? accent : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(end: fraction),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, f, _) {
            // boş gün də nazik xətt kimi görünür
            final height = max(area * f, 4.0);
            return Container(
              width: 22,
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: day.answered == 0
                    ? scheme.surfaceContainerHighest
                    : accent.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: rightShare,
                widthFactor: 1,
                child: ColoredBox(color: accent),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.statsWeekday(day.day.weekday),
          style: text.labelSmall?.copyWith(
            color: isToday ? accent : scheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
