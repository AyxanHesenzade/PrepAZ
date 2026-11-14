import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/topic_mastery.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/stats/domain/stats_repository.dart';
import 'package:prep_az/features/stats/domain/subject_stats.dart';
import 'package:prep_az/features/stats/presentation/stats_providers.dart';
import 'package:prep_az/features/stats/presentation/stats_tab.dart';
import 'package:prep_az/features/stats/presentation/widgets/week_chart.dart';

import '../../support/fakes.dart';
import '../home_screen_test.dart';

const _kimya = Subject(id: 1, slug: 'kimya', name: 'Kimya');
const _bio = Subject(id: 2, slug: 'biologiya', name: 'Biologiya');

class FakeStats implements StatsRepository {
  FakeStats(this.bySubject);

  final Map<int, SubjectStats> bySubject;
  final requests = <int>[];

  @override
  Future<SubjectStats> getStats(int subjectId, {int days = 14}) async {
    requests.add(subjectId);
    return bySubject[subjectId] ?? SubjectStats.empty;
  }
}

SubjectStats _week() => SubjectStats(
  answered: 40,
  correct: 30,
  questionsTried: 25,
  questionsSolved: 20,
  questionsTotal: 200,
  topicsTotal: 4,
  bestStreak: 6,
  days: [
    for (var i = 0; i < 14; i++)
      DayStat(
        day: DateTime(2026, 11, 1 + i),
        answered: i < 7 ? 1 : 3,
        correct: i < 7 ? 1 : 2,
      ),
  ],
);

void main() {
  late FakeStats stats;

  Widget app({List<TopicMastery> topics = const []}) => ProviderScope(
    retry: (_, _) => null,
    overrides: [
      subjectRepositoryProvider.overrideWithValue(
        FakeSubjects(() async => const [_kimya, _bio]),
      ),
      progressRepositoryProvider.overrideWithValue(
        FakeProgressRepository(topics),
      ),
      statsRepositoryProvider.overrideWithValue(stats),
    ],
    child: const MaterialApp(home: StatsTab()),
  );

  testWidgets('shows totals, the week and the topics', (tester) async {
    stats = FakeStats({1: _week()});
    await tester.pumpWidget(
      app(
        topics: const [
          TopicMastery(
            topicId: 7,
            topicName: 'Valentlik',
            total: 50,
            answered: 10,
            correct: 4,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.statsSolvedOf(20, 200)), findsOneWidget);
    expect(
      find.text('75%'),
      findsOneWidget,
      reason: '30 of 40 answers were right',
    );
    expect(find.text(AppStrings.statsDays(6)), findsOneWidget);
    expect(find.byType(WeekChart), findsOneWidget);
    expect(find.text(AppStrings.statsWeekTotal(21)), findsOneWidget);
    expect(find.text(AppStrings.statsWeekDelta(14)), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Valentlik'), 200);
    expect(find.text('Valentlik'), findsOneWidget);
  });

  testWidgets('a student without answers sees a friendly empty state', (
    tester,
  ) async {
    stats = FakeStats({});
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.statsEmptyTitle), findsOneWidget);
    expect(find.byType(WeekChart), findsNothing);
  });

  testWidgets('switching the subject loads its numbers', (tester) async {
    stats = FakeStats({1: _week()});
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(stats.requests, [1]);

    await tester.tap(find.text('Kimya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Biologiya'));
    await tester.pumpAndSettle();

    expect(stats.requests.last, 2);
    expect(find.text(AppStrings.statsEmptyTitle), findsOneWidget);
  });
}
