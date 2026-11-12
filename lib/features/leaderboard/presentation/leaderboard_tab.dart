import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../home/presentation/home_providers.dart';
import '../domain/leaderboard.dart';
import 'leaderboard_providers.dart';
import 'widgets/board_header.dart';
import 'widgets/leaderboard_list.dart';
import 'widgets/player_form.dart';

/// Alt menyudakı "Yarış". Şagird qoşulmayıbsa əvvəl nik-ad forması, sonra fənn üzrə cədvəl.
class LeaderboardTab extends ConsumerWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: ref.watch(myPlayerProvider),
          onRetry: () => ref.invalidate(myPlayerProvider),
          builder: (player) => player == null
              ? _JoinView(onJoined: () => ref.invalidate(myPlayerProvider))
              : _BoardView(player: player),
        ),
      ),
    );
  }
}

class _JoinView extends StatelessWidget {
  const _JoinView({required this.onJoined});

  final VoidCallback onJoined;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m + 4,
        AppSpacing.l,
        AppSpacing.m + 4,
        AppSpacing.l,
      ),
      children: [
        FadeSlideIn(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.brandStart, AppColors.brandEnd],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 56,
                  color: AppColors.gold,
                ),
                AppSpacing.gapM,
                Text(
                  AppStrings.joinTitle,
                  style: text.headlineSmall?.copyWith(color: Colors.white),
                ),
                AppSpacing.gapS,
                Text(
                  AppStrings.joinText,
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapL,
        FadeSlideIn(
          index: 1,
          child: PlayerForm(
            actionLabel: AppStrings.joinAction,
            onSaved: onJoined,
          ),
        ),
      ],
    );
  }
}

class _BoardView extends ConsumerStatefulWidget {
  const _BoardView({required this.player});

  final Player player;

  @override
  ConsumerState<_BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<_BoardView> {
  int? _subjectId;

  Future<void> _editPlayer() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _EditPlayerScreen(player: widget.player)),
    );
    if (saved == true) {
      ref.invalidate(myPlayerProvider);
      ref.invalidate(leaderboardProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncValueView(
      value: ref.watch(subjectsProvider),
      onRetry: () => ref.invalidate(subjectsProvider),
      builder: (subjects) {
        if (subjects.isEmpty) return Center(child: Text(AppStrings.noSubjects));
        final subject = subjects.firstWhere(
          (s) => s.id == _subjectId,
          orElse: () => subjects.first,
        );
        final accent = AppColors.subjectAccent(subject.slug, subject.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m + 4,
                AppSpacing.m,
                AppSpacing.m + 4,
                0,
              ),
              child: FadeSlideIn(
                child: BoardHeader(
                  subjects: subjects,
                  selected: subject,
                  nickname: widget.player.nickname,
                  onSubjectChanged: (id) => setState(() => _subjectId = id),
                  onEditPlayer: _editPlayer,
                ),
              ),
            ),
            Expanded(
              child: LeaderboardList(
                subjectId: subject.id,
                accent: accent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EditPlayerScreen extends StatelessWidget {
  const _EditPlayerScreen({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editPlayerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m + 4),
        children: [
          PlayerForm(
            initial: player,
            actionLabel: AppStrings.saveAction,
            onSaved: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
