import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/logging/app_log.dart';
import '../../../core/widgets/glass_nav_bar.dart';
import '../../home/presentation/home_providers.dart';
import '../../home/presentation/home_screen.dart';
import '../../leaderboard/presentation/leaderboard_providers.dart';
import '../../leaderboard/presentation/leaderboard_tab.dart';
import '../../reminders/presentation/reminder_sync.dart';
import '../../stats/presentation/stats_providers.dart';
import '../../stats/presentation/stats_tab.dart';
import '../../tour/presentation/tour_controller.dart';
import '../../tour/presentation/tour_targets.dart';
import '../../tour/presentation/widgets/tour_overlay.dart';
import '../../whats_new/presentation/whats_new_check.dart';

/// Daxil olandan sonrakı əsas ekran: aşağıda menyu (Ana səhifə, İrəliləyiş, Yarış).
/// Tablar `IndexedStack`-dədir: keçəndə ana səhifənin vəziyyəti itmir.
/// "İrəliləyiş" və "Yarış" ilk dəfə basılana qədər qurulmur (lazımsız sorğu getməsin).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _home = 0;
  static const _progress = 1;
  static const _compete = 2;

  int _index = _home;
  final _opened = <int>{_home};

  /// Turun açarları burada yaşayır (qlobal yox, bax `TourScope`): tur alt menyunu da göstərir.
  final _tour = TourTargets(hasBottomNav: true);

  void _select(int index) {
    if (index != _index) {
      AppLog.info('tab', meta: {'tab': const ['home', 'progress', 'compete'][index]});
    }
    // geri qayıdanda rəqəmlər təzə olsun (ana səhifədə test həll edilmiş ola bilər)
    if (_opened.contains(index)) {
      if (index == _progress) {
        ref.invalidate(subjectStatsProvider);
        ref.invalidate(masteryProvider);
      }
      if (index == _compete) ref.invalidate(leaderboardProvider);
    }
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // tur gedərkən alt menyu gizlənir (yan menyunun alt düymələrini örtməsin),
    // yalnız alt menyunun öz addımlarında görünür
    final step = ref.watch(tourControllerProvider);
    final showNav = step == null || step.onBottomNav;
    return ReminderSync(
      child: WhatsNewCheck(
        child: TourScope(
          targets: _tour,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Scaffold(
                body: IndexedStack(
                  index: _index,
                  children: [
                    const HomeScreen(),
                    _opened.contains(_progress)
                        ? const StatsTab()
                        : const SizedBox.shrink(),
                    _opened.contains(_compete)
                        ? const LeaderboardTab()
                        : const SizedBox.shrink(),
                  ],
                ),
                // panel üzür: arxasında ekranın fonu bulanıq görünür
                extendBody: true,
                bottomNavigationBar: !showNav
                    ? null
                    : GlassNavBar(
                        selectedIndex: _index,
                        onSelected: _select,
                        items: [
                          GlassNavItem(
                            icon: Icons.home_outlined,
                            selectedIcon: Icons.home_rounded,
                            label: AppStrings.navHome,
                          ),
                          GlassNavItem(
                            key: _tour.progress,
                            icon: Icons.insights_outlined,
                            selectedIcon: Icons.insights_rounded,
                            label: AppStrings.navProgress,
                          ),
                          GlassNavItem(
                            key: _tour.compete,
                            icon: Icons.emoji_events_outlined,
                            selectedIcon: Icons.emoji_events_rounded,
                            label: AppStrings.navCompete,
                          ),
                        ],
                      ),
              ),
              // yan menyunun və alt menyunun da üstündə qalsın
              const TourOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
