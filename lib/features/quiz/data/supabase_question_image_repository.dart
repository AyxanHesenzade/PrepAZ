import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/question_image_repository.dart';

/// Supabase Storage-in gizli `question-images` bucket-i (giriş etmiş istifadəçi oxuya bilər).
class SupabaseQuestionImageRepository implements QuestionImageRepository {
  const SupabaseQuestionImageRepository(this._storage);

  static const bucket = 'question-images';

  final SupabaseStorageClient _storage;

  @override
  Future<Uint8List> fetch(String path) =>
      guard(() => _storage.from(bucket).download(path));
}
