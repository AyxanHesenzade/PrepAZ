import 'reminder.dart';

abstract interface class StreakStatusRepository {
  Future<StreakStatus> getStatus();
}

/// Telefonda planlaşdırılan bildirişlər.
abstract interface class ReminderScheduler {
  /// false = bu mühitdə bildiriş yoxdur (testlər): heç nə hesablanmır.
  bool get isAvailable;

  /// Bir dəfə icazə istəyir (Android 13+). Sonrakı çağırışlarda pəncərə açılmır.
  Future<void> requestPermissionOnce();

  /// Köhnə xatırlatmaları silib bunları qoyur.
  Future<void> replaceAll(List<ScheduledReminder> reminders);

  Future<void> cancelAll();
}

class ScheduledReminder {
  const ScheduledReminder({
    required this.at,
    required this.title,
    required this.body,
  });

  final DateTime at;
  final String title;
  final String body;
}

/// Testlər və bildirişsiz mühit üçün.
class NoReminderScheduler implements ReminderScheduler {
  const NoReminderScheduler();

  @override
  bool get isAvailable => false;

  @override
  Future<void> requestPermissionOnce() async {}

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}
}
