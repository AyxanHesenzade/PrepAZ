import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/app_features.dart';
import '../../../core/providers.dart';
import '../data/layered_image_repositories.dart';
import '../data/public_url_image_repository.dart';
import '../data/supabase_question_image_repository.dart';
import '../data/supabase_quiz_repository.dart';
import '../domain/image_cache.dart';
import '../domain/question_image_repository.dart';
import '../domain/quiz_repository.dart';

/// Şəkillər göstərilsin? Testlərdə override olunur.
final imagesEnabledProvider = Provider<bool>(
  (ref) => AppFeatures.questionImages,
);

/// Köməkçinin söz seçimi. Testlərdə sabit `Random` verilir.
final cheerRandomProvider = Provider<Random>((ref) => Random());

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => SupabaseQuizRepository(ref.watch(supabaseClientProvider)),
);

/// Şəkillərin açıq linki (`IMAGE_BASE_URL`, məs. R2). Boşdursa yalnız Supabase işlədilir.
final imageBaseUrlProvider = Provider<String>((ref) => AppConfig.imageBaseUrl);

/// Şəklin serverdəki mənbəyi, keşsiz (oflayn yükləmə də bunu işlədir: şəkil iki dəfə saxlanmasın).
/// Sıra: açıq link (R2) → alınmasa Supabase. Gələcəkdə gizli server = yalnız burada dəyişiklik.
final remoteImageRepositoryProvider = Provider<QuestionImageRepository>((ref) {
  final supabase = SupabaseQuestionImageRepository(
    ref.watch(supabaseClientProvider).storage,
  );
  final base = ref.watch(imageBaseUrlProvider);
  if (base.isEmpty) return supabase;
  return FallbackImageRepository(PublicUrlImageRepository(base), supabase);
});

/// `main.dart` telefonun cache qovluğunda fayl keşi verir.
final imageCacheProvider = Provider<ImageCache>((ref) => const NoImageCache());

/// Ekranda göstərmək üçün: əvvəl keş, sonra server.
final questionImageRepositoryProvider = Provider<QuestionImageRepository>(
  (ref) => CachedImageRepository(
    ref.watch(remoteImageRepositoryProvider),
    ref.watch(imageCacheProvider),
  ),
);

/// Şəklin baytları. Eyni şəkil üçün widget-lər arasında paylaşılır.
final questionImageBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, String>(
      (ref, path) => ref.watch(questionImageRepositoryProvider).fetch(path),
    );
