import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_goal_repository.dart';
import '../domain/exam_goal.dart';
import '../domain/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => SupabaseGoalRepository(ref.watch(supabaseClientProvider)),
);

final examPeriodsProvider = FutureProvider.autoDispose<List<ExamPeriod>>(
  (ref) => ref.watch(goalRepositoryProvider).getPeriods(),
);

final userGoalProvider = FutureProvider.autoDispose<UserGoal?>(
  (ref) => ref.watch(goalRepositoryProvider).getGoal(),
);

/// Bu gün (telefonun vaxtı ilə 00:00-dan) verilən cavabların sayı.
final answeredTodayProvider = FutureProvider.autoDispose<int>((ref) {
  final now = DateTime.now();
  return ref
      .watch(goalRepositoryProvider)
      .countAnswersSince(DateTime(now.year, now.month, now.day));
});
