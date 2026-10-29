import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/quiz/domain/question_image_repository.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';
import 'package:prep_az/features/quiz/presentation/quiz_screen.dart';

import '../../support/fakes.dart';

const _subject = Subject(id: 4, slug: 'kimya', name: 'Kimya');

/// Link heç vaxt gəlmir: yer tutucunun görünməsini yoxlamaq üçün.
class _HangingImages implements QuestionImageRepository {
  @override
  Future<String> signedUrl(String path) => Completer<String>().future;
}

Widget app(FakeQuizRepository repo, {QuestionImageRepository? images}) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        quizRepositoryProvider.overrideWithValue(repo),
        questionImageRepositoryProvider.overrideWithValue(images ?? FakeImageRepository()),
      ],
      child: const MaterialApp(home: QuizScreen(subject: _subject)),
    );

void main() {
  testWidgets('shows the question, 5 options, progress title and a disabled "Yoxla"', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([closedQuestion(), closedQuestion(id: 'q2')])));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.questionOf(1, 2)), findsOneWidget);
    for (final letter in ['A)', 'B)', 'C)', 'D)', 'E)']) {
      expect(find.text(letter), findsOneWidget);
    }
    final check = tester.widget<FilledButton>(find.widgetWithText(FilledButton, AppStrings.check));
    expect(check.onPressed, isNull);
  });

  testWidgets('empty daily set shows the friendly message', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([])));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noQuestionsLeft), findsOneWidget);
  });

  testWidgets('load error shows retry', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([closedQuestion()])..failLoad = true));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.retry), findsOneWidget);
  });

  testWidgets('wrong answer: correct option is marked, solution and review note appear', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([closedQuestion(correct: 'B', solution: 'Düzgün izah')])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('C)'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.wrong('B')), findsOneWidget);
    expect(find.text('Düzgün izah'), findsOneWidget);
    expect(find.text(AppStrings.savedForReview), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('3-question scenario: right, wrong, "Bilmirəm" then the result screen', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([
      closedQuestion(id: 'a', correct: 'A', body: 'Birinci sual'),
      closedQuestion(id: 'b', correct: 'B', body: 'İkinci sual'),
      closedQuestion(id: 'c', correct: 'C', body: 'Üçüncü sual'),
    ])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A)'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.correct), findsOneWidget);
    await tester.tap(find.text(AppStrings.nextQuestion));
    await tester.pumpAndSettle();

    await tester.tap(find.text('E)'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.nextQuestion));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.dontKnow));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.toResult));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.resultTitle('Kimya')), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text(AppStrings.percentCorrect(33)), findsOneWidget);
    expect(find.text(AppStrings.wrongTitle(2)), findsOneWidget);
    expect(find.text(AppStrings.yourVsRight('E', 'B')), findsOneWidget);
    expect(find.text(AppStrings.yourVsRight('-', 'C')), findsOneWidget);
  });

  testWidgets('numeric question shows a text field and accepts the typed answer', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([numericQuestion(correct: '9,2')])));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '9,2');
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.correct), findsOneWidget);
  });

  testWidgets('image that fails to load shows "Şəkil yüklənmədi" but the question stays solvable', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([closedQuestion(imagePath: 'KIM-0001.png', correct: 'B')])));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.imageFailed), findsOneWidget);

    await tester.tap(find.text('B)'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.correct), findsOneWidget);
  });

  testWidgets('image shows a spinner placeholder while the signed link is loading', (tester) async {
    await tester.pumpWidget(app(
      FakeQuizRepository([closedQuestion(imagePath: 'KIM-0001.png')]),
      images: _HangingImages(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(AppStrings.imageFailed), findsNothing);
  });

  testWidgets('question without image shows no image widget', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([closedQuestion()])));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.imageFailed), findsNothing);
    expect(find.byType(Image), findsNothing);
  });
}
