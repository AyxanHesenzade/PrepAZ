import 'topic_mastery.dart';

abstract interface class ProgressRepository {
  /// Fənn üzrə cavab verilmiş mövzular, ən zəifi birinci.
  Future<List<TopicMastery>> getMastery(int subjectId);
}
