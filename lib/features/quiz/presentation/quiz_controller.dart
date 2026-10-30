import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../domain/answer_result.dart';
import '../domain/quiz_repository.dart';
import '../domain/quiz_request.dart';
import 'quiz_providers.dart';
import 'quiz_state.dart';

/// Bir məşq (bugünkü dəst, mövzu və ya səhvlər dəftəri). `build` sualları yükləyir və sessiya açır;
/// xəta olsa AsyncError olur, ekran "Yenidən cəhd et" göstərir.
class QuizController extends AsyncNotifier<QuizState> {
  QuizController(this.request);

  final QuizRequest request;
  DateTime _shownAt = DateTime.now();

  QuizRepository get _repo => ref.read(quizRepositoryProvider);
  QuizState get _current => state.requireValue;

  @override
  Future<QuizState> build() async {
    final loaded = switch (request.kind) {
      QuizKind.daily => await _repo.getDailySet(request.subjectId),
      QuizKind.topic => await _repo.getTopicSet(request.topicId!),
      QuizKind.mistakes => [for (final m in await _repo.getMistakes(request.subjectId)) m.question],
    };
    final showImages = ref.read(imagesEnabledProvider);
    final questions = showImages ? loaded : [for (final q in loaded) q.withoutImages()];
    final sessionId = questions.isEmpty ? null : await _repo.startSession(request.subjectId);
    _shownAt = DateTime.now();
    return QuizState.initial(questions, sessionId);
  }

  void select(String letter) {
    if (_current.isAnswered || _current.isSending) return;
    state = AsyncData(_current.withSelected(letter));
  }

  void type(String text) {
    if (_current.isAnswered || _current.isSending) return;
    state = AsyncData(_current.withInput(text));
  }

  /// [skip] = "Bilmirəm": cavab null göndərilir və səhv sayılır.
  Future<void> check({bool skip = false}) async {
    final s = _current;
    if (s.isSending || s.isAnswered || (!skip && s.given == null)) return;
    final given = skip ? null : s.given;
    state = AsyncData(s.sending());
    try {
      final isCorrect = await _repo.submitAnswer(
        questionId: s.current.id,
        sessionId: s.sessionId!,
        given: given,
        timeMs: DateTime.now().difference(_shownAt).inMilliseconds,
      );
      state = AsyncData(s.answered(AnswerResult(question: s.current, given: given, isCorrect: isCorrect)));
    } on AppException catch (e) {
      state = AsyncData(s.failed(e.message));
    }
  }

  Future<void> next() async {
    final s = _current;
    if (!s.isAnswered) return;
    if (!s.isLast) {
      _shownAt = DateTime.now();
      state = AsyncData(s.advanced());
      return;
    }
    try {
      await _repo.finishSession(s.sessionId!);
    } on AppException {
      // sessiyanın bağlanmaması nəticəni itirmir: cavablar artıq yazılıb
    }
    state = AsyncData(s.finished());
  }
}

final quizControllerProvider =
    AsyncNotifierProvider.autoDispose.family<QuizController, QuizState, QuizRequest>(QuizController.new);
