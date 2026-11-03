import '../../../core/error/app_exception.dart';
import '../../browse/domain/browse_repository.dart';
import '../../browse/domain/browse_topic.dart';
import '../../quiz/domain/question.dart';
import '../domain/answer_outbox.dart';
import '../domain/offline_store.dart';

/// Mövzular bölməsi: yüklənmiş mövzunu telefondan oxuyur, qalanını serverdən ([remote]).
///
/// - Tam yüklənmiş mövzunun sualları HƏMİŞƏ telefondan gəlir (internet olsa belə): sürətlidir, trafik getmir.
///   Yenilənmə şagird "Yenilə" basanda olur.
/// - İnternet yoxdursa, mövzu siyahısı yüklənmiş mövzulardan qurulur.
/// - Şagirdin əvvəlki cavabları serverdədir; yüklənmiş mövzuda telefonda keşlənir. Hələ göndərilməmiş oflayn cavablar
///   (`outbox`) üstünə qoyulur: həll edilmiş test yenidən "həll edilməmiş" görünməsin.
class OfflineBrowseRepository implements BrowseRepository {
  const OfflineBrowseRepository({
    required this.remote,
    required this.store,
    required this.outbox,
  });

  final BrowseRepository remote;
  final OfflineStore store;
  final AnswerOutbox outbox;

  @override
  Future<List<BrowseTopic>> getTopics(int subjectId) async {
    try {
      return await remote.getTopics(subjectId);
    } on AppException {
      final downloaded = (await store.watchTopics(
        subjectId,
      ).first).where((t) => t.isComplete);
      if (downloaded.isEmpty) rethrow;
      return [
        for (final t in downloaded)
          BrowseTopic(
            id: t.topicId,
            name: t.topicName,
            questionCount: t.questionCount,
          ),
      ];
    }
  }

  @override
  Future<List<Question>> getTopicQuestions(int topicId) async {
    final stored = await store.getTopic(topicId);
    if (stored != null && stored.isComplete) {
      return store.questionsOf(topicId);
    }
    return remote.getTopicQuestions(topicId);
  }

  @override
  Future<Map<String, bool>> getLatestAnswers(int topicId) async {
    final stored = await store.getTopic(topicId);
    final downloaded = stored != null && stored.isComplete;
    Map<String, bool> latest;
    try {
      latest = {...await remote.getLatestAnswers(topicId)};
      if (downloaded) await store.cacheLatest(topicId, latest);
    } on AppException {
      if (!downloaded) rethrow;
      latest = {...await store.cachedLatest(topicId)};
    }
    if (downloaded) {
      // Ən köhnədən yenisinə: eyni sual iki dəfə cavablanıbsa, sonuncu qalır.
      for (final entry in await outbox.forTopic(topicId)) {
        latest[entry.questionId] = entry.isCorrect;
      }
    }
    return latest;
  }
}
