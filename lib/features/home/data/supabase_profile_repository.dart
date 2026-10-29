import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<int> getStreakDays() {
    return guard(() async {
      final userId = _db.auth.currentUser!.id;
      final row = await _db.from('profiles').select('streak_days').eq('id', userId).maybeSingle();
      return (row?['streak_days'] as num?)?.toInt() ?? 0;
    });
  }
}
