import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/offline/data/local_database.dart';

void main() {
  late LocalDatabase db;

  setUp(() => db = LocalDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  LocalQuestionsCompanion question(String id, int topic, {String? image}) =>
      LocalQuestionsCompanion.insert(
        id: id,
        topicId: topic,
        type: 'qapali',
        body: 'x',
        optionsJson: '{"A": "1", "B": "2"}',
        correctAnswer: 'A',
        difficulty: 1,
        imagePath: Value(image),
      );

  test('a question is stored and read back with its answer key', () async {
    await db.into(db.localQuestions).insert(question('q1', 7, image: 'A.webp'));

    final row = await (db.select(db.localQuestions)..where((q) => q.id.equals('q1'))).getSingle();

    expect(row.topicId, 7);
    expect(row.correctAnswer, 'A');
    expect(row.imagePath, 'A.webp');
    expect(row.solution, isNull);
  });

  test('questions are found by topic', () async {
    await db.batch((b) {
      b.insertAll(db.localQuestions, [question('a', 1), question('b', 1), question('c', 2)]);
    });

    final rows = await (db.select(db.localQuestions)..where((q) => q.topicId.equals(1))).get();

    expect(rows.map((r) => r.id), unorderedEquals(['a', 'b']));
  });

  test('a topic keeps its version (a microsecond epoch fits an int) and download progress', () async {
    const version = 1793706651634870;
    await db.into(db.downloadedTopics).insert(
      DownloadedTopicsCompanion.insert(
        topicId: const Value(11),
        subjectId: 1,
        topicName: 'Kimyanın əsas anlayışları',
        sectionName: const Value('Ümumi kimya'),
        questionCount: 100,
        version: version,
        imageCount: 102,
        imageBytes: 3125990,
        downloadedAt: DateTime.utc(2026, 11, 3),
      ),
    );

    final row = await db.select(db.downloadedTopics).getSingle();

    expect(row.version, version);
    expect(row.imagesDone, 0);
    expect(row.imagesDone == row.imageCount, isFalse);
  });

  test('the same answer cannot be queued twice (clientId is unique)', () async {
    PendingAnswersCompanion answer(String clientId) => PendingAnswersCompanion.insert(
      clientId: clientId,
      questionId: 'q1',
      topicId: 1,
      subjectId: 1,
      isCorrect: true,
      answeredAt: DateTime.utc(2026, 11, 3),
    );
    await db.into(db.pendingAnswers).insert(answer('c1'));

    await expectLater(db.into(db.pendingAnswers).insert(answer('c1')), throwsA(anything));
    await db.into(db.pendingAnswers).insert(answer('c2'));

    expect(await db.select(db.pendingAnswers).get(), hasLength(2));
  });

  test('queued answers keep their order', () async {
    for (final id in ['c1', 'c2', 'c3']) {
      await db.into(db.pendingAnswers).insert(
        PendingAnswersCompanion.insert(
          clientId: id,
          questionId: 'q',
          topicId: 1,
          subjectId: 1,
          isCorrect: false,
          answeredAt: DateTime.utc(2026, 11, 3),
        ),
      );
    }

    final rows = await (db.select(db.pendingAnswers)..orderBy([(a) => OrderingTerm.asc(a.id)])).get();

    expect(rows.map((r) => r.clientId), ['c1', 'c2', 'c3']);
  });
}
