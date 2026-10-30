import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/browse/presentation/browse_providers.dart';
import 'package:prep_az/features/browse/presentation/topic_list_screen.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';

import '../support/fakes.dart';

Widget _app(FakeBrowseRepository repo) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        imagesEnabledProvider.overrideWithValue(true),
        browseRepositoryProvider.overrideWithValue(repo),
        questionImageRepositoryProvider.overrideWithValue(FakeImageRepository()),
      ],
      child: const MaterialApp(home: TopicListScreen(subject: Subject(id: 1, slug: 'kimya', name: 'Kimya'))),
    );

void main() {
  testWidgets('topic list -> questions in order, answer is shown but nothing is saved, can jump', (tester) async {
    final repo = FakeBrowseRepository([
      imageOnlyQuestion(id: 'Q001', correct: 'B'),
      imageOnlyQuestion(id: 'Q002', correct: 'C'),
      imageOnlyQuestion(id: 'Q003', correct: 'D'),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Əsas anlayışlar'), findsOneWidget);
    expect(find.text(AppStrings.questionCount(3)), findsOneWidget);
    await tester.tap(find.text('Əsas anlayışlar'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.questionOf(1, 3)), findsOneWidget);
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.wrong('B')), findsOneWidget);

    await tester.tap(find.text(AppStrings.nextQuestion));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.questionOf(2, 3)), findsOneWidget);
    expect(find.text(AppStrings.wrong('C')), findsNothing); // new question starts unanswered

    await tester.tap(find.text(AppStrings.jumpToQuestion));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.questionOf(3, 3)), findsOneWidget);

    await tester.tap(find.text(AppStrings.previousQuestion));
    await tester.tap(find.text(AppStrings.previousQuestion));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.wrong('B')), findsOneWidget); // question 1 remembers the pick while the screen is open
  });

  testWidgets('search filters topics, ignores case and Azerbaijani letters', (tester) async {
    await tester.pumpWidget(_app(FakeBrowseRepository([imageOnlyQuestion()])));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ESAS anlayis');
    await tester.pump();
    expect(find.text('Əsas anlayışlar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'fizika');
    await tester.pump();
    expect(find.text('Əsas anlayışlar'), findsNothing);
    expect(find.text(AppStrings.noTopicsFound), findsOneWidget);
  });
}
