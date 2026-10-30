import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../../quiz/data/supabase_quiz_repository.dart';
import '../../quiz/domain/question.dart';
import '../domain/browse_repository.dart';
import '../domain/browse_topic.dart';

class SupabaseBrowseRepository implements BrowseRepository {
  SupabaseBrowseRepository(this._db);

  final SupabaseClient _db;

  /// Supabase bir sorğuda ən çox 1000 sətir qaytarır, ona görə səhifə-səhifə oxunur.
  static const _page = 1000;

  @override
  Future<List<BrowseTopic>> getTopics(int subjectId) {
    return guard(() async {
      final topics = await _db
          .from('topics')
          .select('id, name, sort_order')
          .eq('subject_id', subjectId);
      final counts = <int, int>{};
      for (var from = 0; ; from += _page) {
        final rows = await _db
            .from('questions')
            .select('topic_id, topics!inner(subject_id)')
            .eq('topics.subject_id', subjectId)
            .eq('is_active', true)
            .order('id')
            .range(from, from + _page - 1);
        for (final row in rows) {
          final id = (row['topic_id'] as num).toInt();
          counts[id] = (counts[id] ?? 0) + 1;
        }
        if (rows.length < _page) break;
      }
      final withQuestions =
          topics
              .where((t) => (counts[(t['id'] as num).toInt()] ?? 0) > 0)
              .toList()
            ..sort((a, b) {
              final bySort = ((a['sort_order'] as num?) ?? 0).compareTo(
                (b['sort_order'] as num?) ?? 0,
              );
              return bySort != 0
                  ? bySort
                  : (a['name'] as String).compareTo(b['name'] as String);
            });
      return [
        for (final t in withQuestions)
          BrowseTopic(
            id: (t['id'] as num).toInt(),
            name: t['name'] as String,
            questionCount: counts[(t['id'] as num).toInt()]!,
          ),
      ];
    });
  }

  @override
  Future<List<Question>> getTopicQuestions(int topicId) {
    return guard(() async {
      final rows = await _db
          .from('questions')
          .select()
          .eq('topic_id', topicId)
          .eq('is_active', true)
          .order('code')
          .limit(_page);
      return rows.map(questionFromRow).toList();
    });
  }
}
