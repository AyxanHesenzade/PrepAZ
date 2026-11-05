import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_language.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/menu/presentation/app_drawer.dart';
import 'package:prep_az/features/share/domain/share_service.dart';
import 'package:prep_az/features/share/presentation/share_app.dart';
import 'package:prep_az/features/tour/domain/tour_step.dart';
import 'package:prep_az/features/tour/presentation/tour_targets.dart';
import 'package:prep_az/features/update/domain/app_config.dart';
import 'package:prep_az/features/update/domain/app_config_repository.dart';
import 'package:prep_az/features/update/presentation/update_providers.dart';
import 'package:prep_az/features/settings/data/in_memory_settings_repository.dart';
import 'package:prep_az/features/settings/domain/app_settings.dart';
import 'package:prep_az/features/settings/presentation/settings_providers.dart';
import 'package:prep_az/features/teachers/domain/teacher.dart';
import 'package:prep_az/features/teachers/presentation/teachers_providers.dart';
import 'package:prep_az/features/teachers/presentation/teachers_screen.dart';

/// Dil dəyişəndə MaterialApp-ın özü yox, yalnız seçilmiş ekran yenidən qurulur (PrepAzApp-dakı key testdə yoxdur).
Widget _drawerApp(InMemorySettingsRepository repo, {AppConfig? config, ShareService? share}) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        appConfigRepositoryProvider.overrideWithValue(_FakeConfig(config)),
        shareServiceProvider.overrideWithValue(share ?? _FakeShare()),
      ],
      child: MaterialApp(
        home: Scaffold(
          drawer: const AppDrawer(),
          body: Builder(
            builder: (context) => TextButton(onPressed: () => Scaffold.of(context).openDrawer(), child: const Text('open')),
          ),
        ),
      ),
    );

class _FakeConfig implements AppConfigRepository {
  _FakeConfig(this.config);

  final AppConfig? config;

  @override
  Future<AppConfig?> getConfig() async => config;
}

class _FakeShare implements ShareService {
  _FakeShare({this.fail = false});

  final bool fail;
  final List<String> texts = [];

  @override
  Future<void> shareText(String text, {String? subject}) async {
    if (fail) throw AppException(AppStrings.unknownError);
    texts.add(text);
  }
}

