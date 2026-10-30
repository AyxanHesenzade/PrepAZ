/// Məşq hansı suallardan qurulur.
enum QuizKind {
  /// Bugünkü dəst: vaxtı çatmış təkrarlar + zəif mövzular.
  daily,

  /// Bir mövzu üzrə.
  topic,

  /// Səhvlər dəftərindəki suallar.
  mistakes,
}

/// Məşq ekranının və controller-in açarı (dəyər müqayisəsi var, `family` üçün vacibdir).
class QuizRequest {
  const QuizRequest.daily(this.subjectId)
      : kind = QuizKind.daily,
        topicId = null;

  const QuizRequest.topic(this.subjectId, int this.topicId) : kind = QuizKind.topic;

  const QuizRequest.mistakes(this.subjectId)
      : kind = QuizKind.mistakes,
        topicId = null;

  final int subjectId;
  final QuizKind kind;
  final int? topicId;

  @override
  bool operator ==(Object other) =>
      other is QuizRequest && other.subjectId == subjectId && other.kind == kind && other.topicId == topicId;

  @override
  int get hashCode => Object.hash(subjectId, kind, topicId);
}
