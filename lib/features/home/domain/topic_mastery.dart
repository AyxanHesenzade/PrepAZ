/// Mövzu üzrə son 30 cavabın düz faizi. Serverdə hesablanır.
class TopicMastery {
  const TopicMastery({
    required this.topicId,
    required this.topicName,
    required this.answered,
    required this.masteryPct,
  });

  final int topicId;
  final String topicName;
  final int answered;
  final int masteryPct;
}
