import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

/// Telefona yüklənmiş sual (serverdəki `questions` sətrinin surəti, düz cavab daxil).
@TableIndex(name: 'local_questions_topic', columns: {#topicId})
class LocalQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().nullable()();
  IntColumn get topicId => integer()();
  TextColumn get type => text()();
  TextColumn get body => text()();
  TextColumn get imagePath => text().nullable()();

  /// `{"A": "...", "B": "..."}` JSON kimi (serverdəki jsonb ilə eyni).
  TextColumn get optionsJson => text()();
  TextColumn get correctAnswer => text()();
  IntColumn get difficulty => integer()();
  TextColumn get solution => text().nullable()();
  TextColumn get solutionImagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Yüklənmiş mövzu: ekranda "yükləndi / yenilənmə var" və ölçü bundan oxunur.
class DownloadedTopics extends Table {
  IntColumn get topicId => integer()();
  IntColumn get subjectId => integer()();
  TextColumn get topicName => text()();
  TextColumn get sectionName => text().nullable()();
  IntColumn get questionCount => integer()();

  /// Yükləmə anında serverdəki `get_download_catalog().version`. Fərqlidirsə, "yenilənmə var".
  IntColumn get version => integer()();
  IntColumn get imageCount => integer()();
  IntColumn get imageBytes => integer()();

  /// Endirilmiş şəkil sayı. `imagesDone == imageCount` olanda mövzu tam hazırdır.
  IntColumn get imagesDone => integer().withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {topicId};
}

/// Telefonda saxlanan şəkil faylı (yol bucket-dəki ad ilə eynidir).
class LocalImages extends Table {
  TextColumn get path => text()();
  IntColumn get bytes => integer()();

  @override
  Set<Column> get primaryKey => {path};
}

/// Göndərilməyi gözləyən cavab (oflayn verilib). `clientId` təkrar göndərməni təhlükəsiz edir
/// (serverdə `answers.client_id` unikaldır, eyni cavab ikinci dəfə yazılmır).
class PendingAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientId => text().unique()();
  TextColumn get questionId => text()();
  IntColumn get topicId => integer()();
  IntColumn get subjectId => integer()();
  TextColumn get givenAnswer => text().nullable()();

  /// Telefonda hesablanmış nəticə (nəticə ekranı üçün). Əsl qərarı server göndərəndə verir.
  BoolColumn get isCorrect => boolean()();
  IntColumn get timeMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get answeredAt => dateTime()();
}

/// Fənlər siyahısının surəti: internetsiz açılanda ana ekran fənn kartlarını göstərə bilsin.
class LocalSubjects extends Table {
  IntColumn get id => integer()();
  TextColumn get slug => text()();
  TextColumn get name => text()();

  /// Serverdəki sıra (siyahı eyni sıra ilə göstərilsin).
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Şagirdin son cavabı (server nəticəsi): internetsiz açılanda həll edilmiş testlər yenidən "həll edilməmiş" görünməsin.
class LocalLatestAnswers extends Table {
  TextColumn get questionId => text()();
  IntColumn get topicId => integer()();
  BoolColumn get isCorrect => boolean()();

  @override
  Set<Column> get primaryKey => {questionId};
}

@DriftDatabase(
  tables: [
    LocalQuestions,
    DownloadedTopics,
    LocalImages,
    PendingAnswers,
    LocalLatestAnswers,
    LocalSubjects,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.executor);

  /// Telefonda real fayl (`prepaz.sqlite`).
  LocalDatabase.open() : super(driftDatabase(name: 'prepaz'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Hər sxema dəyişikliyi burada addım-addım əlavə olunur (köhnə telefonlar pozulmasın).
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1-də cavab növbəsinə heç nə yazılmırdı (xüsusiyyət hələ buraxılmamışdı): boş cədvəl yenidən qurulur.
        await m.deleteTable('pending_answers');
        await m.createTable(pendingAnswers);
        await m.createTable(localLatestAnswers);
      }
      if (from < 3) await m.createTable(localSubjects);
    },
  );
}
