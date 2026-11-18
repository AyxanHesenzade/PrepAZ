/// Admin paneldəki "Loglar" üçün bir hadisə. Serverdə `app_events` cədvəlinə düşür
/// (`db/migrations/019_app_events_admin_users.sql`). Parol və cavab mətni heç vaxt yazılmır.
enum LogKind { auth, error, crash, info }

class LogEvent {
  LogEvent({
    required this.kind,
    required this.name,
    this.message,
    this.meta,
    DateTime? at,
  }) : at = at ?? DateTime.now();

  factory LogEvent.fromJson(Map<String, dynamic> json) => LogEvent(
    kind: LogKind.values.firstWhere(
      (k) => k.name == json['kind'],
      orElse: () => LogKind.info,
    ),
    name: json['name'] as String,
    message: json['message'] as String?,
    meta: (json['meta'] as Map?)?.cast<String, Object?>(),
    at: DateTime.tryParse(json['at'] as String? ?? ''),
  );

  static const maxMessage = 1000;

  final LogKind kind;
  final String name;
  final String? message;
  final Map<String, Object?>? meta;
  final DateTime at;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'name': name,
    if (message != null) 'message': message,
    if (meta != null && meta!.isNotEmpty) 'meta': meta,
    'at': at.toUtc().toIso8601String(),
  };
}

/// Hadisələri serverə göndərir. Alınmasa xəta atır: hadisələr növbədə qalır.
abstract interface class LogSink {
  Future<void> send(List<LogEvent> events);
}

/// Göndərilməmiş hadisələr telefonda saxlanır (internetsiz və ya çökmədən sonra itməsin).
abstract interface class LogStore {
  List<LogEvent> load();
  Future<void> save(List<LogEvent> events);
}

class InMemoryLogStore implements LogStore {
  List<LogEvent> saved = [];

  @override
  List<LogEvent> load() => List.of(saved);

  @override
  Future<void> save(List<LogEvent> events) async => saved = List.of(events);
}
