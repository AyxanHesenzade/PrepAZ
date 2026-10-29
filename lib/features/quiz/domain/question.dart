enum QuestionType { qapali, aciqEded, yazili }

class Question {
  const Question({
    required this.id,
    required this.code,
    required this.topicId,
    required this.type,
    required this.body,
    required this.imagePath,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    required this.solution,
  });

  final String id;
  final String? code;
  final int topicId;
  final QuestionType type;

  /// Mətn və `$...$` arasında LaTeX düsturlar.
  final String body;

  /// `question-images` bucket-ində yol. Yoxdursa şəkil yoxdur.
  final String? imagePath;

  /// Qapalı sual üçün: {"A": "...", "B": "..."} hərf sırası ilə. Digər tiplərdə boşdur.
  final Map<String, String> options;
  final String correctAnswer;
  final int difficulty;
  final String? solution;

  bool get isClosed => type == QuestionType.qapali;
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasSolution => solution != null && solution!.isNotEmpty;
}
