import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../home/presentation/home_providers.dart';
import '../../quiz/domain/answer_result.dart';
import '../../quiz/domain/question.dart';
import '../../quiz/domain/quiz_repository.dart';
import '../../quiz/presentation/quiz_providers.dart';
import '../domain/topic_draft.dart';
import 'browse_providers.dart';
import 'topic_exam_state.dart';

typedef TopicExamKey = ({int subjectId, int topicId});

/// Cavablar əvvəl telefonda toplanır, "Bitir" basılanda bazaya gedir.
/// Göndərilə bilməyənlər qaralamada qalır, yenidən basanda yalnız onlar gedir.
class TopicExamController extends AsyncNotifier<TopicExamState> {
  TopicExamController(this.key);

  /// Eyni anda göndərilən cavab sayı: 100 test bir-bir getsə, çox gözlədir.
  static const _batch = 5;

  final TopicExamKey key;
  String? _sessionId;

  QuizRepository get _quiz => ref.read(quizRepositoryProvider);
  TopicDraftRepository get _drafts => ref.read(topicDraftRepositoryProvider);
  TopicExamState get _current => state.requireValue;

  @override
  Future<TopicExamState> build() async {
    final browse = ref.read(browseRepositoryProvider);
    final all = await browse.getTopicQuestions(key.topicId);
    final latest = await browse.getLatestAnswers(key.topicId);
    final draft = _drafts.load(key.topicId);
    final questions = draft.retake
        ? all
        : all.where((q) => !latest.containsKey(q.id)).toList();
    final given = {
      for (final q in questions)
        if (draft.answers[q.id] != null) q.id: draft.answers[q.id]!,
    };
    final firstOpen = questions.indexWhere((q) => !given.containsKey(q.id));
    return TopicExamState(
      all: all,
      questions: questions,
      latest: latest,
      given: given,
      retake: draft.retake,
      index: firstOpen < 0 ? 0 : firstOpen,
    );
  }

  void answer(String text) {
    final s = _current;
    if (s.isSending) return;
    final given = {...s.given};
    if (text.trim().isEmpty) {
      given.remove(s.current.id);
    } else {
      given[s.current.id] = text;
    }
    state = AsyncData(s.copyWith(given: given));
    _saveDraft(s.retake, given);
  }

  void go(int index) {
    final s = _current;
    state = AsyncData(s.copyWith(index: index.clamp(0, s.questions.length - 1)));
  }

  /// Sonuncu testdən sonra cavabsız buraxılanlara qayıdır.
  void next() {
    final s = _current;
    if (!s.isLast) return go(s.index + 1);
    final open = s.unanswered;
    if (open.isNotEmpty) go(s.questions.indexOf(open.first));
  }

  /// Bitmiş mövzunu yenidən işləmək.
  void restart() {
    final s = _current;
    state = AsyncData(s.copyWith(questions: s.all, retake: true, given: const {}, index: 0));
    _saveDraft(true, const {});
  }

  Future<void> finish() async {
    final s = _current;
    if (s.isSending || s.given.isEmpty) return;
    state = AsyncData(s.copyWith(isSending: true));
    final results = {...s.results};
    final waiting = [
      for (final q in s.questions)
        if (s.given.containsKey(q.id) && !results.containsKey(q.id)) q,
    ];
    try {
      _sessionId ??= await _quiz.startSession(key.subjectId);
      for (var i = 0; i < waiting.length; i += _batch) {
        final batch = waiting.skip(i).take(_batch);
        final sent = await Future.wait(batch.map((q) => _send(q, s.given[q.id]!)));
        for (final result in sent.nonNulls) {
          results[result.question.id] = result;
        }
        final left = {...s.given}..removeWhere((id, _) => results.containsKey(id));
        _saveDraft(s.retake, left);
        if (sent.contains(null)) throw const AppException('');
      }
    } on AppException catch (e) {
      state = AsyncData(_current.copyWith(results: results, isSending: false, error: e.message));
      return;
    }
    try {
      await _quiz.finishSession(_sessionId!);
    } on AppException {
      // sessiyanın bağlanmaması nəticəni itirmir: cavablar artıq yazılıb
    }
    await _clearDraft();
    ref.invalidate(masteryProvider(key.subjectId));
    state = AsyncData(_current.copyWith(results: results, isSending: false, finished: true));
  }

  /// Nəticə ekranından növbəti testlərə keçid.
  void continueSolving() => ref.invalidateSelf();

  Future<AnswerResult?> _send(Question q, String given) async {
    try {
      final isCorrect = await _quiz.submitAnswer(
        questionId: q.id,
        sessionId: _sessionId!,
        given: given,
        timeMs: 0,
      );
      return AnswerResult(question: q, given: given, isCorrect: isCorrect);
    } on AppException {
      return null;
    }
  }

  Future<void> _saveDraft(bool retake, Map<String, String> answers) async {
    try {
      await _drafts.save(key.topicId, TopicDraft(retake: retake, answers: answers));
    } on AppException {
      // yazılmasa da cavablar bu sessiyada ekrandadır
    }
  }

  Future<void> _clearDraft() async {
    try {
      await _drafts.clear(key.topicId);
    } on AppException {
      // növbəti açılışda köhnə cavablar artıq həll edilmiş testlərlə süzülür
    }
  }
}

final topicExamControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TopicExamController, TopicExamState, TopicExamKey>(TopicExamController.new);
