import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/utils/validators.dart';
import 'package:prep_az/features/goal/domain/exam_goal.dart';
import 'package:prep_az/features/goal/presentation/goal_providers.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/leaderboard/domain/leaderboard.dart';
import 'package:prep_az/features/leaderboard/domain/leaderboard_repository.dart';
import 'package:prep_az/features/leaderboard/presentation/leaderboard_providers.dart';
import 'package:prep_az/features/leaderboard/presentation/leaderboard_tab.dart';
import 'package:prep_az/features/shell/presentation/main_shell.dart';

import '../support/fakes.dart';
import 'goal_test.dart';
import 'home_screen_test.dart';

class FakeLeaderboardRepository implements LeaderboardRepository {
  FakeLeaderboardRepository({this.player, this.boards = const {}});

  Player? player;
  final Map<int, List<LeaderboardEntry>> boards;
  final Set<String> takenNicknames = {'taken'};
  final requests = <int>[];

  @override
  Future<Player?> getMyPlayer() async => player;

  @override
  Future<void> savePlayer(Player p) async {
    if (takenNicknames.contains(p.nickname.toLowerCase())) {
      throw NicknameTakenException(AppStrings.nicknameTaken);
    }
    player = p;
  }

  @override
  Future<Leaderboard> getLeaderboard(int subjectId) async {
    requests.add(subjectId);
    return Leaderboard(boards[subjectId] ?? const []);
  }
}

const _kimya = Subject(id: 1, slug: 'kimya', name: 'Kimya');
const _bio = Subject(id: 2, slug: 'biologiya', name: 'Biologiya');
const _me = Player(nickname: 'Ali_07', firstName: 'Əli', lastName: 'Məmmədov');

LeaderboardEntry _e(int rank, String nick, int score, {bool me = false}) =>
    LeaderboardEntry(rank: rank, nickname: nick, score: score, isMe: me);

Widget _app(FakeLeaderboardRepository repo, {Widget home = const LeaderboardTab()}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      leaderboardRepositoryProvider.overrideWithValue(repo),
      subjectRepositoryProvider.overrideWithValue(FakeSubjects(() async => [_kimya, _bio])),
      profileRepositoryProvider.overrideWithValue(FakeProfile(2)),
      progressRepositoryProvider.overrideWithValue(FakeProgressRepository(const [])),
      goalRepositoryProvider.overrideWithValue(
        FakeGoalRepository(goal: const UserGoal(periodId: 1)),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

Future<void> _pump(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

void main() {
  group('validators', () {
    test('nickname', () {
      expect(Validators.nickname('Ali_07'), isNull);
      expect(Validators.nickname('Vüsal.Ş'), isNull);
      expect(Validators.nickname('ab'), isNotNull);
      expect(Validators.nickname('a' * 21), isNotNull);
      expect(Validators.nickname('has space'), isNotNull);
      expect(Validators.nickname('bad!'), isNotNull);
    });

    test('person name', () {
      expect(Validators.personName('Əli'), isNull);
      expect(Validators.personName(' A '), isNotNull);
      expect(Validators.personName('a' * 41), isNotNull);
    });
  });

  testWidgets('without a nickname the join form is shown, then the board', (tester) async {
    final repo = FakeLeaderboardRepository();
    await _pump(tester, _app(repo));

    expect(find.text(AppStrings.joinTitle), findsOneWidget);
    await tester.tap(find.text(AppStrings.joinAction));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.nicknameInvalid), findsOneWidget);
    expect(repo.player, isNull);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'taken');
    await tester.enterText(fields.at(1), 'Əli');
    await tester.enterText(fields.at(2), 'Məmmədov');
    await tester.tap(find.text(AppStrings.joinAction));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.nicknameTaken), findsOneWidget);
    expect(repo.player, isNull);

    await tester.enterText(fields.at(0), 'Ali_07');
    await tester.tap(find.text(AppStrings.joinAction));
    await tester.pumpAndSettle();
    expect(repo.player?.nickname, 'Ali_07');
    expect(find.text(AppStrings.joinTitle), findsNothing);
    expect(find.text('@Ali_07'), findsOneWidget);
    expect(find.text(AppStrings.leaderboardEmpty), findsOneWidget);
    expect(find.text(AppStrings.myRankNone), findsOneWidget);
  });

  testWidgets('board shows podium, the rest and my rank outside the top', (tester) async {
    final repo = FakeLeaderboardRepository(
      player: _me,
      boards: {
        1: [
          _e(1, 'nigar', 40),
          _e(2, 'vusal', 31),
          _e(3, 'kamran', 20),
          _e(4, 'leyla', 12),
          _e(57, 'Ali_07', 3, me: true),
        ],
        2: [_e(1, 'aysel', 9)],
      },
    );
    await _pump(tester, _app(repo));

    for (final nick in ['nigar', 'vusal', 'kamran', 'leyla']) {
      expect(find.text(nick), findsOneWidget);
    }
    // cədvəldən kənar olan öz sətri siyahıda yox, yalnız aşağıdakı zolaqdadır
    expect(find.text('Ali_07 (${AppStrings.youLabel})'), findsNothing);
    expect(find.text(AppStrings.myRank(57, 3)), findsOneWidget);
    expect(find.text(AppStrings.leaderboardAllHint), findsOneWidget);

    // fənn açılan siyahıdan seçilir
    await tester.tap(find.text('Kimya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biologiya').last);
    await tester.pumpAndSettle();
    expect(repo.requests.last, 2);
    expect(find.text('aysel'), findsOneWidget);
    expect(find.text(AppStrings.myRankNone), findsOneWidget);
  });

  testWidgets('player can change their details', (tester) async {
    final repo = FakeLeaderboardRepository(player: _me);
    await _pump(tester, _app(repo));

    await tester.tap(find.text('@Ali_07'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.editPlayerTitle), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Ali_99');
    await tester.tap(find.text(AppStrings.saveAction));
    await tester.pumpAndSettle();

    expect(repo.player?.nickname, 'Ali_99');
    expect(find.text('@Ali_99'), findsOneWidget);
  });

  testWidgets('bottom menu switches between home and the leaderboard', (tester) async {
    final repo = FakeLeaderboardRepository(player: _me);
    await _pump(tester, _app(repo, home: const MainShell()));

    expect(find.text(AppStrings.homeTitle), findsOneWidget);
    // "Yarış" basılana qədər cədvəl sorğusu getmir
    expect(repo.requests, isEmpty);

    await tester.tap(find.text(AppStrings.navCompete));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.competeTitle), findsWidgets);
    expect(repo.requests, isNotEmpty);

    await tester.tap(find.text(AppStrings.navHome));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.homeTitle), findsOneWidget);
  });
}
