import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../data/supabase_leaderboard_repository.dart';
import '../../domain/leaderboard.dart';
import '../leaderboard_providers.dart';
import 'podium.dart';

/// Podium (ilk 3), qalan yerlər və aşağıda sabit "Sən" zolağı.
class LeaderboardList extends ConsumerWidget {
  const LeaderboardList({
    super.key,
    required this.subjectId,
    required this.accent,
  });

  final int subjectId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = subjectId;
    return AsyncValueView(
      value: ref.watch(leaderboardProvider(key)),
      onRetry: () => ref.invalidate(leaderboardProvider(key)),
      builder: (board) {
        final top = [
          for (final e in board.entries)
            if (e.rank <= SupabaseLeaderboardRepository.topLimit) e,
        ];
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(leaderboardProvider(key).future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m + 4,
                    AppSpacing.m,
                    AppSpacing.m + 4,
                    AppSpacing.l,
                  ),
                  children: [
                    if (top.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl),
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 64,
                              color: accent.withValues(alpha: 0.6),
                            ),
                            AppSpacing.gapM,
                            Text(
                              AppStrings.leaderboardEmpty,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      FadeSlideIn(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s,
                            AppSpacing.m,
                            AppSpacing.s,
                            0,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accent.withValues(alpha: 0.14),
                                accent.withValues(alpha: 0.03),
                              ],
                            ),
                          ),
                          child: Podium(entries: top.take(3).toList(), accent: accent),
                        ),
                      ),
                      AppSpacing.gapM,
                      for (final (i, e) in top.skip(3).indexed)
                        FadeSlideIn(
                          index: i < 8 ? i + 1 : 8,
                          child: LeaderboardRow(entry: e, accent: accent),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            _MyRankBar(me: board.me, accent: accent),
          ],
        );
      },
    );
  }
}

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.entry, required this.accent});

  final LeaderboardEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s + 4,
      ),
      decoration: BoxDecoration(
        color: entry.isMe
            ? accent.withValues(alpha: 0.14)
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: entry.isMe ? Border.all(color: accent, width: 1.5) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${entry.rank}',
              style: text.titleMedium?.copyWith(color: scheme.outline),
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: accent.withValues(alpha: 0.18),
            child: Text(
              _initial(entry.nickname),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
          AppSpacing.gapM,
          Expanded(
            child: Text(
              entry.isMe ? '${entry.nickname} (${AppStrings.youLabel})' : entry.nickname,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall,
            ),
          ),
          Text(
            AppStrings.points(entry.score),
            style: text.titleSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _initial(String nickname) =>
    nickname.isEmpty ? '?' : nickname.characters.first.toUpperCase();

class _MyRankBar extends StatelessWidget {
  const _MyRankBar({required this.me, required this.accent});

  final LeaderboardEntry? me;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final me = this.me;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.m + 4,
        0,
        AppSpacing.m + 4,
        AppSpacing.s,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s + 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, AppColors.brandEnd, 0.5)!],
        ),
      ),
      child: Row(
        children: [
          Icon(
            me == null ? Icons.rocket_launch_rounded : Icons.military_tech_rounded,
            color: Colors.white,
          ),
          AppSpacing.gapS,
          Expanded(
            child: Text(
              me == null ? AppStrings.myRankNone : AppStrings.myRank(me.rank, me.score),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
