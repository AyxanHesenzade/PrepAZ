import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/browse/data/in_memory_topic_draft_repository.dart';
import 'package:prep_az/features/browse/domain/topic_draft.dart';
import 'package:prep_az/features/browse/presentation/browse_providers.dart';
import 'package:prep_az/features/browse/presentation/topic_list_screen.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/topic_mastery.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/quiz/domain/question.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';

import '../support/fakes.dart';

Widget _app(
  FakeBrowseRepository repo, {
  FakeQuizRepository? quiz,
  InMemoryTopicDraftRepository? drafts,
  List<TopicMastery> progress = const [],
}) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        imagesEnabledProvider.overrideWithValue(true),
        browseRepositoryProvider.overrideWithValue(repo),
        quizRepositoryProvider.overrideWithValue(quiz ?? FakeQuizRepository(repo.questions)),
        topicDraftRepositoryProvider.overrideWithValue(drafts ?? InMemoryTopicDraftRepository()),
        progressRepositoryProvider.overrideWithValue(FakeProgressRepository(progress)),
        questionImageRepositoryProvider.overrideWithValue(FakeImageRepository()),
      ],
      child: const MaterialApp(home: TopicListScreen(subject: Subject(id: 1, slug: 'kimya', name: 'Kimya'))),
    );

final _three = [
  imageOnlyQuestion(id: 'Q001', correct: 'B'),
  imageOnlyQuestion(id: 'Q002', correct: 'C'),
  imageOnlyQuestion(id: 'Q003', correct: 'D'),
];

