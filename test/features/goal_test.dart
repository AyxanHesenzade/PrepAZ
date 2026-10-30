import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/goal/data/supabase_goal_repository.dart';
import 'package:prep_az/features/goal/domain/exam_goal.dart';
import 'package:prep_az/features/goal/domain/goal_repository.dart';
import 'package:prep_az/features/goal/presentation/goal_providers.dart';
import 'package:prep_az/features/goal/presentation/goal_screen.dart';
import 'package:prep_az/features/goal/presentation/widgets/goal_card.dart';

class FakeGoalRepository implements GoalRepository {
  FakeGoalRepository({this.goal, this.answered = 0});

  UserGoal? goal;
  final int answered;
  final periods = [
    ExamPeriod(
      id: 1,
      code: 'winter',
      name: 'Qış dövrü',
      examDate: DateTime(2027, 2, 15),
    ),
    ExamPeriod(
      id: 2,
      code: 'summer',
      name: 'Yay dövrü',
      examDate: DateTime(2027, 6, 15),
    ),
  ];

  @override
  Future<List<ExamPeriod>> getPeriods() async => periods;

  @override
  Future<UserGoal?> getGoal() async => goal;

  @override
  Future<void> saveGoal(UserGoal value) async => goal = value;

  @override
  Future<int> countAnswersSince(DateTime from) async => answered;
}

void main() {
  final periods = FakeGoalRepository().periods;

  group('UserGoal.daysLeft', () {
    final today = DateTime(2026, 10, 30, 18, 45);

    test('counts days to the chosen period', () {
      expect(const UserGoal(periodId: 1).daysLeft(periods, today), 108);
    });

    test('own date wins over the period', () {
      final goal = UserGoal(periodId: 1, customDate: DateTime(2026, 11, 2));
      expect(goal.daysLeft(periods, today), 3);
    });

    test('today is 0, past or missing date is null', () {
      expect(
        UserGoal(customDate: DateTime(2026, 10, 30)).daysLeft(periods, today),
        0,
      );
      expect(
        UserGoal(customDate: DateTime(2026, 10, 1)).daysLeft(periods, today),
        isNull,
      );
      expect(const UserGoal().daysLeft(periods, today), isNull);
    });
  });

  test('maps database rows', () {
    final p = periodFromRow({
      'id': 1,
      'code': 'winter',
      'name': 'Qış',
      'exam_date': '2027-02-15',
    });
    expect(p.examDate, DateTime(2027, 2, 15));
    final g = goalFromRow({
      'exam_period_id': null,
      'custom_exam_date': '2027-03-01',
      'daily_goal': 30,
    });
    expect(g.customDate, DateTime(2027, 3, 1));
    expect(g.dailyGoal, 30);
    expect(formatDate(DateTime(2027, 3, 1)), '2027-03-01');
  });

  testWidgets('card shows days left and daily progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalCard(
            daysLeft: 108,
            answeredToday: 5,
            dailyGoal: 20,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.goalDaysLeft(108)), findsOneWidget);
    expect(find.text(AppStrings.goalToday(5, 20)), findsOneWidget);
  });

  testWidgets('goal screen saves the chosen period and daily goal', (
    tester,
  ) async {
    final repo = FakeGoalRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [goalRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: GoalScreen(firstTime: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(AppStrings.periodName('summer', '')));
    await tester.tap(find.text('30'));
    await tester.tap(find.text(AppStrings.goalSave));
    await tester.pumpAndSettle();

    expect(repo.goal?.periodId, 2);
    expect(repo.goal?.dailyGoal, 30);
  });
}
