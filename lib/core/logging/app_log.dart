import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'log_event.dart';

/// Tətbiqin hər yerindən çağırılan log girişi. `guard` da bunu işlədir, ona görə statikdir.
/// Testlərdə quraşdırılmır: bütün çağırışlar heç nə etmir. `main.dart` [EventLogger] quraşdırır.
abstract final class AppLog {
  static EventLogger? _logger;

  static void install(EventLogger logger) => _logger = logger;

  static void uninstall() => _logger = null;

  static bool get enabled => _logger != null;

  /// Giriş/qeydiyyat addımları (`sign_in_failed` və s.). [meta]-ya parol YAZILMIR.
  static void auth(String name, {String? message, Map<String, Object?>? meta}) =>
      _logger?.add(LogEvent(kind: LogKind.auth, name: name, message: message, meta: meta));

  static void info(String name, {String? message, Map<String, Object?>? meta}) =>
      _logger?.add(LogEvent(kind: LogKind.info, name: name, message: message, meta: meta));

  /// [origin]: xətanın baş verdiyi yerin (repository) stack-i, `guard` çağırılanda götürülür.
  static void error(Object error, {StackTrace? stack, StackTrace? origin}) =>
      _logger?.add(describeError(LogKind.error, error, stack: stack, origin: origin));

  static void crash(Object error, StackTrace? stack) =>
      _logger?.add(describeError(LogKind.crash, error, stack: stack), urgent: true);

  static Future<void> flush() => _logger?.flush() ?? Future.value();
}

/// Növbə: hadisələr telefonda saxlanır, bir neçə saniyədən bir partiya ilə göndərilir.
/// Göndərmə alınmasa (internet yox), növbədə qalır və növbəti dəfə yenidən cəhd edilir.
class EventLogger {
  EventLogger({
    required this.sink,
    required this.store,
    this.delay = const Duration(seconds: 5),
    this.kinds = defaultKinds,
  }) : _queue = store.load();

  /// Bazaya gedən növlər. Sahibin qərarı (2026-11-18): hamısı gedir, yer lazım olanda admin paneldən
  /// silinir ("Bütün logları sil"). Bir növü söndürmək üçün onu buradan çıxarmaq kifayətdir.
  static const defaultKinds = {LogKind.auth, LogKind.error, LogKind.crash, LogKind.info};

  final Set<LogKind> kinds;

  static const maxQueue = 200;
  static const batchSize = 50;

  final LogSink sink;
  final LogStore store;
  final List<LogEvent> _queue;

  /// null: avtomatik göndərmə yoxdur (testlər [flush]-u özü çağırır).
  final Duration? delay;
  Timer? _timer;
  Future<void>? _sending;

  List<LogEvent> get pending => List.unmodifiable(_queue);

  void add(LogEvent event, {bool urgent = false}) {
    if (!kinds.contains(event.kind)) return;
    _queue.add(event);
    if (_queue.length > maxQueue) _queue.removeRange(0, _queue.length - maxQueue);
    unawaited(store.save(_queue));
    if (urgent) {
      unawaited(flush());
    } else if (delay != null) {
      _timer ??= Timer(delay!, () => unawaited(flush()));
    }
  }

  /// Eyni anda yalnız bir göndərmə gedir.
  Future<void> flush() => _sending ??= _send().whenComplete(() => _sending = null);

  Future<void> _send() async {
    _timer?.cancel();
    _timer = null;
    while (_queue.isNotEmpty) {
      final batch = _queue.take(batchSize).toList();
      try {
        await sink.send(batch);
      } on Object {
        return; // növbədə qalır
      }
      _queue.removeRange(0, batch.length);
      await store.save(_queue);
    }
  }

  void dispose() => _timer?.cancel();
}

/// Xətanı admin üçün oxunaqlı hadisəyə çevirir: nə (tip + kod), harada (layihənin faylı:sətir).
LogEvent describeError(
  LogKind kind,
  Object error, {
  StackTrace? stack,
  StackTrace? origin,
}) {
  final meta = <String, Object?>{};
  String name;
  String message;
  switch (error) {
    case PostgrestException e:
      name = 'PostgrestException';
      message = e.message;
      meta['code'] = e.code;
      if (e.details != null) meta['details'] = '${e.details}';
    case AuthException e:
      name = 'AuthException';
      message = e.message;
      meta['code'] = e.code;
      meta['status'] = e.statusCode;
    case StorageException e:
      name = 'StorageException';
      message = e.message;
      meta['status'] = e.statusCode;
    case SocketException() || TimeoutException() || HttpException():
      name = 'network';
      message = '$error';
    default:
      name = error.runtimeType.toString();
      message = '$error';
  }
  final where = projectFrame(origin) ?? projectFrame(stack);
  if (where != null) meta['where'] = where;
  // çökmədə həmişə, adi xətada yalnız yer tapılmayanda (məs. release-də stack başqa formatdadır)
  final trace = kind == LogKind.crash ? stack : (where == null ? origin ?? stack : null);
  if (trace != null) {
    meta['stack'] = trace.toString().split('\n').take(12).join('\n');
  }
  meta.removeWhere((_, v) => v == null);
  return LogEvent(
    kind: kind,
    name: name,
    message: message.length > LogEvent.maxMessage
        ? message.substring(0, LogEvent.maxMessage)
        : message,
    meta: meta,
  );
}

/// Stack-dəki ilk layihə sətri, log və xəta köməkçiləri xaric:
/// `features/home/data/supabase_home_repository.dart:42 (SupabaseHomeRepository.subjects)`.
String? projectFrame(StackTrace? stack) {
  if (stack == null) return null;
  final frame = RegExp(r'^#\d+\s+(.+?) \(package:prep_az/(.+?):(\d+)(?::\d+)?\)$');
  for (final line in stack.toString().split('\n')) {
    final m = frame.firstMatch(line.trim());
    if (m == null) continue;
    final path = m.group(2)!;
    if (path.startsWith('core/error/') || path.startsWith('core/logging/')) continue;
    return '$path:${m.group(3)} (${m.group(1)})';
  }
  return null;
}
