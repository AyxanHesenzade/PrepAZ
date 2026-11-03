import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../../quiz/data/supabase_question_image_repository.dart';
import '../../quiz/data/supabase_quiz_repository.dart';
import '../../quiz/domain/question.dart';
import '../domain/offline_models.dart';
import '../domain/remote_download_source.dart';

class SupabaseDownloadSource implements RemoteDownloadSource {
  const SupabaseDownloadSource(this._db);

  final SupabaseClient _db;

  /// Supabase bir sorğuda ən çox 1000 sətir qaytarır, ona görə səhifə-səhifə oxunur.
  static const _page = 1000;

  @override
  Future<List<CatalogTopic>> fetchCatalog(int subjectId) {
    return guard(() async {
      final rows = await _db.rpc<List<dynamic>>(
        'get_download_catalog',
        params: {'p_subject': subjectId},
      );
      return [
        for (final row in rows.cast<Map<String, dynamic>>())
          catalogTopicFromRow(row),
      ];
    });
  }

  @override
  Future<List<Question>> fetchTopicQuestions(int topicId) {
    return guard(() async {
      final questions = <Question>[];
      for (var from = 0; ; from += _page) {
        final rows = await _db
            .from('questions')
            .select()
            .eq('topic_id', topicId)
            .eq('is_active', true)
            .order('code')
            .order('id')
            .range(from, from + _page - 1);
        questions.addAll(rows.map(questionFromRow));
        if (rows.length < _page) return questions;
      }
    });
  }

  @override
  Future<Uint8List> downloadImage(String path) {
    return guard(
      () => _db.storage
          .from(SupabaseQuestionImageRepository.bucket)
          .download(path),
    );
  }
}

/// `get_download_catalog` sətri → [CatalogTopic]. Ayrıca funksiyadır ki, birbaşa test olunsun.
CatalogTopic catalogTopicFromRow(Map<String, dynamic> row) => CatalogTopic(
  topicId: (row['topic_id'] as num).toInt(),
  topicName: row['topic_name'] as String,
  sectionName: row['section_name'] as String?,
  questionCount: (row['question_count'] as num).toInt(),
  version: (row['version'] as num).toInt(),
  imageCount: (row['image_count'] as num).toInt(),
  imageBytes: (row['image_bytes'] as num).toInt(),
);
