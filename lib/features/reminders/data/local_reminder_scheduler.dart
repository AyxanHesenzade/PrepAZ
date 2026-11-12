import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_repository.dart';

/// Android-in yerli bildirişləri (server, FCM lazım deyil; internetsiz də işləyir).
/// Dəqiq vaxt icazəsi istənmir: bildiriş 20:00 ətrafında bir neçə dəqiqə gec gələ bilər.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler(this._prefs, {required this.channelName});

  final SharedPreferences _prefs;

  /// Android ayarlarında görünən kanal adı (üç dildə).
  final String channelName;

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  static const _firstId = 100;
  static const _maxCount = 8;
  static const _askedKey = 'reminders.permission_asked';

  @override
  bool get isAvailable => true;

  Future<void> _init() => _ready ??= () async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Baku'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> requestPermissionOnce() async {
    if (_prefs.getBool(_askedKey) ?? false) return;
    await _init();
    await _prefs.setBool(_askedKey, true);
    await _android?.requestNotificationsPermission();
  }

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {
    await _init();
    await cancelAll();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    final now = DateTime.now();
    for (final (i, r) in reminders.take(_maxCount).indexed) {
      if (!r.at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: _firstId + i,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: r.title,
        body: r.body,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    for (var i = 0; i < _maxCount; i++) {
      await _plugin.cancel(id: _firstId + i);
    }
  }
}
