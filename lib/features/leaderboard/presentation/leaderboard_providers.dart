import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_leaderboard_repository.dart';
import '../domain/leaderboard.dart';
import '../domain/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => SupabaseLeaderboardRepository(ref.watch(supabaseClientProvider)),
);

/// null = şagird hələ yarışa qoşulmayıb (nik-ad forması göstərilir).
final myPlayerProvider = FutureProvider.autoDispose<Player?>(
  (ref) => ref.watch(leaderboardRepositoryProvider).getMyPlayer(),
);

final leaderboardProvider = FutureProvider.autoDispose
    .family<Leaderboard, int>(
      (ref, subjectId) =>
          ref.watch(leaderboardRepositoryProvider).getLeaderboard(subjectId),
    );
