import 'question.dart';

/// Cavabın düzgünlüyünü, təkrar növbəsini və seriyanı baza özü hesablayır.
/// Tətbiq yalnız sualları alır, cavabı göndərir və serverin qərarını göstərir.
abstract interface class QuizRepository {
  /// Bugünkü dəst: əvvəl vaxtı çatmış təkrarlar, sonra ən zəif mövzular.
  Future<List<Question>> getDailySet(int subjectId, {int limit = 20});

  Future<String> startSession(int subjectId);

  Future<void> finishSession(String sessionId);

  /// Cavabı göndərir, serverin qərarını (düz/səhv) qaytarır. [given] null = "Bilmirəm".
  Future<bool> submitAnswer({
    required String questionId,
    required String sessionId,
    required String? given,
    required int timeMs,
  });
}
