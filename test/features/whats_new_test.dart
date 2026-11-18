import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/config/app_version.dart';
import 'package:prep_az/core/constants/app_language.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/settings/data/in_memory_settings_repository.dart';
import 'package:prep_az/features/settings/domain/app_settings.dart';
import 'package:prep_az/features/settings/presentation/settings_providers.dart';
import 'package:prep_az/features/whats_new/data/release_notes.dart';
import 'package:prep_az/features/whats_new/domain/release_note.dart';
import 'package:prep_az/features/whats_new/presentation/whats_new_check.dart';
import 'package:prep_az/features/whats_new/presentation/whats_new_providers.dart';

ReleaseNote _note(int build, [List<String> items = const ['x']]) =>
    ReleaseNote(build: build, version: '1.$build.0', items: () => items);

void main() {
  group('notesToShow', () {
    final all = [_note(11), _note(12), _note(13), _note(14, const [])];

    List<int> builds({
      required int current,
      required int lastSeen,
      bool isNewUser = false,
    }) => notesToShow(
      currentBuild: current,
      lastSeenBuild: lastSeen,
      isNewUser: isNewUser,
      all: all,
    ).map((n) => n.build).toList();

    test('new user sees nothing', () {
      expect(builds(current: 13, lastSeen: 0, isNewUser: true), isEmpty);
    });

    test(
      'existing user without a stored value sees only the current build',
      () {
        expect(builds(current: 13, lastSeen: 0), [13]);
      },
    );

    test('already seen build is not shown again', () {
      expect(builds(current: 13, lastSeen: 13), isEmpty);
    });

    test('skipped versions are shown newest first', () {
      expect(builds(current: 13, lastSeen: 10), [13, 12, 11]);
    });

    test('at most three versions', () {
      final many = [for (var b = 1; b <= 10; b++) _note(b)];
      final shown = notesToShow(
        currentBuild: 10,
        lastSeenBuild: 1,
        isNewUser: false,
        all: many,
      );
      expect(shown.map((n) => n.build), [10, 9, 8]);
    });

    test('a build with no items shows nothing', () {
      expect(builds(current: 14, lastSeen: 13), isEmpty);
    });
  });

  group('release notes file', () {
    final app = AppVersion.fromJson(
      jsonDecode(File('assets/app.json').readAsStringSync())
          as Map<String, dynamic>,
    );

    test('the current build has an entry (write the news or an empty list)', () {
      final note = releaseNotes.where((n) => n.build == app.build);
      expect(
        note,
        hasLength(1),
        reason:
            'lib/features/whats_new/data/release_notes.dart: build ${app.build} üçün sətir yoxdur',
      );
      expect(note.single.version, app.version);
    });

    test('builds are unique and every item exists in all three languages', () {
      final builds = releaseNotes.map((n) => n.build).toList();
      expect(builds.toSet(), hasLength(builds.length));
      final saved = AppStrings.language;
      addTearDown(() => AppStrings.language = saved);
      for (final note in releaseNotes) {
        final counts = <int>{};
        for (final language in AppLanguage.values) {
          AppStrings.language = language;
          final items = note.items();
          counts.add(items.length);
          expect(items.every((t) => t.trim().isNotEmpty), isTrue);
        }
        expect(counts, hasLength(1));
      }
    });
  });

  group('WhatsNewCheck', () {
    late InMemorySettingsRepository settings;

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whatsNewEnabledProvider.overrideWithValue(true),
            settingsRepositoryProvider.overrideWithValue(settings),
            appVersionProvider.overrideWith(
              (ref) => const AppVersion(version: '1.13.0', build: 13),
            ),
            releaseNotesProvider.overrideWithValue([
              _note(13, const ['Parol bərpası']),
            ]),
          ],
          child: const MaterialApp(
            home: WhatsNewCheck(child: Scaffold(body: Text('home'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('after an update the sheet opens once and is remembered', (
      tester,
    ) async {
      settings = InMemorySettingsRepository(
        const AppSettings(tourSeen: true, whatsNewSeenBuild: 12),
      );
      await pump(tester);

      expect(find.text('Parol bərpası'), findsOneWidget);
      expect(settings.current.whatsNewSeenBuild, 13);

      await tester.tap(find.text(AppStrings.whatsNewOk));
      await tester.pumpAndSettle();
      expect(find.text('Parol bərpası'), findsNothing);
    });

    testWidgets('a new user does not see it, but the build is stored', (
      tester,
    ) async {
      settings = InMemorySettingsRepository(const AppSettings());
      await pump(tester);

      expect(find.text('Parol bərpası'), findsNothing);
      expect(settings.current.whatsNewSeenBuild, 13);
    });

    testWidgets('a seen build does not open again', (tester) async {
      settings = InMemorySettingsRepository(
        const AppSettings(tourSeen: true, whatsNewSeenBuild: 13),
      );
      await pump(tester);

      expect(find.text('Parol bərpası'), findsNothing);
    });
  });
}
