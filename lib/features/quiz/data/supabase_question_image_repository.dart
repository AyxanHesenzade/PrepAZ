import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/question_image_repository.dart';

class SupabaseQuestionImageRepository implements QuestionImageRepository {
  const SupabaseQuestionImageRepository(this._storage);

  static const bucket = 'question-images';
  static const _linkLifetimeSeconds = 3600;

  final SupabaseStorageClient _storage;

  @override
  Future<String> signedUrl(String path) {
    return guard(() => _storage.from(bucket).createSignedUrl(path, _linkLifetimeSeconds));
  }
}
