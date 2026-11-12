import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/leaderboard.dart';

/// İlk üç yer: ortada birinci (ən hündür, tac ilə), solda ikinci, sağda üçüncü.
/// Sütunlar bir dəfə aşağıdan böyüyür (sonsuz animasiya yoxdur).
class Podium extends StatelessWidget {
  const Podium({super.key, required this.entries, required this.accent});

  final List<LeaderboardEntry> entries;
  final Color accent;

  static const _heights = [118.0, 88.0, 66.0];
  static const _medals = [AppColors.gold, AppColors.silver, AppColors.bronze];

  @override
  Widget build(BuildContext context) {
    // ekranda sıra: 2-ci, 1-ci, 3-cü
    const order = [1, 0, 2];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final place in order)
          Expanded(
            child: place < entries.length
                ? _Column(
                    entry: entries[place],
                    height: _heights[place],
                    medal: _medals[place],
                    accent: accent,
                    first: place == 0,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.entry,
    required this.height,
    required this.medal,
    required this.accent,
    required this.first,
  });

  final LeaderboardEntry entry;
  final double height;
  final Color medal;
  final Color accent;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = first ? 34.0 : 27.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (first)
            const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 30),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, color: medal),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: Text(
                entry.nickname.isEmpty
                    ? '?'
                    : entry.nickname.characters.first.toUpperCase(),
                style: text.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          AppSpacing.gapXs,
          Text(
            entry.isMe ? AppStrings.youLabel : entry.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall?.copyWith(
              fontWeight: entry.isMe ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            AppStrings.points(entry.score),
            style: text.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapXs,
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: height),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, h, child) =>
                ClipRect(child: SizedBox(height: h < 0 ? 0 : h, child: child)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.s),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [medal, medal.withValues(alpha: 0.55)],
                ),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: AppSpacing.s),
              child: Text(
                '${entry.rank}',
                style: text.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
