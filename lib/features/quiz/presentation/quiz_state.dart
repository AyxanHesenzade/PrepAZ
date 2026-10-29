import '../domain/answer_result.dart';
import '../domain/question.dart';

/// Məşqin bütün vəziyyəti. Dəyişməzdir, hər dəyişiklik yeni obyekt qaytarır.
class QuizState {
  const QuizState._({
    required this.questions,
    required this.sessionId,
    required this.index,
    required this.selected,
    required this.input,
    required this.isSending,
    required this.error,
    required this.results,
    required this.isFinished,
  });

  factory QuizState.initial(List<Question> questions, String? sessionId) => QuizState._(
        questions: questions,
        sessionId: sessionId,
        index: 0,
        selected: null,
        input: '',
        isSending: false,
        error: null,
        results: const [],
        isFinished: false,
      );

  final List<Question> questions;
  final String? sessionId;
  final int index;

  /// Qapalı sual üçün seçilmiş hərf.
  final String? selected;

  /// Açıq sual üçün yazılmış cavab.
  final String input;
  final bool isSending;
  final String? error;
  final List<AnswerResult> results;
  final bool isFinished;

  bool get isEmpty => questions.isEmpty;
  Question get current => questions[index];
  bool get isLast => index + 1 >= questions.length;

  /// Cari sual artıq cavablandırılıb (nəticə serverdən gəlib).
  bool get isAnswered => results.length > index;
  AnswerResult? get currentResult => isAnswered ? results[index] : null;

  /// Göndəriləcək cavab; boşdursa null.
  String? get given {
    if (isEmpty) return null;
    if (current.isClosed) return selected;
    final text = input.trim();
    return text.isEmpty ? null : text;
  }

  bool get canSubmit => !isSending && !isAnswered && given != null;

  QuizState _copy({
    int? index,
    String? Function()? selected,
    String? input,
    bool? isSending,
    String? Function()? error,
    List<AnswerResult>? results,
    bool? isFinished,
  }) =>
      QuizState._(
        questions: questions,
        sessionId: sessionId,
        index: index ?? this.index,
        selected: selected != null ? selected() : this.selected,
        input: input ?? this.input,
        isSending: isSending ?? this.isSending,
        error: error != null ? error() : this.error,
        results: results ?? this.results,
        isFinished: isFinished ?? this.isFinished,
      );

  QuizState withSelected(String letter) => _copy(selected: () => letter);
  QuizState withInput(String text) => _copy(input: text);
  QuizState sending() => _copy(isSending: true, error: () => null);
  QuizState failed(String message) => _copy(isSending: false, error: () => message);
  QuizState answered(AnswerResult result) =>
      _copy(isSending: false, error: () => null, results: [...results, result]);
  QuizState advanced() => _copy(index: index + 1, selected: () => null, input: '', error: () => null);
  QuizState finished() => _copy(isFinished: true);
}
