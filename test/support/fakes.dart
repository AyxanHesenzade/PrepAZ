import 'package:prep_az/features/browse/domain/browse_repository.dart';
import 'package:prep_az/features/browse/domain/browse_topic.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/home/domain/progress_repository.dart';
import 'package:prep_az/features/home/domain/topic_mastery.dart';
import 'package:prep_az/features/quiz/domain/mistake_item.dart';
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

/// Skan edilmiş kitabdan sual: mətn yoxdur, sual və variantlar şəkildədir, bazada variantlar yalnız hərfdir.
Question imageOnlyQuestion({String id = 'i1', String correct = 'B'}) => Question(
      id: id,
      code: 'KT1-S01-$id',
      topicId: 1,
      type: QuestionType.qapali,
      body: '',
      imagePath: 'KT1-S01-$id.png',
      options: const {'A': 'A', 'B': 'B', 'C': 'C', 'D': 'D', 'E': 'E'},
      correctAnswer: correct,
      difficulty: 3,
      solution: null,
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

Question multiChoiceQuestion({String id = 'm1', String correct = '135'}) => Question(
      id: id,
      code: 'KT1-S03-$id',
      topicId: 1,
      type: QuestionType.coxluSecim,
      body: 'Hansılar doğrudur?',
      imagePath: null,
      options: const {},
      correctAnswer: correct,
      difficulty: 3,
      solution: null,
    );

Question matchingQuestion({String id = 'u1', String correct = 'E;A;BC'}) => Question(
      id: id,
      code: 'KT1-S01-$id',
      topicId: 1,
      type: QuestionType.uygunlasdirma,
      body: 'Uyğunluğu müəyyən edin',
      imagePath: null,
      options: const {'1': 'ABCDE', '2': 'ABCDE', '3': 'ABCDE'},
      correctAnswer: correct,
      difficulty: 3,
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
    if (failLoad) throw AppException(AppStrings.unknownError);
    return questions;
  }

  /// Mövzu üzrə sorğuda yalnız həmin mövzunun sualları qayıdır.
  @override
  Future<List<Question>> getTopicSet(int topicId, {int limit = 10}) async {
    if (failLoad) throw AppException(AppStrings.unknownError);
    return questions.where((q) => q.topicId == topicId).take(limit).toList();
  }

  List<MistakeItem> mistakes = const [];

  @override
  Future<List<MistakeItem>> getMistakes(int subjectId) async {
    if (failLoad) throw AppException(AppStrings.unknownError);
    return mistakes;
  }

  @override
  Future<String> startSession(int subjectId) async {
    sessionsStarted++;
    return 'session-1';
  }

  @override
  Future<void> finishSession(String sessionId) async {
    if (failFinish) throw AppException(AppStrings.unknownError);
    sessionsFinished++;
  }

  @override
  Future<bool> submitAnswer({
    required String questionId,
    required String sessionId,
    required String? given,
    required int timeMs,
  }) async {
    if (failSubmit) throw AppException(AppStrings.unknownError);
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
    if (fail) throw AppException(AppStrings.imageFailed);
    return 'https://example.invalid/$path';
  }
}

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository([this.topics = const []]);

  final List<TopicMastery> topics;

  @override
  Future<List<TopicMastery>> getMastery(int subjectId) async => topics;
}

class FakeBrowseRepository implements BrowseRepository {
  FakeBrowseRepository(this.questions, {this.latest = const {}});

  final List<Question> questions;
  Map<String, bool> latest;

  @override
  Future<List<BrowseTopic>> getTopics(int subjectId) async =>
      [BrowseTopic(id: 1, name: 'Əsas anlayışlar', questionCount: questions.length)];

  @override
  Future<List<Question>> getTopicQuestions(int topicId) async => questions;

  @override
  Future<Map<String, bool>> getLatestAnswers(int topicId) async => latest;
}
