import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/exam_goal.dart';
import '../domain/goal_repository.dart';

class SupabaseGoalRepository implements GoalRepository {
  const SupabaseGoalRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<List<ExamPeriod>> getPeriods() {
    return guard(() async {
      final rows = await _db
          .from('exam_periods')
          .select('id, code, name, exam_date')
          .eq('is_active', true)
          .order('sort_order');
      return [for (final r in rows) periodFromRow(r)];
    });
  }

  @override
  Future<UserGoal?> getGoal() {
    return guard(() async {
      final row = await _db
          .from('user_goals')
          .select('exam_period_id, custom_exam_date, daily_goal')
          .eq('user_id', _db.auth.currentUser!.id)
          .maybeSingle();
      return row == null ? null : goalFromRow(row);
    });
  }

  @override
  Future<void> saveGoal(UserGoal goal) {
    return guard(() async {
      await _db.from('user_goals').upsert({
        'user_id': _db.auth.currentUser!.id,
        'exam_period_id': goal.periodId,
        'custom_exam_date': goal.customDate == null
            ? null
            : formatDate(goal.customDate!),
        'daily_goal': goal.dailyGoal,
      });
    });
  }

  @override
  Future<int> countAnswersSince(DateTime from) {
    return guard(
      () => _db
          .from('answers')
          .count(CountOption.exact)
          .eq('user_id', _db.auth.currentUser!.id)
          .gte('answered_at', from.toUtc().toIso8601String()),
    );
  }
}

ExamPeriod periodFromRow(Map<String, dynamic> row) => ExamPeriod(
  id: (row['id'] as num).toInt(),
  code: row['code'] as String,
  name: row['name'] as String,
  examDate: DateTime.parse(row['exam_date'] as String),
);

UserGoal goalFromRow(Map<String, dynamic> row) => UserGoal(
  periodId: (row['exam_period_id'] as num?)?.toInt(),
  customDate: row['custom_exam_date'] == null
      ? null
      : DateTime.parse(row['custom_exam_date'] as String),
  dailyGoal: (row['daily_goal'] as num?)?.toInt() ?? UserGoal.defaultDailyGoal,
);

String formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
