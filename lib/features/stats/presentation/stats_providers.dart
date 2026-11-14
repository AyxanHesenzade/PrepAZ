import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_stats_repository.dart';
import '../domain/stats_repository.dart';
import '../domain/subject_stats.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => SupabaseStatsRepository(ref.watch(supabaseClientProvider)),
);

/// Fənn üzrə statistika (bu və keçən həftə).
final subjectStatsProvider = FutureProvider.autoDispose
    .family<SubjectStats, int>(
      (ref, subjectId) =>
          ref.watch(statsRepositoryProvider).getStats(subjectId),
    );
