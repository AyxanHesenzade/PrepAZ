/// Mövzu üzrə hələ göndərilməmiş cavablar. Telefonda qalır ki, şagird qaldığı yerdən davam etsin.
class TopicDraft {
  const TopicDraft({this.retake = false, this.answers = const {}});

  /// true = bitmiş mövzu yenidən işlənir, bütün testlər göstərilir.
  final bool retake;

  /// Sual id -> şagirdin cavabı.
  final Map<String, String> answers;
}

abstract interface class TopicDraftRepository {
  TopicDraft load(int topicId);

  Future<void> save(int topicId, TopicDraft draft);

  Future<void> clear(int topicId);
}
