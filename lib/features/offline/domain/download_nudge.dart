import 'offline_models.dart';

/// Köməkçinin ana ekranda "mövzunu telefona yüklə" deməsi qaydası (sahibin qərarı, 2026-11-19):
/// telefona yüklənməmiş mövzu qaldıqca, ən çox [gap]-dan bir (defolt gündə bir), say limiti yoxdur.
/// Yüklənməmiş mövzu olub-olmadığı ayrıca ([firstMissingTopic]) yoxlanır: bu, serverə sorğudur,
/// ona görə əvvəl bu ucuz yoxlama işlənir.
bool isNudgeDue({
  required DateTime now,
  required DateTime? lastShown,
  Duration gap = const Duration(days: 1),
}) {
  if (lastShown == null) return true;
  return now.difference(lastShown) >= gap;
}

/// Kataloqda olub telefonda tam yüklənməmiş birinci mövzu (null = hamısı telefondadır).
CatalogTopic? firstMissingTopic(List<CatalogTopic> catalog, Iterable<StoredTopic> stored) {
  final complete = {for (final t in stored) if (t.isComplete) t.topicId};
  for (final topic in catalog) {
    if (!complete.contains(topic.topicId)) return topic;
  }
  return null;
}

/// Axşam bildirişində yükləmə təklifi hansı günlər olsun: hər gün yox, üç gündən bir
/// (yerli tarixə görə, eyni gün həmişə eyni cavab).
bool isDownloadReminderDay(DateTime now) {
  final day = DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return day % 3 == 0;
}