Future<void> _open(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Əsas anlayışlar'));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('right or wrong stays hidden until finish, then every test is marked', (tester) async {
    // nəticə siyahısı tənbəl qurulur: hər kart görünsün deyə ekran böyükdür
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final quiz = FakeQuizRepository(_three);
    await tester.pumpWidget(_app(FakeBrowseRepository(_three), quiz: quiz));
    await _open(tester);

    expect(find.text(AppStrings.questionOf(1, 3)), findsOneWidget);
    await _tap(tester, 'B');
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(quiz.submitted, isEmpty, reason: 'nothing is sent before finish');

    await _tap(tester, AppStrings.nextQuestion);
    await _tap(tester, 'A');
    await _tap(tester, AppStrings.nextQuestion);
    await _tap(tester, 'D');

    await tester.tap(find.widgetWithText(FilledButton, AppStrings.finishAction));
    await tester.pumpAndSettle();

    expect(quiz.submitted.map((a) => a.questionId), ['Q001', 'Q002', 'Q003']);
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text(AppStrings.topicProgressChange(0, 2, 3)), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.text(AppStrings.continueSolving), findsNothing);
  });

  testWidgets('after the last test the skipped ones come back', (tester) async {
    await tester.pumpWidget(_app(FakeBrowseRepository(_three)));
    await _open(tester);

    await _tap(tester, AppStrings.nextQuestion);
    await _tap(tester, 'C');
    await _tap(tester, AppStrings.nextQuestion);
    await _tap(tester, 'D');
    await _tap(tester, AppStrings.nextQuestion);

    expect(find.text(AppStrings.questionOf(1, 3)), findsOneWidget);
  });

  testWidgets('finishing early leaves the rest unsolved, not wrong', (tester) async {
    final quiz = FakeQuizRepository(_three);
    final repo = FakeBrowseRepository(_three);
    await tester.pumpWidget(_app(repo, quiz: quiz));
    await _open(tester);

    await _tap(tester, 'B');
    await _tap(tester, AppStrings.finishAction);
    expect(find.text(AppStrings.finishConfirm(2)), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, AppStrings.finishAction).last);
    await tester.pumpAndSettle();

    expect(quiz.submitted, hasLength(1));
    expect(find.text('1 / 1'), findsOneWidget);

    repo.latest = {'Q001': true};
    await tester.dragUntilVisible(
      find.text(AppStrings.continueSolving),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await _tap(tester, AppStrings.continueSolving);
    expect(find.text(AppStrings.questionOf(2, 3)), findsOneWidget);
  });

  testWidgets('leaving keeps the answers and the test carries on where it stopped', (tester) async {
    final drafts = InMemoryTopicDraftRepository();
    await tester.pumpWidget(_app(FakeBrowseRepository(_three), drafts: drafts));
    await _open(tester);
    await _tap(tester, 'B');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(drafts.load(1).answers, {'Q001': 'B'});

    await _tap(tester, 'Əsas anlayışlar');
    expect(find.text(AppStrings.questionOf(2, 3)), findsOneWidget);
    await _tap(tester, AppStrings.previousQuestion);
    expect(find.text(AppStrings.finishAction), findsOneWidget);
  });

  testWidgets('solved tests are skipped', (tester) async {
    await tester.pumpWidget(_app(FakeBrowseRepository(_three, latest: {'Q001': false})));
    await _open(tester);
    expect(find.text(AppStrings.questionOf(2, 3)), findsOneWidget);
  });

  testWidgets('a failed send loses nothing and the retry finishes', (tester) async {
    final quiz = FakeQuizRepository(_three)..failSubmit = true;
    final drafts = InMemoryTopicDraftRepository();
    await tester.pumpWidget(_app(FakeBrowseRepository(_three), quiz: quiz, drafts: drafts));
    await _open(tester);
    await _tap(tester, 'B');
    await _tap(tester, AppStrings.finishAction);
    await tester.tap(find.widgetWithText(TextButton, AppStrings.finishAction).last);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.answersNotSent), findsOneWidget);
    expect(drafts.load(1).answers, {'Q001': 'B'});

    quiz.failSubmit = false;
    await _tap(tester, AppStrings.finishAction);
    await tester.tap(find.widgetWithText(TextButton, AppStrings.finishAction).last);
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(drafts.load(1).answers, isEmpty);
  });

  testWidgets('a finished topic says so and can be started again', (tester) async {
    final repo = FakeBrowseRepository(_three, latest: {'Q001': true, 'Q002': true, 'Q003': false});
    final drafts = InMemoryTopicDraftRepository();
    await tester.pumpWidget(_app(repo, drafts: drafts));
    await _open(tester);

    expect(find.text(AppStrings.topicDone), findsOneWidget);
    expect(find.text(AppStrings.topicCorrectOf(2, 3)), findsOneWidget);
    await _tap(tester, AppStrings.restartTopic);
    expect(find.text(AppStrings.questionOf(1, 3)), findsOneWidget);
    expect(drafts.load(1).retake, isTrue);
  });

  testWidgets('a draft for a question that is gone is ignored', (tester) async {
    final drafts = InMemoryTopicDraftRepository();
    await drafts.save(1, const TopicDraft(answers: {'old': 'A'}));
    await tester.pumpWidget(_app(FakeBrowseRepository(_three), drafts: drafts));
    await _open(tester);
    expect(find.text(AppStrings.questionOf(1, 3)), findsOneWidget);
    expect(find.text(AppStrings.finishAction), findsNothing);
  });

  testWidgets('the list shows how far each topic is', (tester) async {
    await tester.pumpWidget(_app(
      FakeBrowseRepository(_three),
      progress: const [TopicMastery(topicId: 1, topicName: 'x', total: 3, answered: 2, correct: 1)],
    ));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.topicSolved(2, 3)), findsOneWidget);
  });

  testWidgets('a written question takes typed text and keeps it', (tester) async {
    final typed = [
      Question(id: 'T1', code: 'T1', topicId: 1, type: QuestionType.aciqEded, body: 'Neçə?', imagePath: null, options: const {}, correctAnswer: '5', difficulty: 2, solution: null),
      imageOnlyQuestion(id: 'Q002', correct: 'C'),
    ];
    await tester.pumpWidget(_app(FakeBrowseRepository(typed)));
    await _open(tester);
    await tester.enterText(find.byType(TextField), '5');
    await _tap(tester, AppStrings.nextQuestion);
    await _tap(tester, AppStrings.previousQuestion);
    expect(find.text('5'), findsOneWidget);
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
