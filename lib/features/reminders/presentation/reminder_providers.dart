import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_streak_status_repository.dart';
import '../domain/reminder_repository.dart';

/// Defolt: bildiriş yoxdur (testlər). `main.dart` onu `LocalReminderScheduler` ilə əvəz edir.
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => const NoReminderScheduler(),
);

final streakStatusRepositoryProvider = Provider<StreakStatusRepository>(
  (ref) => SupabaseStreakStatusRepository(ref.watch(supabaseClientProvider)),
);
