import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/core/utils/client_id.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/offline/data/drift_answer_outbox.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/domain/answer_outbox.dart';
import 'package:prep_az/features/offline/domain/answer_syncer.dart';
import 'package:prep_az/features/quiz/domain/mistake_item.dart';
import 'package:prep_az/features/quiz/domain/question.dart';
import 'package:prep_az/features/quiz/domain/quiz_repository.dart';

import 'fakes.dart';

/// Yalnız göndərmə: serveri təqlid edir. [online] false olanda hər çağırış xəta verir.
class RecordingQuiz implements QuizRepository {
  bool online = true;

  /// Bu sual id-si üçün server "səhv" cavab verir.
  final wrong = <String>{};
  final calls = <({String questionId, String? sessionId, String? clientId, DateTime? answeredAt})>[];

  @override
  Future<bool> submitAnswer({
    required String questionId,
    required String? sessionId,
    required String? given,
    required int timeMs,
    String? clientId,
    DateTime? answeredAt,
  }) async {
    if (!online) throw const AppException('no internet');
    calls.add((questionId: questionId, sessionId: sessionId, clientId: clientId, answeredAt: answeredAt));
    return !wrong.contains(questionId);
  }

  @override
  Future<List<Question>> getDailySet(int subjectId, {int limit = 20}) => throw UnimplementedError();

  @override
  Future<List<Question>> getTopicSet(int topicId, {int limit = 10}) => throw UnimplementedError();

  @override
  Future<List<MistakeItem>> getMistakes(int subjectId) => throw UnimplementedError();

  @override
  Future<String> startSession(int subjectId) => throw UnimplementedError();

  @override
  Future<void> finishSession(String sessionId) => throw UnimplementedError();
}

OutboxEntry entry(String clientId, String questionId, {int topic = 1, bool correct = true, DateTime? at}) => OutboxEntry(
  clientId: clientId,
  questionId: questionId,
  topicId: topic,
  subjectId: 5,
  given: 'A',
  isCorrect: correct,
  answeredAt: at ?? DateTime.utc(2026, 11, 3, 10),
);

