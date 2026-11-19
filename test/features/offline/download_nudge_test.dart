import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/offline/domain/download_nudge.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/reminders/domain/reminder.dart';

StoredTopic _stored(int id, {bool done = true}) => StoredTopic(
  topicId: id,
  subjectId: 1,
  topicName: 'T$id',
  questionCount: 1,
  version: 1,
  imageCount: 2,
  imageBytes: 0,
  imagesDone: done ? 2 : 1,
  downloadedAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 11, 19, 15);

  group('mascot nudge', () {
    test('never shown before: due', () {
      expect(isNudgeDue(now: now, lastShown: null), isTrue);
    });

    test('at most once a day, no limit on how many times', () {
      expect(isNudgeDue(now: now, lastShown: now.subtract(const Duration(hours: 20))), isFalse);
      expect(isNudgeDue(now: now, lastShown: now.subtract(const Duration(days: 1))), isTrue);
    });

    CatalogTopic topic(int id) => CatalogTopic(
      topicId: id,
      topicName: 'T$id',
      sectionName: 'S',
      questionCount: 1,
      version: 1,
      imageCount: 0,
      imageBytes: 0,
    );

    test('finds the first topic that is not fully on the phone', () {
      final catalog = [topic(1), topic(2), topic(3)];
      expect(firstMissingTopic(catalog, const [])?.topicId, 1);
      expect(firstMissingTopic(catalog, [_stored(1), _stored(2)])?.topicId, 3);
      expect(firstMissingTopic(catalog, [_stored(1), _stored(2, done: false), _stored(3)])?.topicId, 2,
          reason: 'a half-downloaded topic still counts as missing');
      expect(firstMissingTopic(catalog, [_stored(1), _stored(2), _stored(3)]), isNull);
    });
  });

  test('download reminder day is every third day', () {
    final days = [for (var d = 0; d < 9; d++) DateTime(2026, 11, 10 + d, 15)];
    expect(days.where(isDownloadReminderDay), hasLength(3));
  });

  group('evening reminder', () {
    StreakStatus practised() =>
        StreakStatus(streakDays: 4, lastActive: DateTime.utc(2026, 11, 19), answeredToday: 5);
    final day = [for (var d = 0; d < 3; d++) DateTime(2026, 11, 19 + d, 15)].firstWhere(isDownloadReminderDay);
    final otherDay = day.add(const Duration(days: 1));

    test('practised today, a topic is missing on the phone, on its day: tonight a download reminder', () {
      final status = StreakStatus(streakDays: 4, lastActive: DateTime.utc(day.year, day.month, day.day), answeredToday: 5);
      final plans = planReminders(now: day, status: status, hasMissingTopics: true);
      expect(plans.first, ReminderPlan(at: DateTime(day.year, day.month, day.day, 20), kind: ReminderKind.download));
      expect(plans, hasLength(4));
    });

    test('not on other days, and never when every topic is on the phone', () {
      expect(planReminders(now: otherDay, status: practised(), hasMissingTopics: true).map((p) => p.kind),
          isNot(contains(ReminderKind.download)));
      expect(planReminders(now: day, status: practised(), hasMissingTopics: false).map((p) => p.kind),
          isNot(contains(ReminderKind.download)));
    });

    test('not practised today: the streak reminder stays, no download reminder', () {
      final status = StreakStatus(streakDays: 4, lastActive: DateTime.utc(day.year, day.month, day.day - 1), answeredToday: 0);
      final plans = planReminders(now: day, status: status, hasMissingTopics: true);
      expect(plans.first.kind, ReminderKind.atRisk);
      expect(plans.map((p) => p.kind), isNot(contains(ReminderKind.download)));
    });
  });
}
