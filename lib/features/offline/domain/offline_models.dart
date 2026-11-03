import '../../home/domain/subject.dart';
import '../../quiz/domain/question.dart';

/// Serverin yükləmə kataloqunda mövzu (`get_download_catalog` sətri).
class CatalogTopic {
  const CatalogTopic({
    required this.topicId,
    required this.topicName,
    required this.questionCount,
    required this.version,
    required this.imageCount,
    required this.imageBytes,
    this.sectionName,
  });

  final int topicId;
  final String topicName;
  final String? sectionName;
  final int questionCount;

  /// Mövzu dəyişəndə dəyişir (bax db/migrations/016_download_catalog.sql).
  final int version;
  final int imageCount;
  final int imageBytes;
}

/// Telefona yüklənmiş mövzu.
class StoredTopic {
  const StoredTopic({
    required this.topicId,
    required this.subjectId,
    required this.topicName,
    required this.questionCount,
    required this.version,
    required this.imageCount,
    required this.imageBytes,
    required this.imagesDone,
    required this.downloadedAt,
    this.sectionName,
  });

  final int topicId;
  final int subjectId;
  final String topicName;
  final String? sectionName;
  final int questionCount;
  final int version;
  final int imageCount;
  final int imageBytes;
  final int imagesDone;
  final DateTime downloadedAt;

  /// Bütün şəkillər endirilib: mövzu internetsiz tam işləyir.
  bool get isComplete => imagesDone >= imageCount;
}

/// Telefonda mövzusu yüklənmiş fənn.
class DownloadedSubject {
  const DownloadedSubject({required this.subject, required this.topics});

  final Subject subject;
  final List<StoredTopic> topics;

  int get bytes => topics.fold(0, (sum, t) => sum + t.imageBytes);
}

enum TopicDownloadState { notDownloaded, incomplete, ready, updateAvailable }

/// Mövzunun ekranda göstəriləcək vəziyyəti. [server] kataloqdan, [stored] telefondan.
TopicDownloadState downloadStateOf(CatalogTopic? server, StoredTopic? stored) {
  if (stored == null) return TopicDownloadState.notDownloaded;
  if (!stored.isComplete) return TopicDownloadState.incomplete;
  if (server != null && server.version != stored.version) {
    return TopicDownloadState.updateAvailable;
  }
  return TopicDownloadState.ready;
}

/// Suallardakı şəkil yolları (sual və izah şəkli), təkrarsız, sıra ilə.
List<String> imagePathsOf(Iterable<Question> questions) {
  final paths = <String>{};
  for (final q in questions) {
    if (q.hasImage) paths.add(q.imagePath!);
    if (q.hasSolutionImage) paths.add(q.solutionImagePath!);
  }
  return paths.toList();
}
