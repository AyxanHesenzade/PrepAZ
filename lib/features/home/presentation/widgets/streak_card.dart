import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Seriya: gradientli böyük kart, alov nişanı və iri yazı. Alov bir dəfə "sıçrayaraq" çıxır.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final active = days > 0;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandStart, AppColors.brandEnd],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -28,
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 32,
                      color: active ? AppColors.streak : Colors.white70,
                    ),
                  ),
                ),
                AppSpacing.gapM,
                Expanded(
                  child: Text(
                    active ? AppStrings.streak(days) : AppStrings.streakEmpty,
                    style: text.titleMedium?.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
