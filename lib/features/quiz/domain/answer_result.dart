import 'question.dart';

/// Bir sualın nəticəsi (server cavabı yoxladıqdan sonra).
class AnswerResult {
  const AnswerResult({required this.question, required this.given, required this.isCorrect});

  final Question question;

  /// null = "Bilmirəm".
  final String? given;
  final bool isCorrect;
}
