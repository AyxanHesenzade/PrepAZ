import '../../home/domain/subject.dart';
import '../../quiz/domain/question.dart';
import 'offline_models.dart';

/// Telefondakı yüklənmiş məlumat (suallar, mövzular, şəkil qeydləri). Fayl özü [ImageStore]-dadır.
abstract interface class OfflineStore {
  /// Mövzunun suallarını yeniləri ilə əvəz edir və mövzunu "yüklənir" kimi qeyd edir.
  /// Əvvəl endirilmiş şəkillər sayılır, yenidən endirilmir.
  Future<void> saveTopic({
    required int subjectId,
    required CatalogTopic topic,
    required List<Question> questions,
  });

  Future<bool> hasImage(String path);

  /// Şəkil endirildi: qeyd olunur və mövzunun irəliləyişi yenilənir.
  Future<void> recordImage({
    required int topicId,
    required String path,
    required int bytes,
  });

  Future<StoredTopic?> getTopic(int topicId);

  /// Şagirdin mövzu üzrə son cavabları (sual id -> düzdürmü), internetsiz açılanda üçün keş.
  Future<Map<String, bool>> cachedLatest(int topicId);

  /// Serverdən gələn son cavabları keşə yazır (mövzunun köhnə keşini əvəz edir).
  Future<void> cacheLatest(int topicId, Map<String, bool> answers);

  /// Bir cavabın serverdəki nəticəsini keşə əlavə edir (göndərilmiş oflayn cavab).
  Future<void> putCachedLatest(int topicId, String questionId, bool isCorrect);

  /// Fənlər siyahısının telefondakı surəti (ana ekran internetsiz açılsın). Boşdursa, heç vaxt yüklənməyib.
  Future<List<Subject>> cachedSubjects();

  Future<void> cacheSubjects(List<Subject> subjects);

  /// Telefondakı sualları, kod sırası ilə (serverdəki sıra ilə eyni).
  Future<List<Question>> questionsOf(int topicId);

  Stream<List<StoredTopic>> watchTopics(int subjectId);

  /// Bütün fənlərin yüklənmiş mövzuları.
  Stream<List<StoredTopic>> watchAllTopics();

  /// Mövzunu və suallarını silir. Başqa mövzuda işlənməyən şəkil yollarını qaytarır (fayllar silinməlidir).
  Future<List<String>> deleteTopic(int topicId);
}
