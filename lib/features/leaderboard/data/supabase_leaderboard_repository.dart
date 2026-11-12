import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/leaderboard.dart';
import '../domain/leaderboard_repository.dart';

/// `leaderboard_players` cədvəli və `get_leaderboard` RPC (db/migrations/017_leaderboard.sql).
class SupabaseLeaderboardRepository implements LeaderboardRepository {
  const SupabaseLeaderboardRepository(this._db);

  static const topLimit = 50;

  final SupabaseClient _db;

  @override
  Future<Player?> getMyPlayer() {
    return guard(() async {
      final row = await _db
          .from('leaderboard_players')
          .select('nickname, first_name, last_name')
          .eq('user_id', _db.auth.currentUser!.id)
          .maybeSingle();
      return row == null ? null : playerFromRow(row);
    });
  }

  @override
  Future<void> savePlayer(Player player) {
    return guard(
      () async {
        await _db.from('leaderboard_players').upsert({
          'user_id': _db.auth.currentUser!.id,
          'nickname': player.nickname.trim(),
          'first_name': player.firstName.trim(),
          'last_name': player.lastName.trim(),
        });
      },
      mapper: (error) => error is PostgrestException && error.code == '23505'
          ? NicknameTakenException(AppStrings.nicknameTaken)
          : null,
    );
  }

  @override
  Future<Leaderboard> getLeaderboard(int subjectId) {
    return guard(() async {
      final rows = await _db.rpc<List<dynamic>>(
        'get_leaderboard',
        params: {
          'p_subject': subjectId,
          'p_period': 'all',
          'p_limit': topLimit,
        },
      );
      return Leaderboard([
        for (final r in rows) entryFromRow(r as Map<String, dynamic>),
      ]);
    });
  }
}

Player playerFromRow(Map<String, dynamic> row) => Player(
  nickname: row['nickname'] as String,
  firstName: row['first_name'] as String,
  lastName: row['last_name'] as String,
);

LeaderboardEntry entryFromRow(Map<String, dynamic> row) => LeaderboardEntry(
  rank: (row['rank'] as num).toInt(),
  nickname: row['nickname'] as String,
  score: (row['score'] as num).toInt(),
  isMe: row['is_me'] as bool? ?? false,
);
