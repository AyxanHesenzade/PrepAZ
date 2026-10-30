import '../../quiz/domain/question.dart';
import 'browse_topic.dart';

/// Mövzulara görə gəzmək: cavablar yazılmır, təkrar növbəsinə və faizə təsir etmir.
abstract interface class BrowseRepository {
  /// Fənnin sualı olan mövzuları.
  Future<List<BrowseTopic>> getTopics(int subjectId);

  /// Mövzunun bütün aktiv sualları kod sırası ilə (kitabdakı nömrə sırası).
  Future<List<Question>> getTopicQuestions(int topicId);
}
