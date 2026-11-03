import 'dart:typed_data';

import '../../quiz/domain/question.dart';
import 'offline_models.dart';

/// Serverdən yükləmə: kataloq, mövzunun sualları, şəkil faylı.
abstract interface class RemoteDownloadSource {
  Future<List<CatalogTopic>> fetchCatalog(int subjectId);

  /// Mövzunun bütün aktiv sualları (düz cavab daxil).
  Future<List<Question>> fetchTopicQuestions(int topicId);

  Future<Uint8List> downloadImage(String path);
}