void main() {
  late LocalDatabase db;
  late DriftAnswerOutbox outbox;
  late DriftOfflineStore store;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    outbox = DriftAnswerOutbox(db);
    store = DriftOfflineStore(db);
  });
  tearDown(() => db.close());

  group('outbox', () {
    test('keeps the order in which answers were given', () async {
      await outbox.add(entry('c1', 'q1'));
      await outbox.add(entry('c2', 'q2'));
      await outbox.add(entry('c3', 'q3'));

      expect((await outbox.all()).map((e) => e.clientId), ['c1', 'c2', 'c3']);
    });

    test('forTopic returns only that topic', () async {
      await outbox.add(entry('c1', 'q1', topic: 1));
      await outbox.add(entry('c2', 'q2', topic: 2));

      expect((await outbox.forTopic(2)).map((e) => e.questionId), ['q2']);
    });

    test('every field comes back, including the locally computed result and "Bilmirəm" (null)', () async {
      await outbox.add(
        OutboxEntry(
          clientId: 'c1',
          questionId: 'q1',
          topicId: 3,
          subjectId: 5,
          given: null,
          isCorrect: false,
          answeredAt: DateTime.utc(2026, 11, 3, 10, 30),
          timeMs: 1200,
        ),
      );

      final back = (await outbox.all()).single;

      expect(back.given, isNull);
      expect(back.isCorrect, isFalse);
      expect(back.topicId, 3);
      expect(back.subjectId, 5);
      expect(back.timeMs, 1200);
      expect(back.answeredAt.toUtc(), DateTime.utc(2026, 11, 3, 10, 30));
    });

    test('the same clientId cannot be queued twice', () async {
      await outbox.add(entry('c1', 'q1'));

      await expectLater(outbox.add(entry('c1', 'q1')), throwsA(anything));
    });

    test('remove deletes one entry and watchCount follows', () async {
      final counts = <int>[];
      final sub = outbox.watchCount().listen(counts.add);
      await Future<void>.delayed(const Duration(milliseconds: 50)); // ilk dəyər (0) gəlsin
      await outbox.add(entry('c1', 'q1'));
      await outbox.add(entry('c2', 'q2'));
      await outbox.remove('c1');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect((await outbox.all()).single.clientId, 'c2');
      expect(counts.first, 0);
      expect(counts.last, 1);
    });
  });

  group('latest answers cache', () {
    test('cacheLatest replaces the topic and leaves other topics alone', () async {
      await store.cacheLatest(1, {'a': true, 'b': false});
      await store.cacheLatest(2, {'x': true});

      await store.cacheLatest(1, {'a': false});

      expect(await store.cachedLatest(1), {'a': false});
      expect(await store.cachedLatest(2), {'x': true});
    });

    test('putCachedLatest adds or updates one answer', () async {
      await store.cacheLatest(1, {'a': true});

      await store.putCachedLatest(1, 'a', false);
      await store.putCachedLatest(1, 'b', true);

      expect(await store.cachedLatest(1), {'a': false, 'b': true});
    });

    test('deleting a downloaded topic clears its cache but keeps unsent answers', () async {
      final remote = FakeRemote()..questions[1] = [question('a', 1)];
      await store.saveTopic(subjectId: 5, topic: catalog(1), questions: remote.questions[1]!);
      await store.cacheLatest(1, {'a': true});
      await outbox.add(entry('c1', 'a'));

      await store.deleteTopic(1);

      expect(await store.cachedLatest(1), isEmpty);
      expect(await outbox.all(), hasLength(1), reason: 'the answer still has to reach the server');
    });
  });

  group('sync', () {
    late RecordingQuiz quiz;
    late AnswerSyncer syncer;

    setUp(() {
      quiz = RecordingQuiz();
      syncer = AnswerSyncer(outbox: outbox, quiz: quiz, store: store, now: () => DateTime.utc(2026, 11, 3, 12));
    });

    test('sends everything in order, without a session, with the client id, then empties the queue', () async {
      await outbox.add(entry('c1', 'q1'));
      await outbox.add(entry('c2', 'q2'));

      final sent = await syncer.flush();

      expect(sent, 2);
      expect(quiz.calls.map((c) => c.questionId), ['q1', 'q2']);
      expect(quiz.calls.map((c) => c.clientId), ['c1', 'c2']);
      expect(quiz.calls.every((c) => c.sessionId == null), isTrue);
      expect(quiz.calls.first.answeredAt!.toUtc(), DateTime.utc(2026, 11, 3, 10));
      expect(await outbox.all(), isEmpty);
    });

    test("the server's decision goes to the cache, even if the phone guessed differently", () async {
      quiz.wrong.add('q1');
      await outbox.add(entry('c1', 'q1', correct: true)); // telefon düz hesabladı, server səhv dedi

      await syncer.flush();

      expect(await store.cachedLatest(1), {'q1': false});
    });

    test('without internet the queue stays as it was and nothing is lost', () async {
      quiz.online = false;
      await outbox.add(entry('c1', 'q1'));
      await outbox.add(entry('c2', 'q2'));

      expect(await syncer.flush(), 0);

      expect((await outbox.all()).map((e) => e.clientId), ['c1', 'c2']);
      expect(quiz.calls, isEmpty);
    });

    test('a connection that drops midway sends the first ones and keeps the rest', () async {
      await outbox.add(entry('c1', 'q1'));
      await outbox.add(entry('c2', 'q2'));
      await outbox.add(entry('c3', 'q3'));
      final flaky = _FailsOn(quiz, 'q2');
      syncer = AnswerSyncer(outbox: outbox, quiz: flaky, store: store);

      expect(await syncer.flush(), 1);

      expect((await outbox.all()).map((e) => e.clientId), ['c2', 'c3']);

      flaky.failOn = null;
      expect(await syncer.flush(), 2);
      expect(await outbox.all(), isEmpty);
    });

    test('a phone clock set in the future does not stamp answers in the future', () async {
      await outbox.add(entry('c1', 'q1', at: DateTime.utc(2030, 1, 1)));

      await syncer.flush();

      expect(quiz.calls.single.answeredAt!.toUtc(), DateTime.utc(2026, 11, 3, 12));
    });

    test('two flushes at the same time do not send an answer twice', () async {
      await outbox.add(entry('c1', 'q1'));

      final results = await Future.wait([syncer.flush(), syncer.flush()]);

      expect(results.reduce((a, b) => a + b), 1);
      expect(quiz.calls, hasLength(1));
    });
  });

  group('client id', () {
    test('looks like a UUID v4 and is different every time', () {
      final ids = {for (var i = 0; i < 50; i++) newClientId()};

      expect(ids, hasLength(50));
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      }
    });
  });

  test('a v1 database is upgraded: old data stays, the outbox is rebuilt and the cache table appears', () async {
    final dir = Directory.systemTemp.createTempSync('prepaz_db');
    addTearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows fayl kilidi: sistem özü təmizləyəcək
      }
    });
    final file = File('${dir.path}${Platform.pathSeparator}old.sqlite');

    // v1 vəziyyətini yaradırıq: yeni cədvəllər yoxdur, köhnə cavab növbəsi var.
    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.localQuestions).insert(
      LocalQuestionsCompanion.insert(
        id: 'q1',
        topicId: 1,
        type: 'qapali',
        body: 'saxlanmalıdır',
        optionsJson: '{}',
        correctAnswer: 'A',
        difficulty: 1,
      ),
    );
    await old.customStatement('DROP TABLE pending_answers');
    await old.customStatement(
      'CREATE TABLE pending_answers (id INTEGER PRIMARY KEY AUTOINCREMENT, client_id TEXT NOT NULL UNIQUE, '
      'question_id TEXT NOT NULL, subject_id INTEGER NOT NULL, given_answer TEXT, time_ms INTEGER NOT NULL DEFAULT 0, '
      'answered_at INTEGER NOT NULL)',
    );
    await old.customStatement('DROP TABLE local_latest_answers');
    await old.customStatement('DROP TABLE local_subjects');
    await old.customStatement('PRAGMA user_version = 1');
    await old.close();

    final upgraded = LocalDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    await DriftAnswerOutbox(upgraded).add(entry('c1', 'q1'));
    await DriftOfflineStore(upgraded).putCachedLatest(1, 'q1', true);

    expect((await upgraded.select(upgraded.localQuestions).getSingle()).body, 'saxlanmalıdır');
    expect(await DriftAnswerOutbox(upgraded).all(), hasLength(1));
    expect(await DriftOfflineStore(upgraded).cachedLatest(1), {'q1': true});
    expect(await DriftOfflineStore(upgraded).cachedSubjects(), isEmpty, reason: 'the subjects cache table exists too');
    expect((await upgraded.customSelect('PRAGMA user_version').getSingle()).read<int>('user_version'), 3);
  });

  test('a v2 database (outbox and cache already there) gets only the subjects table and keeps its answers', () async {
    final dir = Directory.systemTemp.createTempSync('prepaz_db2');
    addTearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows fayl kilidi
      }
    });
    final file = File('${dir.path}${Platform.pathSeparator}v2.sqlite');
    final old = LocalDatabase(NativeDatabase(file));
    await DriftAnswerOutbox(old).add(entry('c1', 'q1'));
    await DriftOfflineStore(old).cacheLatest(1, {'q1': true});
    await old.customStatement('DROP TABLE local_subjects');
    await old.customStatement('PRAGMA user_version = 2');
    await old.close();

    final upgraded = LocalDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    await DriftOfflineStore(upgraded).cacheSubjects([const Subject(id: 1, slug: 'kimya', name: 'Kimya')]);

    expect(await DriftAnswerOutbox(upgraded).all(), hasLength(1), reason: 'unsent answers must survive');
    expect(await DriftOfflineStore(upgraded).cachedLatest(1), {'q1': true});
    expect((await DriftOfflineStore(upgraded).cachedSubjects()).single.name, 'Kimya');
  });
}

/// [failOn] sual id-si üçün xəta verir, qalanını [inner]-ə ötürür.
class _FailsOn implements QuizRepository {
  _FailsOn(this.inner, this.failOn);

  final RecordingQuiz inner;
  String? failOn;

  @override
  Future<bool> submitAnswer({
    required String questionId,
    required String? sessionId,
    required String? given,
    required int timeMs,
    String? clientId,
    DateTime? answeredAt,
  }) {
    if (questionId == failOn) throw const AppException('connection lost');
    return inner.submitAnswer(
      questionId: questionId,
      sessionId: sessionId,
      given: given,
      timeMs: timeMs,
      clientId: clientId,
      answeredAt: answeredAt,
    );
  }

  @override
  Future<List<Question>> getDailySet(int subjectId, {int limit = 20}) => throw UnimplementedError();

  @override
  Future<List<Question>> getTopicSet(int topicId, {int limit = 10}) => throw UnimplementedError();

  @override
  Future<List<MistakeItem>> getMistakes(int subjectId) => throw UnimplementedError();

  @override
  Future<String> startSession(int subjectId) => throw UnimplementedError();

  @override
  Future<void> finishSession(String sessionId) => throw UnimplementedError();
}
