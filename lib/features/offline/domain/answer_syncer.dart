import '../../../core/error/app_exception.dart';
import '../../quiz/domain/quiz_repository.dart';
import 'answer_outbox.dart';
import 'offline_store.dart';

/// Növbədəki cavabları serverə göndərir. İnternet yoxdursa, birinci xətada dayanır və növbə olduğu kimi qalır.
///
/// Cavab silinmir (sual bazadan silinmir, `is_active=false` olur), ona görə "zəhərli" cavab ehtimalı yoxdur:
/// xəta həmişə "internet yoxdur / server cavab vermir" deməkdir, sonra təkrar cəhd olunur.
class AnswerSyncer {
  AnswerSyncer({
    required this.outbox,
    required this.quiz,
    required this.store,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AnswerOutbox outbox;
  final QuizRepository quiz;
  final OfflineStore store;
  final DateTime Function() _now;

  bool _running = false;

  /// Göndərilən cavabların sayı. Eyni anda ikinci çağırış heç nə etmir (0).
  Future<int> flush() async {
    if (_running) return 0;
    _running = true;
    var sent = 0;
    try {
      for (final entry in await outbox.all()) {
        final bool serverSaysCorrect;
        try {
          final now = _now();
          serverSaysCorrect = await quiz.submitAnswer(
            questionId: entry.questionId,
            sessionId: null,
            given: entry.given,
            timeMs: entry.timeMs,
            clientId: entry.clientId,
            // Telefonun saatı qabağa getsə, "son cavab" sırası pozulmasın.
            answeredAt: entry.answeredAt.isAfter(now) ? now : entry.answeredAt,
          );
        } on AppException {
          break;
        }
        await store.putCachedLatest(
          entry.topicId,
          entry.questionId,
          serverSaysCorrect,
        );
        await outbox.remove(entry.clientId);
        sent++;
      }
    } finally {
      _running = false;
    }
    return sent;
  }
}
