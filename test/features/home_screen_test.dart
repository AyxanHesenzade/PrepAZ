import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/home/domain/profile_repository.dart';
import 'package:prep_az/features/home/domain/topic_mastery.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/subject_repository.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/home/presentation/home_screen.dart';

import '../support/fakes.dart';
import 'goal_test.dart';

import 'package:prep_az/features/goal/domain/exam_goal.dart';
import 'package:prep_az/features/goal/presentation/goal_providers.dart';

class FakeSubjects implements SubjectRepository {
  FakeSubjects(this.result);
  final Future<List<Subject>> Function() result;

  @override
  Future<List<Subject>> getSubjects() => result();
}

class FakeProfile implements ProfileRepository {
  FakeProfile(this.days);
  final int days;

  @override
  Future<int> getStreakDays() async => days;
}

Widget buildHome({
  required SubjectRepository subjects,
  required ProfileRepository profile,
  List<TopicMastery> mastery = const [],
}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      subjectRepositoryProvider.overrideWithValue(subjects),
      profileRepositoryProvider.overrideWithValue(profile),
      progressRepositoryProvider.overrideWithValue(
        FakeProgressRepository(mastery),
      ),
      // hədəf artıq seçilib: ilk açılış ekranı testləri yayındırmasın
      goalRepositoryProvider.overrideWithValue(
        FakeGoalRepository(goal: const UserGoal(periodId: 1)),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  const subjects = [
    Subject(id: 1, slug: 'math', name: 'Riyaziyyat'),
    Subject(id: 2, slug: 'az', name: 'Azərbaycan dili'),
    Subject(id: 3, slug: 'eng', name: 'İngilis dili'),
  ];

  testWidgets('shows streak and all subjects', (tester) async {
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async => subjects),
        profile: FakeProfile(3),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.streak(3)), findsOneWidget);
    for (final s in subjects) {
      expect(find.text(s.name), findsOneWidget);
    }
  });

  testWidgets('shows the empty-streak message when streak is 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async => subjects),
        profile: FakeProfile(0),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.streakEmpty), findsOneWidget);
  });

  testWidgets('error shows retry and recovers after it', (tester) async {
    var fail = true;
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async {
          if (fail) throw AppException(AppStrings.unknownError);
          return subjects;
        }),
        profile: FakeProfile(1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.retry), findsOneWidget);

    fail = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text('Riyaziyyat'), findsOneWidget);
    expect(find.text(AppStrings.retry), findsNothing);
  });

  testWidgets(
    'each subject card has a start button and splits weak and strong topics',
    (tester) async {
      await tester.pumpWidget(
        buildHome(
          subjects: FakeSubjects(() async => subjects.sublist(0, 1)),
          profile: FakeProfile(0),
          mastery: const [
            TopicMastery(topicId: 1, topicName: 'Hidroliz', total: 10, answered: 5, correct: 1),
            TopicMastery(topicId: 2, topicName: 'Metallar', total: 10, answered: 2, correct: 2),
            TopicMastery(topicId: 3, topicName: 'Spirtlər', total: 10, answered: 8, correct: 7),
            TopicMastery(topicId: 4, topicName: 'Alkanlar', total: 10, answered: 10, correct: 9),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.startQuiz), findsOneWidget);
      expect(find.text('Hidroliz'), findsOneWidget);
      expect(find.text('10% · 1/10'), findsOneWidget);
      expect(find.text(AppStrings.weakTopics), findsOneWidget);
      expect(find.text(AppStrings.strongTopics), findsOneWidget);
      expect(find.text('Alkanlar'), findsOneWidget);
      expect(find.text('Metallar'), findsNothing, reason: 'still in progress');
    },
  );

  testWidgets('five right out of a hundred is neither strong nor weak', (tester) async {
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async => subjects.sublist(0, 1)),
        profile: FakeProfile(0),
        mastery: const [
          TopicMastery(topicId: 1, topicName: 'Hidroliz', total: 100, answered: 5, correct: 5),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hidroliz'), findsNothing);
    expect(find.text(AppStrings.weakTopics), findsNothing);
    expect(find.text(AppStrings.strongTopics), findsNothing);
    expect(find.text(AppStrings.needMoreAnswers), findsOneWidget);
  });

  testWidgets('high scores are never called weak', (tester) async {
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async => subjects.sublist(0, 1)),
        profile: FakeProfile(0),
        mastery: const [
          TopicMastery(topicId: 1, topicName: 'Məhlullar', total: 10, answered: 10, correct: 10),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.weakTopics), findsNothing);
    expect(find.text(AppStrings.strongTopics), findsOneWidget);
    expect(find.text('Məhlullar'), findsOneWidget);
  });

  group('TopicMastery', () {
    TopicMastery topic(int total, int answered, int correct) =>
        TopicMastery(topicId: 1, topicName: 'x', total: total, answered: answered, correct: correct);

    test('the percent is measured against every test in the topic', () {
      expect(topic(100, 5, 5).masteryPct, 5);
      expect(topic(100, 5, 5).isStrong, isFalse);
      expect(topic(100, 5, 5).isWeak, isFalse);
    });

    test('strong means most of the whole topic is right', () {
      expect(topic(100, 70, 70).isStrong, isTrue);
      expect(topic(100, 69, 69).isStrong, isFalse);
      expect(topic(3, 3, 3).isStrong, isTrue);
    });

    test('weak needs enough solved tests with a low share right', () {
      expect(topic(100, 5, 3).isWeak, isTrue);
      expect(topic(100, 4, 0).isWeak, isFalse);
      expect(topic(100, 5, 4).isWeak, isFalse);
      expect(topic(3, 3, 0).isWeak, isTrue, reason: 'a small topic can be finished under the minimum');
    });
  });

  testWidgets('no answers yet: hint instead of topics', (tester) async {
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async => subjects.sublist(0, 1)),
        profile: FakeProfile(0),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noMasteryYet), findsOneWidget);
  });
}
