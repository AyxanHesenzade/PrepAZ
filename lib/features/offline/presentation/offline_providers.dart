import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/drift_answer_outbox.dart';
import '../data/drift_offline_store.dart';
import '../data/in_memory_image_store.dart';
import '../data/local_database.dart';
import '../data/supabase_download_source.dart';
import '../domain/answer_outbox.dart';
import '../domain/image_store.dart';
import '../../home/domain/subject.dart';
import '../domain/offline_models.dart';
import '../domain/offline_store.dart';
import '../domain/remote_download_source.dart';
import '../domain/topic_downloader.dart';

/// Son sorğu serverə çatdımı? `true` = ana ekran telefondakı fənn siyahısını göstərir ("Hazırda oflayn rejimdəsən").
class OfflineMode extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool offline) {
    if (state != offline) state = offline;
  }
}

final offlineModeProvider = NotifierProvider<OfflineMode, bool>(OfflineMode.new);

/// `main.dart` burada telefondakı real fayl bazasını verir; testlərdə yaddaşdakı baza işləyir.
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase(NativeDatabase.memory());
  ref.onDispose(db.close);
  return db;
});

final offlineStoreProvider = Provider<OfflineStore>(
  (ref) => DriftOfflineStore(ref.watch(localDatabaseProvider)),
);

final answerOutboxProvider = Provider<AnswerOutbox>(
  (ref) => DriftAnswerOutbox(ref.watch(localDatabaseProvider)),
);

/// `main.dart` burada `FileImageStore` verir; testlərdə şəkil telefonda tapılmır və serverdən göstərilir.
final imageStoreProvider = Provider<ImageStore>((ref) => InMemoryImageStore());

final remoteDownloadSourceProvider = Provider<RemoteDownloadSource>(
  (ref) => SupabaseDownloadSource(ref.watch(supabaseClientProvider)),
);

final topicDownloaderProvider = Provider<TopicDownloader>(
  (ref) => TopicDownloader(
    remote: ref.watch(remoteDownloadSourceProvider),
    store: ref.watch(offlineStoreProvider),
    images: ref.watch(imageStoreProvider),
  ),
);

/// Serverin yükləmə kataloqu: fənnin mövzuları, ölçü və versiya.
final downloadCatalogProvider = FutureProvider.autoDispose
    .family<List<CatalogTopic>, int>(
      (ref, subjectId) =>
          ref.watch(remoteDownloadSourceProvider).fetchCatalog(subjectId),
    );

/// Telefona yüklənmiş mövzular (yükləmə irəlilədikcə özü yenilənir).
final storedTopicsProvider = StreamProvider.autoDispose
    .family<List<StoredTopic>, int>(
      (ref, subjectId) =>
          ref.watch(offlineStoreProvider).watchTopics(subjectId),
    );

/// Telefonda tam yüklənmiş mövzular, fənnə görə qruplaşıb ("Yüklədiyin suallar" bölməsi).
/// Fənn adı telefondakı fənn siyahısından götürülür (internet olmayanda da).
final downloadedSubjectsProvider = StreamProvider.autoDispose<List<DownloadedSubject>>((ref) {
  final store = ref.watch(offlineStoreProvider);
  return store.watchAllTopics().asyncMap((topics) async {
    final names = {for (final s in await store.cachedSubjects()) s.id: s};
    final bySubject = <int, List<StoredTopic>>{};
    for (final t in topics.where((t) => t.isComplete)) {
      bySubject.putIfAbsent(t.subjectId, () => []).add(t);
    }
    return [
      for (final e in bySubject.entries)
        DownloadedSubject(
          subject: names[e.key] ?? Subject(id: e.key, slug: '', name: '#${e.key}'),
          topics: e.value,
        ),
    ]..sort((a, b) => a.subject.id.compareTo(b.subject.id));
  });
});

/// Şəklin telefondakı faylı. Yoxdursa `null`: şəkil serverdən göstərilir.
final localImagePathProvider = FutureProvider.autoDispose
    .family<String?, String>(
      (ref, path) => ref.watch(imageStoreProvider).localPath(path),
    );
