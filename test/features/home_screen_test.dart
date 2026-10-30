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
      progressRepositoryProvider.overrideWithValue(FakeProgressRepository(mastery)),
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
    await tester.pumpWidget(buildHome(
      subjects: FakeSubjects(() async => subjects),
      profile: FakeProfile(3),
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.streak(3)), findsOneWidget);
    for (final s in subjects) {
      expect(find.text(s.name), findsOneWidget);
    }
  });

  testWidgets('shows the empty-streak message when streak is 0', (tester) async {
    await tester.pumpWidget(buildHome(
      subjects: FakeSubjects(() async => subjects),
      profile: FakeProfile(0),
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.streakEmpty), findsOneWidget);
  });

  testWidgets('error shows retry and recovers after it', (tester) async {
    var fail = true;
    await tester.pumpWidget(buildHome(
      subjects: FakeSubjects(() async {
        if (fail) throw AppException(AppStrings.unknownError);
        return subjects;
      }),
      profile: FakeProfile(1),
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.retry), findsOneWidget);

    fail = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text('Riyaziyyat'), findsOneWidget);
    expect(find.text(AppStrings.retry), findsNothing);
  });

  testWidgets('each subject card has a start button and shows the weakest topics', (tester) async {
    await tester.pumpWidget(buildHome(
      subjects: FakeSubjects(() async => subjects.sublist(0, 1)),
      profile: FakeProfile(0),
      mastery: const [
        TopicMastery(topicId: 1, topicName: 'Hidroliz', answered: 5, masteryPct: 20),
        TopicMastery(topicId: 2, topicName: 'Metallar', answered: 5, masteryPct: 60),
        TopicMastery(topicId: 3, topicName: 'Spirtlər', answered: 5, masteryPct: 90),
        TopicMastery(topicId: 4, topicName: 'Alkanlar', answered: 5, masteryPct: 95),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.startQuiz), findsOneWidget);
    expect(find.text('Hidroliz'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('Alkanlar'), findsNothing, reason: 'only the 3 weakest topics are shown');
  });

  testWidgets('no answers yet: hint instead of topics', (tester) async {
    await tester.pumpWidget(buildHome(
      subjects: FakeSubjects(() async => subjects.sublist(0, 1)),
      profile: FakeProfile(0),
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noMasteryYet), findsOneWidget);
  });
}
