import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/reminders/domain/reminder.dart';
import 'package:prep_az/features/reminders/presentation/reminder_sync.dart';

void main() {
  // 12 noyabr, 15:00 (telefonun vaxtı)
  final now = DateTime(2026, 11, 12, 15);
  final today = DateTime.utc(2026, 11, 12);
  final yesterday = DateTime.utc(2026, 11, 11);

  StreakStatus status({int streak = 0, DateTime? last, int today = 0}) =>
      StreakStatus(streakDays: streak, lastActive: last, answeredToday: today);

  test('streak alive, not practised today: tonight at risk, then come back', () {
    final plans = planReminders(now: now, status: status(streak: 6, last: yesterday));
    expect(plans, [
      ReminderPlan(at: DateTime(2026, 11, 12, 20), kind: ReminderKind.atRisk, streak: 6),
      ReminderPlan(at: DateTime(2026, 11, 13, 20), kind: ReminderKind.comeBack),
      ReminderPlan(at: DateTime(2026, 11, 14, 20), kind: ReminderKind.comeBack),
      ReminderPlan(at: DateTime(2026, 11, 15, 20), kind: ReminderKind.comeBack),
    ]);
  });

  test('practised today: nothing tonight, tomorrow keep going', () {
    final plans = planReminders(now: now, status: status(streak: 7, last: today, today: 12));
    expect(plans.first, ReminderPlan(at: DateTime(2026, 11, 13, 20), kind: ReminderKind.keepGoing, streak: 7));
    expect(plans, hasLength(3));
  });

  test('broken streak is not shown as alive', () {
    final old = DateTime.utc(2026, 11, 5);
    expect(currentStreak(now: now, status: status(streak: 9, last: old)), 0);
    final plans = planReminders(now: now, status: status(streak: 9, last: old));
    expect(plans.first.kind, ReminderKind.start);
  });

  test('after 20:00 nothing is scheduled for tonight', () {
    final late = DateTime(2026, 11, 12, 21);
    final plans = planReminders(now: late, status: status(streak: 3, last: yesterday));
    expect(plans.first.at, DateTime(2026, 11, 13, 20));
  });

  test('end of month rolls over', () {
    final plans = planReminders(now: DateTime(2026, 11, 30, 22), status: status());
    expect(plans.first.at, DateTime(2026, 12, 1, 20));
  });

  test('texts carry the streak number', () {
    final r = toScheduled(ReminderPlan(at: DateTime(2026, 11, 12, 20), kind: ReminderKind.atRisk, streak: 6));
    expect(r.title, AppStrings.reminderTitleStreak(6));
    expect(AppStrings.reminderAtRisk(6), contains(r.body));
  });
}
