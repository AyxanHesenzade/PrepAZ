import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_teacher_repository.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>(
  (ref) => SupabaseTeacherRepository(ref.watch(supabaseClientProvider)),
);

/// Siyahı bazadan gəlir (admin paneldən idarə olunur). Testlərdə override olunur.
final teachersProvider = FutureProvider.autoDispose<List<Teacher>>(
  (ref) => ref.watch(teacherRepositoryProvider).getTeachers(),
);
