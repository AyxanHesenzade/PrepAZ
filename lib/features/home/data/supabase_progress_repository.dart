import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/progress_repository.dart';
import '../domain/topic_mastery.dart';

class SupabaseProgressRepository implements ProgressRepository {
  const SupabaseProgressRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<List<TopicMastery>> getMastery(int subjectId) {
    return guard(() async {
      // user_id süzgəci vacibdir: view bütün istifadəçilərin sətirlərini saxlayır.
      final rows = await _db
          .from('topic_mastery')
          .select('topic_id, topic_name, answered, mastery_pct')
          .eq('subject_id', subjectId)
          .eq('user_id', _db.auth.currentUser!.id)
          .order('mastery_pct');
      return rows.map(_toMastery).toList();
    });
  }

  static TopicMastery _toMastery(Map<String, dynamic> row) => TopicMastery(
    topicId: (row['topic_id'] as num).toInt(),
    topicName: row['topic_name'] as String,
    answered: (row['answered'] as num).toInt(),
    masteryPct: (row['mastery_pct'] as num).toInt(),
  );
}
