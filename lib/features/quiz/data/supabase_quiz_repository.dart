import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/mistake_item.dart';
import '../domain/question.dart';
import '../domain/quiz_repository.dart';

class SupabaseQuizRepository implements QuizRepository {
  const SupabaseQuizRepository(this._db);

  final SupabaseClient _db;

  String get _userId => _db.auth.currentUser!.id;

  @override
  Future<List<Question>> getDailySet(int subjectId, {int limit = 20}) {
    return guard(() async {
      final rows = await _db.rpc(
        'get_daily_set',
        params: {'p_subject': subjectId, 'p_limit': limit},
      );
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(questionFromRow)
          .toList();
    });
  }

  @override
  Future<List<Question>> getTopicSet(int topicId, {int limit = 10}) {
    return guard(() async {
      final rows = await _db
          .from('questions')
          .select()
          .eq('topic_id', topicId)
          .eq('is_active', true)
          .limit(200);
      final questions = rows.map(questionFromRow).toList()..shuffle();
      return questions.take(limit).toList();
    });
  }

  @override
  Future<List<MistakeItem>> getMistakes(int subjectId) {
    return guard(() async {
      final rows = await _db
          .from('review_queue')
          .select(
            'due_at, interval_days, questions!inner(*, topics!inner(subject_id))',
          )
          .eq('user_id', _userId)
          .eq('questions.topics.subject_id', subjectId)
          .eq('questions.is_active', true)
          .order('due_at');
      return rows.map(mistakeFromRow).toList();
    });
  }

  @override
  Future<String> startSession(int subjectId) {
    return guard(() async {
      final row = await _db
          .from('sessions')
          .insert({'user_id': _userId, 'kind': 'mesq', 'subject_id': subjectId})
          .select('id')
          .single();
      return row['id'] as String;
    });
  }

  @override
  Future<void> finishSession(String sessionId) {
    return guard(() async {
      await _db
          .from('sessions')
          .update({'finished_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', sessionId);
    });
  }

  @override
  Future<bool> submitAnswer({
    required String questionId,
    required String sessionId,
    required String? given,
    required int timeMs,
  }) {
    return guard(() async {
      final row = await _db
          .from('answers')
          .insert({
            'user_id': _userId,
            'question_id': questionId,
            'session_id': sessionId,
            'given_answer': given,
            'time_ms': timeMs,
          })
          .select('is_correct')
          .single();
      return row['is_correct'] as bool;
    });
  }
}

/// Bazadakı sətir → [Question]. Ayrıca funksiyadır ki, birbaşa test olunsun.
Question questionFromRow(Map<String, dynamic> row) {
  final raw =
      (row['options'] as Map?)?.cast<String, dynamic>() ??
      const <String, dynamic>{};
  final letters = raw.keys.toList()..sort();
  return Question(
    id: row['id'] as String,
    code: row['code'] as String?,
    topicId: (row['topic_id'] as num).toInt(),
    type: _parseType(row['type'] as String),
    body: row['body'] as String,
    imagePath: row['image_path'] as String?,
    options: {for (final letter in letters) letter: '${raw[letter]}'},
    correctAnswer: row['correct_answer'] as String,
    difficulty: (row['difficulty'] as num).toInt(),
    solution: row['solution'] as String?,
    solutionImagePath: row['solution_image_path'] as String?,
  );
}

/// `review_queue` sətri (içində `questions` obyekti ilə) → [MistakeItem].
MistakeItem mistakeFromRow(Map<String, dynamic> row) => MistakeItem(
  question: questionFromRow((row['questions'] as Map).cast<String, dynamic>()),
  dueAt: DateTime.parse(row['due_at'] as String),
  intervalDays: (row['interval_days'] as num).toInt(),
);

QuestionType _parseType(String value) => switch (value) {
  'qapali' => QuestionType.qapali,
  'aciq_eded' => QuestionType.aciqEded,
  _ => QuestionType.yazili,
};
