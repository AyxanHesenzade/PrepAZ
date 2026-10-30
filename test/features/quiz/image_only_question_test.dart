import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';
import 'package:prep_az/features/quiz/presentation/quiz_screen.dart';

import '../../support/fakes.dart';

Widget _app(FakeQuizRepository repo) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        imagesEnabledProvider.overrideWithValue(true),
        quizRepositoryProvider.overrideWithValue(repo),
        questionImageRepositoryProvider.overrideWithValue(FakeImageRepository()),
      ],
      child: const MaterialApp(home: QuizScreen(subject: Subject(id: 1, slug: 'kimya', name: 'Kimya'))),
    );

void main() {
  test('a question with an image and no text is image-only', () {
    expect(imageOnlyQuestion().isImageOnly, isTrue);
    expect(closedQuestion(imagePath: 'x.png').isImageOnly, isFalse);
    expect(closedQuestion().isImageOnly, isFalse);
  });

  testWidgets('shows the image frame and only the letters A–E (no option texts)', (tester) async {
    await tester.pumpWidget(_app(FakeQuizRepository([imageOnlyQuestion()])));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.imageFailed), findsOneWidget); // the fake repository cannot load, but the image slot is there
    for (final letter in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text(letter), findsOneWidget);
    }
    expect(find.text('A)'), findsNothing); // the normal option tile is not used
  });

  testWidgets('pick a letter, check, the server verdict is shown', (tester) async {
    final repo = FakeQuizRepository([imageOnlyQuestion(correct: 'B')]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('C'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();

    expect(repo.submitted.single.given, 'C');
    expect(find.text(AppStrings.wrong('B')), findsOneWidget);
  });

  testWidgets('the correct letter ends in the success message', (tester) async {
    await tester.pumpWidget(_app(FakeQuizRepository([imageOnlyQuestion(correct: 'D')])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('D'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.correct), findsOneWidget);
  });
}
