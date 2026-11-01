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

Widget app(FakeQuizRepository repo, {QuestionImageRepository? images, bool imagesEnabled = true}) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        imagesEnabledProvider.overrideWithValue(imagesEnabled),
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
    for (final letter in ['A', 'B', 'C', 'D', 'E']) {
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

    await tester.tap(find.text('C'));
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

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.correct), findsOneWidget);
    await tester.tap(find.text(AppStrings.nextQuestion));
    await tester.pumpAndSettle();

    await tester.tap(find.text('E'));
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

  testWidgets('multi-choice field keeps only digits and shows the answer as 1,3,5', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([multiChoiceQuestion(correct: '135')])));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '1.2,4');
    await tester.pump();
    expect(find.text('124'), findsOneWidget);

    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.wrong('1,3,5')), findsOneWidget);
  });

  testWidgets('matching question: letters are picked per row and sent as E;A;BC', (tester) async {
    final repo = FakeQuizRepository([matchingQuestion(correct: 'E;A;BC')]);
    await tester.pumpWidget(app(repo));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text(AppStrings.check), findsOneWidget);
    Future<void> pick(String letter, int row) async {
      await tester.tap(find.text(letter).at(row));
      await tester.pump();
    }

    await pick('e', 0);
    await pick('a', 1);
    await pick('c', 2);
    await pick('b', 2);
    await pick('d', 2);
    await pick('d', 2); // ikinci toxunuş seçimi götürür
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();

    expect(repo.submitted.single.given, 'E;A;BC');
    expect(find.text(AppStrings.correct), findsOneWidget);
  });

  testWidgets('image that fails to load shows "Şəkil yüklənmədi" but the question stays solvable', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([closedQuestion(imagePath: 'KIM-0001.png', correct: 'B')])));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.imageFailed), findsOneWidget);

    await tester.tap(find.text('B'));
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

  testWidgets('explanation image replaces the text; without an image the text is shown', (tester) async {
    await tester.pumpWidget(app(FakeQuizRepository([
      closedQuestion(id: 'a', correct: 'A', solution: 'Dağınıq mətn', solutionImagePath: 'KIM-0001_izah.png'),
      closedQuestion(id: 'b', correct: 'A', solution: 'Təmiz mətn'),
    ])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    expect(find.text('Dağınıq mətn'), findsNothing, reason: 'the image is the explanation');
    expect(find.text(AppStrings.imageFailed), findsOneWidget, reason: 'the fake repository fails to sign the link');

    await tester.tap(find.text(AppStrings.nextQuestion));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();
    expect(find.text('Təmiz mətn'), findsOneWidget);
  });

  testWidgets('images switched off: no image is requested or shown, the text explanation appears', (tester) async {
    final images = FakeImageRepository(fail: false);
    await tester.pumpWidget(app(
      FakeQuizRepository([
        closedQuestion(correct: 'A', imagePath: 'KIM-0001.png', solution: 'Mətn izahı', solutionImagePath: 'KIM-0001_izah.png'),
      ]),
      images: images,
      imagesEnabled: false,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.check));
    await tester.pumpAndSettle();

    expect(find.text('Mətn izahı'), findsOneWidget);
    expect(find.text(AppStrings.imageFailed), findsNothing);
    expect(images.calls, 0, reason: 'Storage must not be called when images are off');
  });
}
