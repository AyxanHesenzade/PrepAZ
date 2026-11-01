import 'dart:math';

/// Mövzu üzrə nəticə: bütün aktiv testlərə görə. Hər test bir dəfə sayılır, son cavabı həlledicidir.
class TopicMastery {
  /// Bundan az test həll edilibsə, mövzu zəif sayılmır: nəticə çıxarmaq üçün azdır.
  static const minAnswers = 5;

  /// Mövzudakı bütün testlərin bu faizi düz olanda mövzu yaxşı bilinir.
  /// Həll edilənlərin bu faizindən az düz olanda isə zəifdir.
  static const strongPct = 70;

  const TopicMastery({
    required this.topicId,
    required this.topicName,
    required this.total,
    required this.answered,
    required this.correct,
  });

  final int topicId;
  final String topicName;

  /// Mövzudakı aktiv testlərin sayı.
  final int total;
  final int answered;
  final int correct;

  /// Mövzudakı bütün testlərə görə: 100 testdən 5-i düzdürsə, 5%.
  int get masteryPct => total == 0 ? 0 : (100 * correct / total).round();

  /// Yalnız həll edilən testlərə görə.
  int get accuracyPct => answered == 0 ? 0 : (100 * correct / answered).round();

  bool get isStrong => masteryPct >= strongPct;
  bool get isWeak => !isStrong && answered >= min(minAnswers, total) && accuracyPct < strongPct;
}
