import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../home/domain/subject.dart';
import '../../quiz/domain/question.dart';
import '../domain/offline_models.dart';
import '../domain/offline_store.dart';
import 'local_database.dart';

class DriftOfflineStore implements OfflineStore {
  DriftOfflineStore(this._db);

  final LocalDatabase _db;

  /// Mövzu siyahısı dəyişəndə siqnal verir. Drift-in `watch()`-u əvəzinə: o, widget testlərində widget
  /// silinəndə gözləyən Timer qoyur. Bir mağaza nüsxəsi var (provider), bütün dəyişikliklər buradan keçir.
  final _topicChanges = StreamController<void>.broadcast(sync: true);

  @override
  Future<void> saveTopic({
    required int subjectId,
    required CatalogTopic topic,
    required List<Question> questions,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.localQuestions,
      )..where((q) => q.topicId.equals(topic.topicId))).go();
      await _db.batch(
        (b) => b.insertAll(_db.localQuestions, questions.map(_row).toList()),
      );
      final paths = imagePathsOf(questions);
      await _db
          .into(_db.downloadedTopics)
          .insertOnConflictUpdate(
            DownloadedTopicsCompanion.insert(
              topicId: Value(topic.topicId),
              subjectId: subjectId,
              topicName: topic.topicName,
              sectionName: Value(topic.sectionName),
              questionCount: questions.length,
              version: topic.version,
              imageCount: paths.length,
              imageBytes: topic.imageBytes,
              imagesDone: Value(await _storedCount(paths)),
              downloadedAt: DateTime.now().toUtc(),
            ),
          );
    });
    _topicChanges.add(null);
  }

  @override
  Future<bool> hasImage(String path) async {
    final row = await (_db.select(
      _db.localImages,
    )..where((i) => i.path.equals(path))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> recordImage({
    required int topicId,
    required String path,
    required int bytes,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.localImages)
          .insertOnConflictUpdate(
            LocalImagesCompanion.insert(path: path, bytes: bytes),
          );
      final done = await _storedCount(await _topicPaths(topicId));
      await (_db.update(_db.downloadedTopics)
            ..where((t) => t.topicId.equals(topicId)))
          .write(DownloadedTopicsCompanion(imagesDone: Value(done)));
    });
    _topicChanges.add(null);
  }

  @override
  Future<StoredTopic?> getTopic(int topicId) async {
    final row = await (_db.select(
      _db.downloadedTopics,
    )..where((t) => t.topicId.equals(topicId))).getSingleOrNull();
    return row == null ? null : _stored(row);
  }

  @override
  Future<List<Subject>> cachedSubjects() async {
    final rows = await (_db.select(
      _db.localSubjects,
    )..orderBy([(s) => OrderingTerm.asc(s.position)])).get();
    return [for (final r in rows) Subject(id: r.id, slug: r.slug, name: r.name)];
  }

  @override
  Future<void> cacheSubjects(List<Subject> subjects) {
    return _db.transaction(() async {
      await _db.delete(_db.localSubjects).go();
      await _db.batch(
        (b) => b.insertAll(_db.localSubjects, [
          for (final (i, s) in subjects.indexed)
            LocalSubjectsCompanion.insert(id: Value(s.id), slug: s.slug, name: s.name, position: i),
        ]),
      );
    });
  }

  @override
  Future<Map<String, bool>> cachedLatest(int topicId) async {
    final rows = await (_db.select(
      _db.localLatestAnswers,
    )..where((a) => a.topicId.equals(topicId))).get();
    return {for (final row in rows) row.questionId: row.isCorrect};
  }

  @override
  Future<void> cacheLatest(int topicId, Map<String, bool> answers) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.localLatestAnswers,
      )..where((a) => a.topicId.equals(topicId))).go();
      await _db.batch(
        (b) => b.insertAll(_db.localLatestAnswers, [
          for (final e in answers.entries)
            LocalLatestAnswersCompanion.insert(
              questionId: e.key,
              topicId: topicId,
              isCorrect: e.value,
            ),
        ]),
      );
    });
  }

  @override
  Future<void> putCachedLatest(
    int topicId,
    String questionId,
    bool isCorrect,
  ) async {
    await _db
        .into(_db.localLatestAnswers)
        .insertOnConflictUpdate(
          LocalLatestAnswersCompanion.insert(
            questionId: questionId,
            topicId: topicId,
            isCorrect: isCorrect,
          ),
        );
  }

  @override
  Future<List<Question>> questionsOf(int topicId) async {
    final rows =
        await (_db.select(_db.localQuestions)
              ..where((q) => q.topicId.equals(topicId))
              ..orderBy([
                (q) => OrderingTerm.asc(q.code),
                (q) => OrderingTerm.asc(q.id),
              ]))
            .get();
    return rows.map(_question).toList();
  }

  @override
  Stream<List<StoredTopic>> watchTopics(int subjectId) => _watch(subjectId);

  @override
  Stream<List<StoredTopic>> watchAllTopics() => _watch(null);

  Stream<List<StoredTopic>> _watch(int? subjectId) {
    late final StreamController<List<StoredTopic>> controller;
    StreamSubscription<void>? changes;
    Future<void> emit() async {
      final rows = await _topics(subjectId);
      if (!controller.isClosed) controller.add(rows);
    }

    controller = StreamController<List<StoredTopic>>(
      onListen: () {
        changes = _topicChanges.stream.listen((_) => emit());
        emit();
      },
      onCancel: () async {
        await changes?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  Future<List<StoredTopic>> _topics(int? subjectId) async {
    final query = _db.select(_db.downloadedTopics)
      ..orderBy([(t) => OrderingTerm.asc(t.topicName)]);
    if (subjectId != null) query.where((t) => t.subjectId.equals(subjectId));
    final rows = await query.get();
    return rows.map(_stored).toList();
  }

  @override
  Future<List<String>> deleteTopic(int topicId) async {
    final orphans = await _db.transaction(() async {
      final paths = await _topicPaths(topicId);
      await (_db.delete(
        _db.localQuestions,
      )..where((q) => q.topicId.equals(topicId))).go();
      await (_db.delete(
        _db.downloadedTopics,
      )..where((t) => t.topicId.equals(topicId))).go();
      await (_db.delete(
        _db.localLatestAnswers,
      )..where((a) => a.topicId.equals(topicId))).go();

      final orphans = <String>[];
      for (final path in paths) {
        final stillUsed =
            await (_db.select(_db.localQuestions)
                  ..where(
                    (q) =>
                        q.imagePath.equals(path) |
                        q.solutionImagePath.equals(path),
                  )
                  ..limit(1))
                .get();
        if (stillUsed.isEmpty) orphans.add(path);
      }
      if (orphans.isNotEmpty) {
        await (_db.delete(
          _db.localImages,
        )..where((i) => i.path.isIn(orphans))).go();
      }
      return orphans;
    });
    _topicChanges.add(null);
    return orphans;
  }

  /// Mövzunun suallarındakı şəkil yolları (təkrarsız).
  Future<List<String>> _topicPaths(int topicId) async {
    final rows = await (_db.select(
      _db.localQuestions,
    )..where((q) => q.topicId.equals(topicId))).get();
    final paths = <String>{};
    for (final row in rows) {
      if (row.imagePath != null && row.imagePath!.isNotEmpty) {
        paths.add(row.imagePath!);
      }
      if (row.solutionImagePath != null && row.solutionImagePath!.isNotEmpty) {
        paths.add(row.solutionImagePath!);
      }
    }
    return paths.toList();
  }

  /// [paths] içindən neçəsi telefonda endirilib.
  Future<int> _storedCount(List<String> paths) async {
    if (paths.isEmpty) return 0;
    final rows = await (_db.select(
      _db.localImages,
    )..where((i) => i.path.isIn(paths))).get();
    return rows.length;
  }

  /// Sual tipi enum adı ilə saxlanır (`QuestionType.name`); enum adı dəyişsə, sxema migrasiyası lazımdır.
  LocalQuestionsCompanion _row(Question q) => LocalQuestionsCompanion.insert(
    id: q.id,
    code: Value(q.code),
    topicId: q.topicId,
    type: q.type.name,
    body: q.body,
    imagePath: Value(q.imagePath),
    optionsJson: jsonEncode(q.options),
    correctAnswer: q.correctAnswer,
    difficulty: q.difficulty,
    solution: Value(q.solution),
    solutionImagePath: Value(q.solutionImagePath),
  );

  Question _question(LocalQuestion row) {
    final raw = (jsonDecode(row.optionsJson) as Map).cast<String, dynamic>();
    final letters = raw.keys.toList()..sort();
    return Question(
      id: row.id,
      code: row.code,
      topicId: row.topicId,
      type: QuestionType.values.byName(row.type),
      body: row.body,
      imagePath: row.imagePath,
      options: {for (final letter in letters) letter: '${raw[letter]}'},
      correctAnswer: row.correctAnswer,
      difficulty: row.difficulty,
      solution: row.solution,
      solutionImagePath: row.solutionImagePath,
    );
  }

  StoredTopic _stored(DownloadedTopic row) => StoredTopic(
    topicId: row.topicId,
    subjectId: row.subjectId,
    topicName: row.topicName,
    sectionName: row.sectionName,
    questionCount: row.questionCount,
    version: row.version,
    imageCount: row.imageCount,
    imageBytes: row.imageBytes,
    imagesDone: row.imagesDone,
    downloadedAt: row.downloadedAt,
  );
}
