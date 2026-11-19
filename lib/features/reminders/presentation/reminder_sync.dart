import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../home/presentation/home_providers.dart';
import '../../offline/domain/download_nudge.dart';
import '../../offline/presentation/offline_providers.dart';
import '../../tour/presentation/tour_controller.dart';
import '../domain/reminder.dart';
import '../domain/reminder_repository.dart';
import 'reminder_providers.dart';

/// Axşam (20:00) seriya xatırlatmasını telefonda planlaşdırır.
/// Tetiklər: açılış, arxa fondan qayıtmaq, seriya yenilənəndə (məşqdən sonra).
/// İcazə öyrədici tur bitəndən sonra bir dəfə istənir. Xəta olsa heç nə göstərilmir.
class ReminderSync extends ConsumerStatefulWidget {
  const ReminderSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  late final AppLifecycleListener _lifecycle;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final scheduler = ref.read(reminderSchedulerProvider);
    if (!scheduler.isAvailable || _running || !mounted) return;
    _running = true;
    try {
      if (ref.read(tourControllerProvider) == null) {
        await scheduler.requestPermissionOnce();
      }
      final status = await ref.read(streakStatusRepositoryProvider).getStatus();
      final now = DateTime.now();
      // kataloq sorğusu yalnız lazım olan axşam (bu bildirişin günü) edilir
      final missing = isDownloadReminderDay(now) && await _hasMissingTopics();
      final plans = planReminders(now: now, status: status, hasMissingTopics: missing);
      await scheduler.replaceAll([for (final p in plans) toScheduled(p)]);
    } catch (_) {
      // xatırlatma köməkçi funksiyadır: internet yoxdursa köhnə plan qalır
    } finally {
      _running = false;
    }
  }

  /// Hər hansı fəndə telefona tam yüklənməmiş mövzu qalıbmı (köməkçinin sözü ilə eyni qayda)?
  /// Oxunmasa "yox" sayılır (artıq bildiriş göndərmirik).
  Future<bool> _hasMissingTopics() async {
    try {
      final subjects = await ref.read(subjectsProvider.future);
      final stored = await ref.read(offlineStoreProvider).watchAllTopics().first;
      final remote = ref.read(remoteDownloadSourceProvider);
      for (final subject in subjects) {
        try {
          if (firstMissingTopic(await remote.fetchCatalog(subject.id), stored) != null) return true;
        } catch (_) {
          // bu fənnin kataloqu alınmadı: növbətisinə baxırıq
        }
      }
    } catch (_) {
      // fənlər və ya telefondakı baza oxunmadı
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // məşqdən sonra ana səhifə seriyanı yeniləyir: plan da yenilənsin
    ref.listen(streakDaysProvider, (_, next) {
      if (next.hasValue) _sync();
    });
    // tur bitəndə icazə istənsin
    ref.listen(tourControllerProvider, (prev, next) {
      if (prev != null && next == null) _sync();
    });
    return widget.child;
  }
}

/// Plan → bildiriş mətni (cari interfeys dilində). Variant günə görə dəyişir.
ScheduledReminder toScheduled(ReminderPlan p) {
  final (title, bodies) = switch (p.kind) {
    ReminderKind.atRisk => (
      AppStrings.reminderTitleStreak(p.streak),
      AppStrings.reminderAtRisk(p.streak),
    ),
    ReminderKind.keepGoing => (
      AppStrings.reminderTitleStreak(p.streak),
      AppStrings.reminderKeepGoing(p.streak),
    ),
    ReminderKind.start => (
      AppStrings.reminderTitleStart,
      AppStrings.reminderStart,
    ),
    ReminderKind.comeBack => (
      AppStrings.reminderTitleComeBack,
      AppStrings.reminderComeBack,
    ),
    ReminderKind.download => (
      AppStrings.reminderTitleDownload,
      AppStrings.reminderDownload,
    ),
  };
  return ScheduledReminder(
    at: p.at,
    title: title,
    body: bodies[p.at.day % bodies.length],
  );
}
