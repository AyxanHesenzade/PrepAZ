import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_question_image_repository.dart';
import '../data/supabase_quiz_repository.dart';
import '../domain/question_image_repository.dart';
import '../domain/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => SupabaseQuizRepository(ref.watch(supabaseClientProvider)),
);

final questionImageRepositoryProvider = Provider<QuestionImageRepository>(
  (ref) => SupabaseQuestionImageRepository(ref.watch(supabaseClientProvider).storage),
);

/// Şəklin imzalı linki. Eyni şəkil üçün widget-lər arasında paylaşılır.
final questionImageUrlProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, path) => ref.watch(questionImageRepositoryProvider).signedUrl(path),
);
