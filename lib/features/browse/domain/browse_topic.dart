/// Fənnin mövzusu və içindəki aktiv sualların sayı.
class BrowseTopic {
  const BrowseTopic({
    required this.id,
    required this.name,
    required this.questionCount,
  });

  final int id;
  final String name;
  final int questionCount;
}
