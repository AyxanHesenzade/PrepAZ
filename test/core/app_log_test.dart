import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/core/logging/app_log.dart';
import 'package:prep_az/core/logging/log_event.dart';
import 'package:prep_az/features/auth/presentation/auth_controller.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/fake_auth_repository.dart';

class FakeSink implements LogSink {
  final sent = <List<LogEvent>>[];
  bool fail = false;

  @override
  Future<void> send(List<LogEvent> events) async {
    if (fail) throw const SocketException('offline');
    sent.add(List.of(events));
  }
}

void main() {
  late FakeSink sink;
  late InMemoryLogStore store;
  late EventLogger logger;

  setUp(() {
    sink = FakeSink();
    store = InMemoryLogStore();
    logger = EventLogger(sink: sink, store: store, delay: null);
  });

  tearDown(AppLog.uninstall);

  LogEvent event(String name) => LogEvent(kind: LogKind.auth, name: name);

  group('EventLogger', () {
    test('keeps events on the phone until they are sent', () async {
      logger.add(event('a'));
      logger.add(event('b'));
      expect(store.saved.map((e) => e.name), ['a', 'b']);

      await logger.flush();

      expect(sink.sent.single.map((e) => e.name), ['a', 'b']);
      expect(logger.pending, isEmpty);
      expect(store.saved, isEmpty);
    });

    test('a failed send keeps the queue for the next try', () async {
      sink.fail = true;
      logger.add(event('a'));
      await logger.flush();
      expect(logger.pending, hasLength(1));

      sink.fail = false;
      await logger.flush();
      expect(sink.sent.single.single.name, 'a');
    });

    test('loads events saved before a restart', () async {
      store.saved = [event('old')];
      final restarted = EventLogger(sink: sink, store: store, delay: null);
      await restarted.flush();
      expect(sink.sent.single.single.name, 'old');
    });

    test('sends in batches of 50 and keeps at most 200', () async {
      for (var i = 0; i < 230; i++) {
        logger.add(event('e$i'));
      }
      expect(logger.pending.first.name, 'e30');

      await logger.flush();

      expect(sink.sent.map((b) => b.length), [50, 50, 50, 50]);
    });

    test('every kind is sent by default, a kind can be switched off', () async {
      logger.add(LogEvent(kind: LogKind.info, name: 'app_open'));
      expect(logger.pending.single.name, 'app_open');

      final noInfo = EventLogger(
        sink: sink,
        store: InMemoryLogStore(),
        delay: null,
        kinds: {LogKind.auth, LogKind.error, LogKind.crash},
      )..add(LogEvent(kind: LogKind.info, name: 'tab'));
      expect(noInfo.pending, isEmpty);
    });

    test('two flushes at once send only once', () async {
      logger.add(event('a'));
      await Future.wait([logger.flush(), logger.flush()]);
      expect(sink.sent, hasLength(1));
    });

    test('json survives the round trip', () {
      final e = LogEvent(
        kind: LogKind.auth,
        name: 'sign_in_failed',
        message: 'm',
        meta: {'email': 'a@b.az'},
        at: DateTime.utc(2026, 11, 18, 10),
      );
      final back = LogEvent.fromJson(
        jsonDecode(jsonEncode(e.toJson())) as Map<String, dynamic>,
      );
      expect(back.kind, LogKind.auth);
      expect(back.meta, {'email': 'a@b.az'});
      expect(back.at, e.at);
      expect(e.toJson()['at'], '2026-11-18T10:00:00.000Z');
    });
  });

  group('describeError', () {
    test('database error keeps its code', () {
      final e = describeError(
        LogKind.error,
        const PostgrestException(message: 'function missing', code: 'PGRST202'),
      );
      expect(e.name, 'PostgrestException');
      expect(e.message, 'function missing');
      expect(e.meta!['code'], 'PGRST202');
    });

    test('no internet is called network', () {
      expect(describeError(LogKind.error, const SocketException('x')).name, 'network');
    });

    test('very long messages are cut', () {
      final e = describeError(LogKind.error, Exception('x' * 3000));
      expect(e.message!.length, LogEvent.maxMessage);
    });

    test('the place is the first project frame outside the helpers', () {
      final stack = StackTrace.fromString(
        '#0      guard (package:prep_az/core/error/app_exception.dart:23:30)\n'
        '#1      SupabaseHomeRepository.subjects (package:prep_az/features/home/data/supabase_home_repository.dart:42:12)\n'
        '#2      main (package:prep_az/main.dart:10:3)',
      );
      expect(
        projectFrame(stack),
        'features/home/data/supabase_home_repository.dart:42 (SupabaseHomeRepository.subjects)',
      );
      expect(projectFrame(StackTrace.fromString('#0 x (dart:async/zone.dart:1:1)')), isNull);
    });
  });

  group('guard', () {
    test('logs technical errors with the caller', () async {
      AppLog.install(logger);
      await expectLater(
        guard<void>(() async => throw const PostgrestException(message: 'boom')),
        throwsA(isA<AppException>()),
      );
      final e = logger.pending.single;
      expect(e.kind, LogKind.error);
      expect(e.name, 'PostgrestException');
      expect(e.message, 'boom'); // the caller here is the test file, not package:prep_az, so no 'where'
    });

    test('does not log intended AppExceptions', () async {
      AppLog.install(logger);
      await expectLater(
        guard<void>(() async => throw const AppException('hesab var')),
        throwsA(isA<AppException>()),
      );
      expect(logger.pending, isEmpty);
    });

    test('does nothing when logging is not installed', () async {
      await expectLater(
        guard<void>(() async => throw const PostgrestException(message: 'boom')),
        throwsA(isA<AppException>()),
      );
      expect(logger.pending, isEmpty);
    });
  });

  test('a failed sign in is logged with the e-mail and never the password', () async {
    AppLog.install(logger);
    final repo = FakeAuthRepository()..signInError = const AppException('yanlış');
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, _) {});
    final controller = container.read(authControllerProvider.notifier)
      ..setMode(AuthMode.signIn);

    await controller.submit(email: ' Ali@Mail.az ', password: 'gizli-parol');

    final e = logger.pending.single;
    expect(e.kind, LogKind.auth);
    expect(e.name, 'sign_in_failed');
    expect(e.message, 'yanlış');
    expect(e.meta, {'email': 'ali@mail.az'});
    expect(jsonEncode(e.toJson()), isNot(contains('gizli-parol')));
  });
}