AppConfig _config(String? url) => AppConfig(minVersion: '0.0.1', latestVersion: '0.0.1', updateUrl: url);

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => AppStrings.language = AppLanguage.az);

  testWidgets('drawer: sections expand on tap, language and theme are saved', (tester) async {
    final repo = InMemorySettingsRepository();
    await tester.pumpWidget(_drawerApp(repo));
    await _openDrawer(tester);

    // bağlı bölmədə seçimlər görünmür
    expect(find.text('Русский'), findsNothing);
    await tester.tap(find.text(AppStrings.languageTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(repo.current.language, AppLanguage.ru);
    expect(AppStrings.language, AppLanguage.ru);
    expect(AppStrings.signOut, 'Выйти');

    await tester.tap(find.text(AppStrings.appearance));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.themeDark));
    await tester.pumpAndSettle();
    expect(repo.current.themeMode, AppThemeMode.dark);
  });

  testWidgets('saved language is applied when the controller starts', (tester) async {
    final repo = InMemorySettingsRepository(const AppSettings(language: AppLanguage.en, themeMode: AppThemeMode.light));
    final container = ProviderContainer(overrides: [settingsRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);

    final settings = container.read(settingsControllerProvider);
    expect(settings.language, AppLanguage.en);
    expect(AppStrings.language, AppLanguage.en);
    expect(AppStrings.check, 'Check');
  });

  testWidgets('share button sits right below the teachers item', (tester) async {
    await tester.pumpWidget(_drawerApp(InMemorySettingsRepository()));
    await _openDrawer(tester);

    expect(find.text(AppStrings.shareAppTitle), findsOneWidget);
    expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    final teachers = tester.getTopLeft(find.text(AppStrings.teachersTitle)).dy;
    final share = tester.getTopLeft(find.text(AppStrings.shareAppTitle)).dy;
    final report = tester.getTopLeft(find.text(AppStrings.reportAppTitle)).dy;
    expect(teachers < share && share < report, isTrue);
  });

  testWidgets('share: the link from app_config goes into the message', (tester) async {
    final share = _FakeShare();
    await tester.pumpWidget(
      _drawerApp(InMemorySettingsRepository(), config: _config('  https://example.com/prepaz.apk '), share: share),
    );
    await _openDrawer(tester);
    await tester.tap(find.text(AppStrings.shareAppTitle));
    await tester.pumpAndSettle();

    expect(share.texts, [AppStrings.shareAppMessage('https://example.com/prepaz.apk')]);
    expect(share.texts.single, endsWith('https://example.com/prepaz.apk'));
    expect(share.texts.single, isNot(contains('{link}')));
    expect(find.byType(Drawer), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  for (final (name, config) in [
    ('config cannot be read', null),
    ('url is empty', _config('  ')),
    ('url is null', _config(null)),
  ]) {
    testWidgets('share: no dialog and a SnackBar when $name', (tester) async {
      final share = _FakeShare();
      await tester.pumpWidget(_drawerApp(InMemorySettingsRepository(), config: config, share: share));
      await _openDrawer(tester);
      await tester.tap(find.text(AppStrings.shareAppTitle));
      await tester.pumpAndSettle();

      expect(share.texts, isEmpty);
      expect(find.text(AppStrings.shareAppNoLink), findsOneWidget);
    });
  }

  testWidgets('share: a failing share dialog shows the error instead of crashing', (tester) async {
    await tester.pumpWidget(
      _drawerApp(
        InMemorySettingsRepository(),
        config: _config('https://example.com/prepaz.apk'),
        share: _FakeShare(fail: true),
      ),
    );
    await _openDrawer(tester);
    await tester.tap(find.text(AppStrings.shareAppTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.unknownError), findsOneWidget);
  });

  test('share has a tour step right after teachers, with a target key and a message', () {
    expect(TourStep.values.indexOf(TourStep.shareApp), TourStep.values.indexOf(TourStep.teachers) + 1);
    expect(TourStep.shareApp.inDrawer, isTrue);
    expect(TourTargets().keyFor(TourStep.shareApp), isNotNull);
    for (final language in AppLanguage.values) {
      AppStrings.language = language;
      for (final text in [AppStrings.shareAppTitle, AppStrings.shareAppNoLink, AppStrings.tourShareApp]) {
        expect(text.trim(), isNotEmpty, reason: language.name);
      }
      expect(AppStrings.shareAppMessage('https://x.az'), endsWith('https://x.az'), reason: language.name);
    }
    AppStrings.language = AppLanguage.ru;
    expect(AppStrings.shareAppTitle, 'Поделиться с другом');
    AppStrings.language = AppLanguage.en;
    expect(AppStrings.shareAppTitle, 'Share with a friend');
  });

  test('every string exists in all three languages', () {
    for (final language in AppLanguage.values) {
      AppStrings.language = language;
      final texts = [
        AppStrings.retry,
        AppStrings.unknownError,
        AppStrings.signInTitle,
        AppStrings.homeTitle,
        AppStrings.startQuiz,
        AppStrings.teachersTitle,
        AppStrings.themeSystem,
        AppStrings.streak(3),
        AppStrings.questionOf(1, 5),
        AppStrings.wrong('B'),
      ];
      expect(texts.every((t) => t.trim().isNotEmpty), isTrue, reason: language.name);
    }
    AppStrings.language = AppLanguage.ru;
    expect(AppStrings.streak(3), contains('3'));
    AppStrings.language = AppLanguage.en;
    expect(AppStrings.streak(1), 'Streak: 1 day in a row');
  });

  testWidgets('teachers screen lists the teachers with contact buttons', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        teachersProvider.overrideWith((ref) async => const [
          Teacher(
            name: 'Aydın Əliyev',
            subject: 'Kimya müəllimi',
            lessonMode: LessonMode.both,
            phone: '+994501112233',
            address: 'Bakı, Nərimanov',
            about: 'On il təcrübə',
            offer: 'Qrup dərsləri',
          ),
        ]),
      ],
      child: const MaterialApp(home: TeachersScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Aydın Əliyev'), findsOneWidget);
    expect(find.text('Kimya müəllimi'), findsOneWidget);
    expect(find.text('Qrup dərsləri'), findsOneWidget);
    expect(find.text(AppStrings.lessonBoth), findsOneWidget);
    expect(find.text('Bakı, Nərimanov'), findsOneWidget);
    expect(find.text('On il təcrübə'), findsOneWidget);
    expect(find.text('A'), findsOneWidget); // foto yoxdur: adın ilk hərfi
    expect(find.text(AppStrings.callAction), findsOneWidget);
    expect(find.text('+994501112233'), findsOneWidget);
  });

  testWidgets('empty teacher list shows a friendly message', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [teachersProvider.overrideWith((ref) async => const [])],
      child: const MaterialApp(home: TeachersScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.teachersEmpty), findsOneWidget);
  });

  testWidgets('online teacher: address is hidden, photo link falls back to the initial when it cannot load', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        teachersProvider.overrideWith((ref) async => const [
          Teacher(
            name: 'Leyla Həsənova',
            subject: 'Biologiya müəllimi',
            lessonMode: LessonMode.online,
            phone: '+994551112233',
            address: 'Bakı, gizli ünvan',
            photo: 'assets/teachers/yoxdur.jpg',
          ),
        ]),
      ],
      child: const MaterialApp(home: TeachersScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lessonOnline), findsOneWidget);
    expect(find.text('Bakı, gizli ünvan'), findsNothing);
    expect(find.text('L'), findsOneWidget);
  });

  test('teacher phone digits for WhatsApp', () {
    const t = Teacher(name: 'A', subject: 'B', lessonMode: LessonMode.online, phone: '+994 (50) 111-22-33');
    expect(t.phoneDigits, '994501112233');
  });
}
