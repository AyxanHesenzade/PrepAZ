/// Göndərilməyi gözləyən cavab. [isCorrect] telefonda hesablanıb, əsl qərarı server göndərildikdə verir.
class OutboxEntry {
  const OutboxEntry({
    required this.clientId,
    required this.questionId,
    required this.topicId,
    required this.subjectId,
    required this.given,
    required this.isCorrect,
    required this.answeredAt,
    this.timeMs = 0,
  });

  /// Serverdə `answers.client_id`: eyni cavab ikinci dəfə göndərilsə, ikiqat yazılmır.
  final String clientId;
  final String questionId;
  final int topicId;
  final int subjectId;

  /// null = "Bilmirəm".
  final String? given;
  final bool isCorrect;
  final DateTime answeredAt;
  final int timeMs;
}

/// İnternetsiz verilən cavabların növbəsi: internet gələndə sırası ilə göndərilir.
abstract interface class AnswerOutbox {
  Future<void> add(OutboxEntry entry);

  /// Hamısı, ən köhnəsi birinci.
  Future<List<OutboxEntry>> all();

  /// Mövzunun gözləyən cavabları, ən köhnəsi birinci.
  Future<List<OutboxEntry>> forTopic(int topicId);

  Future<void> remove(String clientId);

  /// Gözləyən cavabların sayı (ekranda "N cavab göndərilməyi gözləyir").
  Stream<int> watchCount();
}
