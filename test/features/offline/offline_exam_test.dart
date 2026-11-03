import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/browse/data/in_memory_topic_draft_repository.dart';
import 'package:prep_az/features/browse/presentation/browse_providers.dart';
import 'package:prep_az/features/browse/presentation/topic_exam_controller.dart';
import 'package:prep_az/features/browse/presentation/topic_exam_state.dart';
import 'package:prep_az/features/browse/presentation/widgets/topic_result_view.dart';
import 'package:prep_az/features/offline/data/drift_answer_outbox.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/data/offline_browse_repository.dart';
import 'package:prep_az/features/offline/domain/answer_syncer.dart';
import 'package:prep_az/features/offline/presentation/offline_providers.dart';
import 'package:prep_az/features/quiz/domain/answer_result.dart';
import 'package:prep_az/features/quiz/domain/question.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';

import '../../support/fakes.dart';
import 'fakes.dart';

const _key = (subjectId: 5, topicId: 1);

/// Şəkilsiz qapalı sual: düz cavab `correct`.
Question closed(String id, String correct) => Question(
  id: id,
  code: 'C-$id',
  topicId: 1,
  type: QuestionType.qapali,
  body: 'Sual $id',
  imagePath: null,
  options: const {'A': 'a', 'B': 'b', 'C': 'c'},
  correctAnswer: correct,
  difficulty: 1,
  solution: null,
);

void main() {
  late LocalDatabase db;
  late DriftOfflineStore store;
  late DriftAnswerOutbox outbox;
  late FakeQuizRepository quiz;
  late List<Question> questions;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    store = DriftOfflineStore(db);
    outbox = DriftAnswerOutbox(db);
    questions = [closed('q1', 'B'), closed('q2', 'C'), closed('q3', 'A')];
    quiz = FakeQuizRepository(questions);
  });
  tearDown(() => db.close());

  Future<void> download() => store.saveTopic(subjectId: 5, topic: catalog(1), questions: questions);

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        browseRepositoryProvider.overrideWithValue(
          OfflineBrowseRepository(remote: FakeBrowseRepository(questions), store: store, outbox: outbox),
        ),
        quizRepositoryProvider.overrideWithValue(quiz),
        topicDraftRepositoryProvider.overrideWithValue(InMemoryTopicDraftRepository()),
      ],
    );
    addTearDown(c.dispose);
    // autoDispose controller sınaq boyu yaşasın
    c.listen(topicExamControllerProvider(_key), (_, _) {});
    return c;
  }

  Future<TopicExamController> open(ProviderContainer c) async {
    await c.read(topicExamControllerProvider(_key).future);
    return c.read(topicExamControllerProvider(_key).notifier);
  }

  TopicExamState state(ProviderContainer c) => c.read(topicExamControllerProvider(_key)).requireValue;

  test('online: answers carry a client id, nothing is queued', () async {
    await download();
    final c = container();
    final exam = await open(c);
    exam.answer('B');
    exam.go(1);
    exam.answer('A');

    await exam.finish();

    expect(state(c).finished, isTrue);
    expect(state(c).savedOffline, isFalse);
    expect(quiz.submitted.map((a) => a.questionId), ['q1', 'q2']);
    expect(quiz.submitted.every((a) => a.clientId != null && a.clientId!.isNotEmpty), isTrue);
    expect(quiz.submitted.map((a) => a.clientId).toSet(), hasLength(2));
    expect(await outbox.all(), isEmpty);
  });

  test('no internet on a DOWNLOADED topic: the result is computed on the phone and the answers are queued', () async {
    await download();
    quiz.failSubmit = true;
    final c = container();
    final exam = await open(c);
    exam.answer('B'); // düz
    exam.go(1);
    exam.answer('A'); // səhv (düz C)

    await exam.finish();

    final s = state(c);
    expect(s.finished, isTrue);
    expect(s.savedOffline, isTrue);
    expect(s.error, isNull);
    expect(s.results['q1']!.isCorrect, isTrue);
    expect(s.results['q2']!.isCorrect, isFalse);
    expect(s.results.containsKey('q3'), isFalse, reason: 'unanswered stays unsolved, not wrong');
    final queued = await outbox.all();
    expect(queued.map((e) => (e.questionId, e.given, e.isCorrect)), [('q1', 'B', true), ('q2', 'A', false)]);
    expect(queued.map((e) => e.clientId).toSet(), hasLength(2));
    expect(queued.every((e) => e.topicId == 1 && e.subjectId == 5), isTrue);
  });

  test('no internet on a topic that was NOT downloaded: the old behaviour (error, answers stay in the draft)', () async {
    quiz.failSubmit = true;
    final c = container();
    final exam = await open(c);
    exam.answer('B');

    await exam.finish();

    final s = state(c);
    expect(s.finished, isFalse);
    expect(s.error, isNotNull);
    expect(s.savedOffline, isFalse);
    expect(await outbox.all(), isEmpty);
  });

  test('reopening the topic offline does not offer the tests that were just answered', () async {
    await download();
    quiz.failSubmit = true;
    final first = container();
    final exam = await open(first);
    exam.answer('B');
    exam.go(1);
    exam.answer('A');
    await exam.finish();

    final again = container();
    await open(again);

    expect(state(again).questions.map((q) => q.id), ['q3']);
    expect(state(again).latest, {'q1': true, 'q2': false});
  });

  test('when the internet returns the queued answers are sent once, without a session, with the same client ids', () async {
    await download();
    quiz.failSubmit = true;
    final c = container();
    final exam = await open(c);
    exam.answer('B');
    exam.go(1);
    exam.answer('A');
    await exam.finish();
    final queuedIds = (await outbox.all()).map((e) => e.clientId).toList();

    quiz.failSubmit = false;
    quiz.submitted.clear();
    final sent = await AnswerSyncer(outbox: outbox, quiz: quiz, store: store).flush();

    expect(sent, 2);
    expect(quiz.submitted.map((a) => a.clientId), queuedIds);
    expect(await outbox.all(), isEmpty);
    expect(await store.cachedLatest(1), {'q1': true, 'q2': false});
  });

  testWidgets('the result screen tells the student the answers are saved and will be sent', (tester) async {
    final shown = TopicExamState(
      all: questions,
      questions: questions,
      latest: const {},
      results: {'q1': AnswerResult(question: questions.first, given: 'B', isCorrect: true)},
      finished: true,
      savedOffline: true,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TopicResultView(state: shown))));

    expect(find.text(AppStrings.resultSavedOffline), findsOneWidget);
  });

  testWidgets('no such notice after a normal online finish', (tester) async {
    final shown = TopicExamState(
      all: questions,
      questions: questions,
      latest: const {},
      results: {'q1': AnswerResult(question: questions.first, given: 'B', isCorrect: true)},
      finished: true,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TopicResultView(state: shown))));

    expect(find.text(AppStrings.resultSavedOffline), findsNothing);
  });
}
