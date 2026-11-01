import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_language.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';
import 'package:prep_az/features/legal/data/legal_texts.dart';
import 'package:prep_az/features/legal/domain/legal_document.dart';
import 'package:prep_az/features/legal/domain/legal_repository.dart';
import 'package:prep_az/features/legal/presentation/legal_acceptance_recorder.dart';
import 'package:prep_az/features/legal/presentation/legal_providers.dart';
import 'package:prep_az/features/settings/data/in_memory_settings_repository.dart';
import 'package:prep_az/features/settings/domain/app_settings.dart';
import 'package:prep_az/features/settings/presentation/settings_providers.dart';

class _FakeLegal implements LegalRepository {
  _FakeLegal({this.fails = false});

  final bool fails;
  final recorded = <int>[];

  @override
  Future<void> recordAcceptance(int version) async {
    if (fails) throw Exception('offline');
    recorded.add(version);
  }
}

void main() {
  setUp(() => AppStrings.language = AppLanguage.az);
  tearDown(() => AppStrings.language = AppLanguage.az);

  Widget app(InMemorySettingsRepository settings, _FakeLegal legal, {bool signedIn = true}) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        legalRepositoryProvider.overrideWithValue(legal),
        isSignedInProvider.overrideWith((ref) => Stream.value(signedIn)),
      ],
      child: const MaterialApp(home: LegalAcceptanceRecorder(child: Text('home'))),
    );
  }

  const pending = AppSettings(pendingLegalVersion: currentLegalVersion);

  testWidgets('a pending acceptance is written once signed in, then cleared', (tester) async {
    final settings = InMemorySettingsRepository(pending);
    final legal = _FakeLegal();
    await tester.pumpWidget(app(settings, legal));
    await tester.pumpAndSettle();
    expect(legal.recorded, [currentLegalVersion]);
    expect(settings.current.pendingLegalVersion, 0);
  });

  testWidgets('nothing is written while signed out', (tester) async {
    final settings = InMemorySettingsRepository(pending);
    final legal = _FakeLegal();
    await tester.pumpWidget(app(settings, legal, signedIn: false));
    await tester.pumpAndSettle();
    expect(legal.recorded, isEmpty);
    expect(settings.current.pendingLegalVersion, currentLegalVersion);
  });

  testWidgets('existing users are not recorded', (tester) async {
    final legal = _FakeLegal();
    await tester.pumpWidget(app(InMemorySettingsRepository(const AppSettings()), legal));
    await tester.pumpAndSettle();
    expect(legal.recorded, isEmpty);
  });

  testWidgets('a failed write keeps it pending and does not block the app', (tester) async {
    final settings = InMemorySettingsRepository(pending);
    await tester.pumpWidget(app(settings, _FakeLegal(fails: true)));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(settings.current.pendingLegalVersion, currentLegalVersion);
  });

  group('texts', () {
    final all = [
      for (final document in LegalDocument.values)
        for (final language in AppLanguage.values) legalSections(document, language),
    ];

    test('every language has the same sections', () {
      for (final document in LegalDocument.values) {
        final counts = {for (final l in AppLanguage.values) legalSections(document, l).length};
        expect(counts, hasLength(1));
      }
    });

    test('the contact section matches the real menu title', () {
      for (final language in AppLanguage.values) {
        AppStrings.language = language;
        expect(legalSections(LegalDocument.terms, language).last.body, contains(AppStrings.reportAppTitle));
      }
    });

    test('deletion points to the real menu title', () {
      for (final language in AppLanguage.values) {
        AppStrings.language = language;
        expect(legalSections(LegalDocument.privacy, language)[5].body, contains(AppStrings.deleteAccount));
      }
    });

    test('nothing is said about where questions come from', () {
      final text = all.expand((s) => s).map((s) => '${s.heading} ${s.body}').join(' ').toLowerCase();
      for (final word in ['dim', 'dİm', 'дим', 'araz', 'güvən']) {
        expect(RegExp('(^|[^\\p{L}])$word([^\\p{L}]|\$)', unicode: true).hasMatch(text), isFalse, reason: word);
      }
    });
  });
}
