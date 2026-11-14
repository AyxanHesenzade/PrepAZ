import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/stats_repository.dart';
import '../domain/subject_stats.dart';

/// `get_my_stats` RPC (db/migrations/018_my_stats.sql).
class SupabaseStatsRepository implements StatsRepository {
  const SupabaseStatsRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<SubjectStats> getStats(int subjectId, {int days = 14}) {
    return guard(() async {
      final json = await _db.rpc<dynamic>(
        'get_my_stats',
        params: {'p_subject': subjectId, 'p_days': days},
      );
      return json is Map<String, dynamic>
          ? statsFromJson(json)
          : SubjectStats.empty;
    });
  }
}

SubjectStats statsFromJson(Map<String, dynamic> json) {
  int n(String key) => (json[key] as num?)?.toInt() ?? 0;
  return SubjectStats(
    answered: n('answered'),
    correct: n('correct'),
    questionsTried: n('questions_tried'),
    questionsSolved: n('questions_solved'),
    questionsTotal: n('questions_total'),
    topicsTotal: n('topics_total'),
    bestStreak: n('best_streak'),
    days: [
      for (final d in (json['days'] as List<dynamic>? ?? const []))
        DayStat(
          day: DateTime.parse((d as Map<String, dynamic>)['day'] as String),
          answered: (d['answered'] as num).toInt(),
          correct: (d['correct'] as num).toInt(),
        ),
    ],
  );
}
