import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/home/domain/progress_repository.dart';
import 'package:prep_az/features/home/domain/topic_mastery.dart';
import 'package:prep_az/features/quiz/domain/question.dart';
import 'package:prep_az/features/quiz/domain/question_image_repository.dart';
import 'package:prep_az/features/quiz/domain/quiz_repository.dart';

Question closedQuestion({
  String id = 'q1',
  String body = r'$\mathrm{H_{2}SO_{4}}$ turşusunun formulu',
  String correct = 'B',
  String? imagePath,
  String? solution = 'İzah mətni',
  String? solutionImagePath,
}) =>
    Question(
      id: id,
      code: 'KIM-$id',
      topicId: 1,
      type: QuestionType.qapali,
      body: body,
      imagePath: imagePath,
      options: const {'A': 'bir', 'B': 'iki', 'C': 'üç', 'D': 'dörd', 'E': 'beş'},
      correctAnswer: correct,
      difficulty: 3,
      solution: solution,
      solutionImagePath: solutionImagePath,
    );

Question numericQuestion({String id = 'n1', String correct = '9,2'}) => Question(
      id: id,
      code: 'KIM-$id',
      topicId: 1,
      type: QuestionType.aciqEded,
      body: 'Kütləni hesablayın',
      imagePath: null,
      options: const {},
      correctAnswer: correct,
      difficulty: 2,
      solution: null,
    );

/// Serverin yoxlamasını təqlid edir: düzgün cavab = `correctAnswer` (böyük/kiçik hərfə həssas deyil).
class FakeQuizRepository implements QuizRepository {
  FakeQuizRepository(this.questions);

  final List<Question> questions;
  final submitted = <({String questionId, String? given, int timeMs})>[];
  int sessionsStarted = 0;
  int sessionsFinished = 0;
  bool failSubmit = false;
  bool failLoad = false;
  bool failFinish = false;

  @override
  Future<List<Question>> getDailySet(int subjectId, {int limit = 20}) async {
    if (failLoad) throw const AppException(AppStrings.unknownError);
    return questions;
  }

  @override
  Future<String> startSession(int subjectId) async {
    sessionsStarted++;
    return 'session-1';
  }

  @override
  Future<void> finishSession(String sessionId) async {
    if (failFinish) throw const AppException(AppStrings.unknownError);
    sessionsFinished++;
  }

  @override
  Future<bool> submitAnswer({
    required String questionId,
    required String sessionId,
    required String? given,
    required int timeMs,
  }) async {
    if (failSubmit) throw const AppException(AppStrings.unknownError);
    submitted.add((questionId: questionId, given: given, timeMs: timeMs));
    final question = questions.firstWhere((q) => q.id == questionId);
    return given != null && given.toUpperCase() == question.correctAnswer.toUpperCase();
  }
}

class FakeImageRepository implements QuestionImageRepository {
  FakeImageRepository({this.fail = true});

  final bool fail;
  int calls = 0;

  @override
  Future<String> signedUrl(String path) async {
    calls++;
    if (fail) throw const AppException(AppStrings.imageFailed);
    return 'https://example.invalid/$path';
  }
}

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository([this.topics = const []]);

  final List<TopicMastery> topics;

  @override
  Future<List<TopicMastery>> getMastery(int subjectId) async => topics;
}
