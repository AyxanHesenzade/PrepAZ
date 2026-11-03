import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/browse/domain/browse_repository.dart';
import 'package:prep_az/features/browse/domain/browse_topic.dart';
import 'package:prep_az/features/offline/data/drift_answer_outbox.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/data/offline_browse_repository.dart';
import 'package:prep_az/features/offline/domain/topic_downloader.dart';
import 'package:prep_az/features/quiz/domain/question.dart';

import 'fakes.dart';

/// Serveri təqlid edir: [online] false olanda hər sorğu xəta verir.
class FakeServer implements BrowseRepository {
  bool online = true;
  int questionCalls = 0;
  final topics = [const BrowseTopic(id: 1, name: 'Server mövzusu', questionCount: 9)];
  final answers = {'a': true};

  void _check() {
    if (!online) throw const AppException('no internet');
  }

  @override
  Future<List<BrowseTopic>> getTopics(int subjectId) async {
    _check();
    return topics;
  }

  @override
  Future<List<Question>> getTopicQuestions(int topicId) async {
    _check();
    questionCalls++;
    return [question('from-server', topicId)];
  }

  @override
  Future<Map<String, bool>> getLatestAnswers(int topicId) async {
    _check();
    return answers;
  }
}

void main() {
  late LocalDatabase db;
  late DriftOfflineStore store;
  late FakeServer server;
  late FakeRemote remote;
  late TopicDownloader downloader;
  late OfflineBrowseRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    store = DriftOfflineStore(db);
    server = FakeServer();
    remote = FakeRemote();
    downloader = TopicDownloader(remote: remote, store: store, images: FakeImages());
    repo = OfflineBrowseRepository(remote: server, store: store, outbox: DriftAnswerOutbox(db));
  });
  tearDown(() => db.close());

  Future<void> download(int topic, List<Question> questions) async {
    remote.questions[topic] = questions;
    await downloader.download(subjectId: 5, topic: catalog(topic));
  }

  test('a topic that was not downloaded is read from the server', () async {
    final questions = await repo.getTopicQuestions(1);

    expect(questions.single.id, 'from-server');
    expect(server.questionCalls, 1);
  });

  test('a downloaded topic is read from the phone even when the internet works', () async {
    await download(1, [question('b', 1, image: 'b.webp'), question('a', 1)]);

    final questions = await repo.getTopicQuestions(1);

    expect(server.questionCalls, 0);
    expect(questions.map((q) => q.code), ['C-a', 'C-b'], reason: 'ordered by code like the server');
    final first = questions.first;
    expect(first.correctAnswer, 'A');
    expect(first.options, {'A': '1', 'B': '2'});
    expect(first.type, QuestionType.qapali);
    expect(questions.last.imagePath, 'b.webp');
  });

  test('every question field survives the trip through the phone database', () async {
    final original = Question(
      id: 'x',
      code: 'KIM-0001',
      topicId: 1,
      type: QuestionType.uygunlasdirma,
      body: r'Düstur $H_2O$',
      imagePath: 'x.webp',
      options: const {'1': 'ABCDE', '2': 'ABCDE'},
      correctAnswer: 'C;BE',
      difficulty: 4,
      solution: 'izah',
      solutionImagePath: 'x_izah.webp',
    );
    await download(1, [original]);

    final back = (await repo.getTopicQuestions(1)).single;

    expect(back.id, original.id);
    expect(back.code, original.code);
    expect(back.type, original.type);
    expect(back.body, original.body);
    expect(back.imagePath, original.imagePath);
    expect(back.options, original.options);
    expect(back.correctAnswer, original.correctAnswer);
    expect(back.difficulty, original.difficulty);
    expect(back.solution, original.solution);
    expect(back.solutionImagePath, original.solutionImagePath);
  });

  test('an incomplete download is not used: the server answers', () async {
    remote.questions[1] = [question('a', 1, image: 'a.webp')];
    remote.failOn = 'a.webp';
    await expectLater(downloader.download(subjectId: 5, topic: catalog(1)), throwsA(isA<AppException>()));

    final questions = await repo.getTopicQuestions(1);

    expect(questions.single.id, 'from-server');
  });

  test('the topic list comes from the server when online', () async {
    await download(2, [question('a', 2)]);

    final topics = await repo.getTopics(5);

    expect(topics.single.name, 'Server mövzusu');
  });

  test('without internet the topic list is built from the downloaded topics', () async {
    await download(2, [question('a', 2), question('b', 2)]);
    server.online = false;

    final topics = await repo.getTopics(5);

    expect(topics.single.id, 2);
    expect(topics.single.name, 'Mövzu 2');
    expect(topics.single.questionCount, 2);
  });

  test('without internet and nothing downloaded the error is shown', () async {
    server.online = false;

    await expectLater(repo.getTopics(5), throwsA(isA<AppException>()));
  });

  test('previous answers: server when online, the phone cache when offline', () async {
    await download(1, [question('a', 1)]);

    expect(await repo.getLatestAnswers(1), {'a': true});

    server.online = false;
    expect(await repo.getLatestAnswers(1), {'a': true}, reason: 'cached during the last online read');
  });

  test('offline before any online read: nothing is known, so the list is empty (not an error)', () async {
    await download(1, [question('a', 1)]);
    server.online = false;

    expect(await repo.getLatestAnswers(1), isEmpty);
  });

  test('previous answers of a topic that was not downloaded: the offline error is shown', () async {
    server.online = false;

    await expectLater(repo.getLatestAnswers(1), throwsA(isA<AppException>()));
  });
}
