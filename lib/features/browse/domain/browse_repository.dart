import '../../quiz/domain/question.dart';
import 'browse_topic.dart';

/// Mövzular bölməsi: mövzuların və suallarının siyahısı.
abstract interface class BrowseRepository {
  /// Fənnin sualı olan mövzuları.
  Future<List<BrowseTopic>> getTopics(int subjectId);

  /// Mövzunun bütün aktiv sualları kod sırası ilə (kitabdakı nömrə sırası).
  Future<List<Question>> getTopicQuestions(int topicId);

  /// Şagirdin mövzu üzrə cavabları: sual id -> son cavab düzdürmü.
  Future<Map<String, bool>> getLatestAnswers(int topicId);
}
