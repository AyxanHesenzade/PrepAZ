import '../../quiz/domain/answer_result.dart';
import '../../quiz/domain/question.dart';

/// Mövzunun işlənməsi. Düz/səhv yalnız [finished] olanda ekrana çıxır.
class TopicExamState {
  const TopicExamState({
    required this.all,
    required this.questions,
    required this.latest,
    this.index = 0,
    this.given = const {},
    this.retake = false,
    this.results = const {},
    this.isSending = false,
    this.finished = false,
    this.error,
  });

  /// Mövzunun bütün testləri (nömrə buradan gəlir).
  final List<Question> all;

  /// Bu dəfə işlənən testlər: hələ həll edilməyənlər və ya yenidən işləyəndə hamısı.
  final List<Question> questions;

  /// Bitirməzdən əvvəlki vəziyyət: sual id -> son cavab düzdürmü.
  final Map<String, bool> latest;
  final int index;
  final Map<String, String> given;
  final bool retake;
  final Map<String, AnswerResult> results;
  final bool isSending;
  final bool finished;
  final String? error;

  /// Mövzudakı bütün testlər həll edilib.
  bool get isCompleted => questions.isEmpty;

  Question get current => questions[index];
  bool get isLast => index == questions.length - 1;
  int numberOf(Question q) => all.indexOf(q) + 1;

  List<Question> get unanswered => [
    for (final q in questions)
      if (!given.containsKey(q.id)) q,
  ];

  int get correctBefore => all.where((q) => latest[q.id] == true).length;
  int get correctAfter =>
      all.where((q) => results[q.id]?.isCorrect ?? latest[q.id] == true).length;

  List<AnswerResult> get orderedResults => [
    for (final q in questions)
      if (results[q.id] != null) results[q.id]!,
  ];

  TopicExamState copyWith({
    int? index,
    Map<String, String>? given,
    bool? retake,
    List<Question>? questions,
    Map<String, AnswerResult>? results,
    bool? isSending,
    bool? finished,
    String? error,
  }) => TopicExamState(
    all: all,
    latest: latest,
    questions: questions ?? this.questions,
    index: index ?? this.index,
    given: given ?? this.given,
    retake: retake ?? this.retake,
    results: results ?? this.results,
    isSending: isSending ?? this.isSending,
    finished: finished ?? this.finished,
    error: error,
  );
}
