import 'image_store.dart';
import 'offline_models.dart';
import 'offline_store.dart';
import 'remote_download_source.dart';

/// Yükləməni dayandırmaq üçün. Dayandırılan mövzu "yarımçıq" qalır, yenidən basanda davam edir.
class DownloadCancel {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}

/// Mövzunu yükləyir: əvvəl suallar (bazaya), sonra şəkillər (fayl). Xəta [AppException] olaraq çıxır.
class TopicDownloader {
  TopicDownloader({
    required this.remote,
    required this.store,
    required this.images,
    this.parallel = 4,
  });

  final RemoteDownloadSource remote;
  final OfflineStore store;
  final ImageStore images;

  /// Eyni anda neçə şəkil endirilir.
  final int parallel;

  /// Yarıda kəsilibsə, yenidən çağırmaq qaldığı yerdən davam edir (endirilmiş şəkillər təkrar çəkilmir).
  Future<void> download({
    required int subjectId,
    required CatalogTopic topic,
    void Function(int done, int total)? onProgress,
    DownloadCancel? cancel,
  }) async {
    final questions = await remote.fetchTopicQuestions(topic.topicId);
    await store.saveTopic(
      subjectId: subjectId,
      topic: topic,
      questions: questions,
    );

    final paths = imagePathsOf(questions);
    final missing = <String>[];
    for (final path in paths) {
      // Qeyd var, fayl yoxdursa (telefon təmizlənib), şəkil yenidən endirilir.
      if (await store.hasImage(path) && await images.exists(path)) continue;
      missing.add(path);
    }
    var done = paths.length - missing.length;
    onProgress?.call(done, paths.length);

    for (var i = 0; i < missing.length; i += parallel) {
      if (cancel?.isCancelled ?? false) return;
      await Future.wait(
        missing.skip(i).take(parallel).map((path) async {
          final bytes = await remote.downloadImage(path);
          await images.write(path, bytes);
          await store.recordImage(
            topicId: topic.topicId,
            path: path,
            bytes: bytes.length,
          );
          done++;
          onProgress?.call(done, paths.length);
        }),
      );
    }
  }

  /// Mövzunu və yalnız ona aid şəkilləri telefondan silir.
  Future<void> delete(int topicId) async {
    final orphans = await store.deleteTopic(topicId);
    for (final path in orphans) {
      await images.delete(path);
    }
  }
}
