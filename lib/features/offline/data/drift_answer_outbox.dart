import 'package:drift/drift.dart';

import '../domain/answer_outbox.dart';
import 'local_database.dart';

class DriftAnswerOutbox implements AnswerOutbox {
  DriftAnswerOutbox(this._db);

  final LocalDatabase _db;

  @override
  Future<void> add(OutboxEntry entry) async {
    await _db.into(_db.pendingAnswers).insert(
      PendingAnswersCompanion.insert(
        clientId: entry.clientId,
        questionId: entry.questionId,
        topicId: entry.topicId,
        subjectId: entry.subjectId,
        givenAnswer: Value(entry.given),
        isCorrect: entry.isCorrect,
        timeMs: Value(entry.timeMs),
        answeredAt: entry.answeredAt,
      ),
    );
  }

  @override
  Future<List<OutboxEntry>> all() => _select(null);

  @override
  Future<List<OutboxEntry>> forTopic(int topicId) => _select(topicId);

  Future<List<OutboxEntry>> _select(int? topicId) async {
    final query = _db.select(_db.pendingAnswers)
      ..orderBy([(a) => OrderingTerm.asc(a.id)]);
    if (topicId != null) query.where((a) => a.topicId.equals(topicId));
    return [for (final row in await query.get()) _entry(row)];
  }

  @override
  Future<void> remove(String clientId) async {
    await (_db.delete(_db.pendingAnswers)
          ..where((a) => a.clientId.equals(clientId)))
        .go();
  }

  @override
  Stream<int> watchCount() {
    final count = _db.pendingAnswers.id.count();
    final query = _db.selectOnly(_db.pendingAnswers)..addColumns([count]);
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  OutboxEntry _entry(PendingAnswer row) => OutboxEntry(
    clientId: row.clientId,
    questionId: row.questionId,
    topicId: row.topicId,
    subjectId: row.subjectId,
    given: row.givenAnswer,
    isCorrect: row.isCorrect,
    answeredAt: row.answeredAt,
    timeMs: row.timeMs,
  );
}
