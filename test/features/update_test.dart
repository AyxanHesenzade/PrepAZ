import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/config/app_version.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/update/domain/app_config.dart';
import 'package:prep_az/features/update/domain/app_config_repository.dart';
import 'package:prep_az/features/update/presentation/update_gate.dart';
import 'package:prep_az/features/update/presentation/update_providers.dart';

class _FakeConfig implements AppConfigRepository {
  _FakeConfig(this.config);
  final AppConfig? config;
  @override
  Future<AppConfig?> getConfig() async => config;
}

const _v = VersionCode(0, 0, 1, 2); // the app that is running: 0.0.1+2

Widget _app(AppConfig? config) => ProviderScope(
      overrides: [
        appVersionProvider.overrideWith((ref) async => const AppVersion(version: '0.0.1', build: 2)),
        appConfigRepositoryProvider.overrideWithValue(_FakeConfig(config)),
      ],
      child: const MaterialApp(home: UpdateGate(child: Scaffold(body: Text('HOME')))),
    );

void main() {
  group('VersionCode', () {
    test('parses with and without build, rejects junk', () {
      expect(VersionCode.tryParse('0.0.1+2')!.build, 2);
      expect(VersionCode.tryParse('1.2.3')!.build, 0);
      expect(VersionCode.tryParse('1.2'), isNull);
      expect(VersionCode.tryParse('abc'), isNull);
    });
    test('compares major, minor, patch, then build', () {
      expect(VersionCode.tryParse('0.0.1+2')! < VersionCode.tryParse('0.0.1+3')!, isTrue);
      expect(VersionCode.tryParse('0.0.9')! < VersionCode.tryParse('0.1.0')!, isTrue);
      expect(VersionCode.tryParse('1.0.0')! < VersionCode.tryParse('0.9.9')!, isFalse);
      expect(VersionCode.tryParse('0.0.1+2')! < VersionCode.tryParse('0.0.1+2')!, isFalse);
    });
  });

  group('UpdateInfo.decide', () {
    UpdateKind kind(String min, String latest) =>
        UpdateInfo.decide(_v, AppConfig(minVersion: min, latestVersion: latest)).kind;

    test('harmless defaults and equal versions: nothing', () {
      expect(kind('0.0.0', '0.0.0'), UpdateKind.none);
      expect(kind('0.0.1+2', '0.0.1+2'), UpdateKind.none);
      expect(kind('0.0.1', '0.0.1'), UpdateKind.none); // no build = 0, the app is newer
    });
    test('older than min: required; older than latest: optional; required wins', () {
      expect(kind('0.0.1+3', '0.0.1+3'), UpdateKind.required);
      expect(kind('0.0.1', '0.0.2'), UpdateKind.optional);
      expect(kind('0.1.0', '0.0.2'), UpdateKind.required);
    });
    test('missing or broken config never blocks', () {
      expect(UpdateInfo.decide(_v, null).kind, UpdateKind.none);
      expect(kind('junk', 'junk'), UpdateKind.none);
    });
  });

  testWidgets('required: blocking screen with the update button, the app is not shown', (tester) async {
    await tester.pumpWidget(_app(const AppConfig(minVersion: '0.0.2', latestVersion: '0.0.2', updateUrl: 'https://example.com/app.apk')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.updateRequiredTitle), findsOneWidget);
    expect(find.text(AppStrings.updateNow), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('required without a link: no button', (tester) async {
    await tester.pumpWidget(_app(const AppConfig(minVersion: '0.0.2', latestVersion: '0.0.2')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.updateRequiredTitle), findsOneWidget);
    expect(find.text(AppStrings.updateNow), findsNothing);
  });

  testWidgets('optional: the app opens and a dismissible notice appears once', (tester) async {
    await tester.pumpWidget(_app(const AppConfig(minVersion: '0.0.1', latestVersion: '0.0.2', updateUrl: 'https://example.com/app.apk')));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text(AppStrings.updateAvailableTitle), findsOneWidget);
    await tester.tap(find.text(AppStrings.updateLater));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.updateAvailableTitle), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('up to date or config unreadable: just the app', (tester) async {
    await tester.pumpWidget(_app(const AppConfig(minVersion: '0.0.0', latestVersion: '0.0.0')));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    await tester.pumpWidget(_app(null));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text(AppStrings.updateRequiredTitle), findsNothing);
  });
}
