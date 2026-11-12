import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/reminder.dart';
import '../domain/reminder_repository.dart';

class SupabaseStreakStatusRepository implements StreakStatusRepository {
  const SupabaseStreakStatusRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<StreakStatus> getStatus() {
    return guard(() async {
      final userId = _db.auth.currentUser!.id;
      final now = DateTime.now();
      final (row, answeredToday) = await (
        _db
            .from('profiles')
            .select('streak_days, last_active')
            .eq('id', userId)
            .maybeSingle()
            .then((r) => r),
        _db
            .from('answers')
            .count(CountOption.exact)
            .eq('user_id', userId)
            .gte(
              'answered_at',
              DateTime(now.year, now.month, now.day).toUtc().toIso8601String(),
            )
            .then((n) => n),
      ).wait;
      final last = row?['last_active'] as String?;
      return StreakStatus(
        streakDays: (row?['streak_days'] as num?)?.toInt() ?? 0,
        lastActive: last == null ? null : DateTime.parse(last),
        answeredToday: answeredToday,
      );
    });
  }
}
