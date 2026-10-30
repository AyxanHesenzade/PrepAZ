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
    this.solutionImagePath,
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

  /// Rəsmi izahın şəkli. Varsa, izah mətni əvəzinə göstərilir (kəsrlər və cədvəllər mətndə pozulur).
  final String? solutionImagePath;

  /// Eyni sual, şəkilsiz. Şəkil funksiyası söndürülən zaman istifadə olunur.
  Question withoutImages() => Question(
    id: id,
    code: code,
    topicId: topicId,
    type: type,
    body: body,
    imagePath: null,
    options: options,
    correctAnswer: correctAnswer,
    difficulty: difficulty,
    solution: solution,
  );

  /// Problem bildirmək üçün: insan oxuya bilən kod, yoxdursa UUID.
  String get reportCode => (code != null && code!.isNotEmpty) ? code! : id;

  bool get isClosed => type == QuestionType.qapali;

  /// Sual yalnız şəkildir (skan edilmiş kitab): mətn yoxdur, variantlar şəkildədir, ekranda yalnız A–E düymələri göstərilir.
  bool get isImageOnly => body.trim().isEmpty && hasImage;
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasSolutionText => solution != null && solution!.isNotEmpty;
  bool get hasSolutionImage =>
      solutionImagePath != null && solutionImagePath!.isNotEmpty;
  bool get hasSolution => hasSolutionImage || hasSolutionText;
}
