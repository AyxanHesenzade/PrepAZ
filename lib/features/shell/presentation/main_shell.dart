import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glass_nav_bar.dart';
import '../../home/presentation/home_screen.dart';
import '../../leaderboard/presentation/leaderboard_providers.dart';
import '../../leaderboard/presentation/leaderboard_tab.dart';
import '../../reminders/presentation/reminder_sync.dart';
import '../../tour/presentation/tour_controller.dart';

/// Daxil olandan sonrakı əsas ekran: aşağıda menyu (Ana səhifə, Yarış).
/// Tablar `IndexedStack`-dədir: keçəndə ana səhifənin vəziyyəti itmir.
/// "Yarış" ilk dəfə basılana qədər qurulmur (lazımsız sorğu getməsin).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;
  final _opened = <int>{0};

  void _select(int index) {
    if (index == 1 && _opened.contains(1)) {
      // geri qayıdanda cədvəl təzə olsun (ana səhifədə test həll edilmiş ola bilər)
      ref.invalidate(leaderboardProvider);
    }
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // öyrədici tur ana səhifədədir: tur gedərkən alt menyu gizlənir
    final touring = ref.watch(tourControllerProvider) != null;
    return ReminderSync(
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const HomeScreen(),
            _opened.contains(1)
                ? const LeaderboardTab()
                : const SizedBox.shrink(),
          ],
        ),
        // panel üzür: arxasında ekranın fonu bulanıq görünür
        extendBody: true,
        bottomNavigationBar: touring
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
                    icon: Icons.emoji_events_outlined,
                    selectedIcon: Icons.emoji_events_rounded,
                    label: AppStrings.navCompete,
                  ),
                ],
              ),
      ),
    );
  }
}
