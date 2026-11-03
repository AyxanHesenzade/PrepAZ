import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../domain/offline_models.dart';
import '../domain/topic_downloader.dart';
import 'offline_providers.dart';

/// Yüklənməkdə olan (və ya alınmayan) mövzunun vəziyyəti.
class TopicActivity {
  const TopicActivity({this.done = 0, this.total = 0, this.error});

  final int done;
  final int total;

  /// Doludursa, yükləmə alınmayıb: ekranda xəta və "Yenidən cəhd et" göstərilir.
  final String? error;

  bool get failed => error != null;

  /// 0..1 (şəkil sayına görə).
  double get fraction => total == 0 ? 0 : (done / total).clamp(0, 1).toDouble();
}

/// Mövzu yükləmələrini idarə edir. Ekrandan çıxanda yükləmə dayanmır (provider tətbiq boyu yaşayır).
class DownloadsController extends Notifier<Map<int, TopicActivity>> {
  final _cancels = <int, DownloadCancel>{};

  @override
  Map<int, TopicActivity> build() => const {};

  TopicDownloader get _downloader => ref.read(topicDownloaderProvider);

  bool isBusy(int topicId) {
    final activity = state[topicId];
    return activity != null && !activity.failed;
  }

  /// Bir mövzunu yükləyir (yarımçıqdırsa, qaldığı yerdən). Xəta ekrana [TopicActivity.error] ilə çıxır.
  Future<void> download({required int subjectId, required CatalogTopic topic}) async {
    final id = topic.topicId;
    if (isBusy(id)) return;
    final cancel = _cancels[id] = DownloadCancel();
    _set(id, const TopicActivity());
    try {
      await _downloader.download(
        subjectId: subjectId,
        topic: topic,
        cancel: cancel,
        onProgress: (done, total) => _set(id, TopicActivity(done: done, total: total)),
      );
      _clear(id);
    } on AppException catch (e) {
      _set(id, TopicActivity(error: e.message));
    } finally {
      _cancels.remove(id);
    }
  }

  /// Verilən mövzuları ardıcıl yükləyir (eyni anda yox: şəbəkə və batareya).
  Future<void> downloadAll({required int subjectId, required List<CatalogTopic> topics}) async {
    for (final topic in topics) {
      if (!ref.mounted) return;
      await download(subjectId: subjectId, topic: topic);
      if (state[topic.topicId]?.failed ?? false) return; // internet getdi: qalanlarını boş yerə yoxlamırıq
    }
  }

  /// Dayandırılan mövzu "yarımçıq" qalır, yenidən basanda davam edir.
  void cancel(int topicId) => _cancels[topicId]?.cancel();

  Future<void> delete(int topicId) async {
    await _downloader.delete(topicId);
    _clear(topicId);
  }

  void _set(int id, TopicActivity activity) {
    if (ref.mounted) state = {...state, id: activity};
  }

  void _clear(int id) {
    if (ref.mounted) state = {...state}..remove(id);
  }
}

final downloadsControllerProvider =
    NotifierProvider<DownloadsController, Map<int, TopicActivity>>(DownloadsController.new);
