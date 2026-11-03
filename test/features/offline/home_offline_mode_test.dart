import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/browse/domain/browse_repository.dart';
import 'package:prep_az/features/browse/domain/browse_topic.dart';
import 'package:prep_az/features/browse/presentation/browse_providers.dart';
import 'package:prep_az/features/goal/domain/exam_goal.dart';
import 'package:prep_az/features/goal/presentation/goal_providers.dart';
import 'package:prep_az/features/home/domain/profile_repository.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/subject_repository.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/home/presentation/home_screen.dart';
import 'package:prep_az/features/offline/data/drift_answer_outbox.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/data/offline_browse_repository.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/offline/presentation/downloaded_subjects_screen.dart';
import 'package:prep_az/features/offline/presentation/downloaded_topics_screen.dart';
import 'package:prep_az/features/offline/presentation/offline_providers.dart';
import 'package:prep_az/features/quiz/domain/question.dart';

import '../../support/fakes.dart';
import '../goal_test.dart';
import 'fakes.dart';

const _subjects = [
  Subject(id: 1, slug: 'kimya', name: 'Kimya'),
  Subject(id: 2, slug: 'biologiya', name: 'Biologiya'),
];

/// Serveri təqlid edir: [online] false olanda hər sorğu xəta verir.
class SwitchableServer implements SubjectRepository, ProfileRepository, BrowseRepository {
  bool online = true;

  void _check() {
    if (!online) throw const AppException('no internet');
  }

  @override
  Future<List<Subject>> getSubjects() async {
    _check();
    return _subjects;
  }

  @override
  Future<int> getStreakDays() async {
    _check();
    return 4;
  }

  @override
  Future<List<BrowseTopic>> getTopics(int subjectId) async {
    _check();
    return const [];
  }

  @override
  Future<List<Question>> getTopicQuestions(int topicId) async {
    _check();
    return const [];
  }

  @override
  Future<Map<String, bool>> getLatestAnswers(int topicId) async {
    _check();
    return const {};
  }
}

Question _closed(String id, int topic, {String? image}) => Question(
  id: id,
  code: 'C-$id',
  topicId: topic,
  type: QuestionType.qapali,
  body: 'Sual $id',
  imagePath: image,
  options: const {'A': 'a', 'B': 'b', 'C': 'c'},
  correctAnswer: 'B',
  difficulty: 1,
  solution: null,
);

const _atom = CatalogTopic(
  topicId: 7,
  topicName: 'Atom',
  sectionName: 'Quruluş',
  questionCount: 2,
  version: 1,
  imageCount: 0,
  imageBytes: 1024 * 1024,
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump();
  }
}

