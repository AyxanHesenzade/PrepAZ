import 'dart:typed_data';

import '../../../core/logging/app_log.dart';
import '../domain/image_cache.dart';
import '../domain/question_image_repository.dart';

/// Əvvəl [primary] (məs. R2), alınmasa [fallback] (məs. Supabase). Köçürmə zamanı hələ köçməmiş şəkil də
/// açılır; hansı şəkillərin əsas mənbədə olmadığı loglarda `image_fallback` kimi görünür.
class FallbackImageRepository implements QuestionImageRepository {
  const FallbackImageRepository(this.primary, this.fallback);

  final QuestionImageRepository primary;
  final QuestionImageRepository fallback;

  @override
  Future<Uint8List> fetch(String path) async {
    try {
      return await primary.fetch(path);
    } catch (_) {
      final bytes = await fallback.fetch(path);
      AppLog.info('image_fallback', meta: {'path': path});
      return bytes;
    }
  }
}

/// Keşdə varsa oradan, yoxsa [inner]-dən yükləyib keşə yazır. Keş xətası şəkli göstərməyə mane olmur.
class CachedImageRepository implements QuestionImageRepository {
  const CachedImageRepository(this.inner, this.cache);

  final QuestionImageRepository inner;
  final ImageCache cache;

  @override
  Future<Uint8List> fetch(String path) async {
    final cached = await _safe(() => cache.read(path));
    if (cached != null) return cached;
    final bytes = await inner.fetch(path);
    await _safe(() => cache.write(path, bytes));
    return bytes;
  }

  static Future<T?> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }
}
