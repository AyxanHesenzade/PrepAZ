import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_profile_repository.dart';
import '../data/supabase_progress_repository.dart';
import '../data/supabase_subject_repository.dart';
import '../domain/profile_repository.dart';
import '../domain/progress_repository.dart';
import '../domain/subject.dart';
import '../domain/subject_repository.dart';
import '../domain/topic_mastery.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>(
  (ref) => SupabaseSubjectRepository(ref.watch(supabaseClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

final subjectsProvider = FutureProvider.autoDispose<List<Subject>>(
  (ref) => ref.watch(subjectRepositoryProvider).getSubjects(),
);

final streakDaysProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(profileRepositoryProvider).getStreakDays(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => SupabaseProgressRepository(ref.watch(supabaseClientProvider)),
);

/// Fənn üzrə mövzu mənimsənilməsi (ən zəifi birinci).
final masteryProvider = FutureProvider.autoDispose
    .family<List<TopicMastery>, int>(
      (ref, subjectId) =>
          ref.watch(progressRepositoryProvider).getMastery(subjectId),
    );