void main() {
  late LocalDatabase db;
  late SwitchableServer server;
  late FakeRemote downloads;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    server = SwitchableServer();
    downloads = FakeRemote();
  });
  tearDown(() => db.close());

  /// Tətbiqi (yenidən) açır. Baza eynidir, yəni telefon eynidir; internet [server.online]-dan asılıdır.
  Future<void> openApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox()); // əvvəlki açılışı bağla
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          localDatabaseProvider.overrideWithValue(db),
          remoteSubjectRepositoryProvider.overrideWithValue(server),
          profileRepositoryProvider.overrideWithValue(server),
          browseRepositoryProvider.overrideWithValue(
            OfflineBrowseRepository(remote: server, store: DriftOfflineStore(db), outbox: DriftAnswerOutbox(db)),
          ),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          goalRepositoryProvider.overrideWithValue(FakeGoalRepository(goal: const UserGoal(periodId: 1))),
          remoteDownloadSourceProvider.overrideWithValue(downloads),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await _settle(tester);
  }

  Future<void> useOnceOnline(WidgetTester tester) async {
    await openApp(tester);
    expect(find.text('Kimya'), findsWidgets);
  }

  Future<void> downloadAtom() =>
      DriftOfflineStore(db).saveTopic(subjectId: 1, topic: _atom, questions: [_closed('a', 7), _closed('b', 7)]);

  testWidgets('online: no offline banner', (tester) async {
    await openApp(tester);

    expect(find.text(AppStrings.homeOfflineTitle), findsNothing);
    expect(find.text('Kimya'), findsWidgets);
  });

  testWidgets('without internet: "Hazırda oflayn rejimdəsən" with the way to the downloaded questions, no error blocks', (tester) async {
    await useOnceOnline(tester); // fənlər telefona yazılır
    await tester.runAsync(downloadAtom);
    server.online = false;

    await openApp(tester);

    expect(find.text(AppStrings.homeOfflineTitle), findsOneWidget);
    expect(find.text(AppStrings.homeOfflineBodyWithDownloads), findsOneWidget);
    expect(find.text(AppStrings.homeOfflineGo), findsOneWidget);
    expect(find.text('Kimya'), findsNothing, reason: 'the subject cards are hidden: their buttons need internet');
    expect(find.text(AppStrings.startQuiz), findsNothing);
    expect(find.text(AppStrings.retry), findsNothing, reason: 'no "could not load" blocks');
  });

  testWidgets('without internet and nothing downloaded: only the explanation, no button', (tester) async {
    await useOnceOnline(tester);
    server.online = false;

    await openApp(tester);

    expect(find.text(AppStrings.homeOfflineTitle), findsOneWidget);
    expect(find.text(AppStrings.homeOfflineBodyEmpty), findsOneWidget);
    expect(find.text(AppStrings.homeOfflineGo), findsNothing);
  });

  testWidgets('the whole way offline: banner -> subject name -> topics -> the downloaded questions open', (tester) async {
    await useOnceOnline(tester);
    await tester.runAsync(downloadAtom);
    server.online = false;
    await openApp(tester);

    await tester.tap(find.text(AppStrings.homeOfflineGo));
    await tester.pumpAndSettle();

    expect(find.byType(DownloadedSubjectsScreen), findsOneWidget);
    expect(find.text('Kimya'), findsOneWidget, reason: 'the subject that has downloaded questions');
    expect(find.text('Biologiya'), findsNothing, reason: 'nothing was downloaded for it');
    expect(find.text(AppStrings.downloadedSubjectLine(1, '1.0 MB')), findsOneWidget);

    await tester.tap(find.text('Kimya'));
    await tester.pumpAndSettle();
    expect(find.byType(DownloadedTopicsScreen), findsOneWidget);
    expect(find.text('Atom'), findsOneWidget);

    await tester.tap(find.text('Atom'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.questionOf(1, 2)), findsOneWidget);
    expect(find.text('Sual a'), findsOneWidget);
  });

  testWidgets('a topic that is only partly downloaded is not offered', (tester) async {
    await useOnceOnline(tester);
    await tester.runAsync(
      () => DriftOfflineStore(db).saveTopic(
        subjectId: 1,
        topic: _atom,
        questions: [_closed('a', 7, image: 'missing.webp')],
      ),
    );
    server.online = false;

    await openApp(tester);

    expect(find.text(AppStrings.homeOfflineGo), findsNothing, reason: 'its images are not on the phone');
  });

  testWidgets('offline and the app never saw the subjects: the old error with a retry (nothing to show)', (tester) async {
    server.online = false;

    await openApp(tester);

    expect(find.text(AppStrings.retry), findsOneWidget);
    expect(find.text(AppStrings.homeOfflineTitle), findsNothing);
  });

  testWidgets('the internet comes back: "İnterneti yenidən yoxla" brings the subject cards back and the banner goes away', (tester) async {
    await useOnceOnline(tester);
    server.online = false;
    await openApp(tester);
    expect(find.text(AppStrings.homeOfflineTitle), findsOneWidget);
    expect(find.text('Kimya'), findsNothing);

    // düymə kartın ALTINDADIR
    final card = tester.getBottomLeft(find.text(AppStrings.homeOfflineBodyEmpty));
    final button = tester.getTopLeft(find.text(AppStrings.homeOfflineRetry));
    expect(button.dy, greaterThan(card.dy));

    // hələ də internet yoxdur: banner qalır və bunu deyir
    expect(find.text(AppStrings.homeOfflineStill), findsNothing);
    await tester.tap(find.text(AppStrings.homeOfflineRetry));
    await _settle(tester);
    expect(find.text(AppStrings.homeOfflineTitle), findsOneWidget);
    expect(find.text(AppStrings.homeOfflineStill), findsOneWidget);

    server.online = true;
    await tester.tap(find.text(AppStrings.homeOfflineRetry));
    await _settle(tester);

    expect(find.text(AppStrings.homeOfflineTitle), findsNothing);
    expect(find.text('Kimya'), findsWidgets);
  });

  testWidgets('the home list can always be pulled down, even when it is short (only the banner)', (tester) async {
    await useOnceOnline(tester);
    server.online = false;
    await openApp(tester);

    final list = tester.widget<ListView>(find.byType(ListView).first);

    expect(list.physics, isA<AlwaysScrollableScrollPhysics>());
  });
}
