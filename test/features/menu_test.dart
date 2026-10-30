import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_language.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/menu/presentation/app_drawer.dart';
import 'package:prep_az/features/settings/data/in_memory_settings_repository.dart';
import 'package:prep_az/features/settings/domain/app_settings.dart';
import 'package:prep_az/features/settings/presentation/settings_providers.dart';
import 'package:prep_az/features/teachers/domain/teacher.dart';
import 'package:prep_az/features/teachers/presentation/teachers_providers.dart';
import 'package:prep_az/features/teachers/presentation/teachers_screen.dart';

/// Dil dəyişəndə MaterialApp-ın özü yox, yalnız seçilmiş ekran yenidən qurulur (PrepAzApp-dakı key testdə yoxdur).
Widget _drawerApp(InMemorySettingsRepository repo) => ProviderScope(
      retry: (_, _) => null,
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Scaffold(
          drawer: const AppDrawer(),
          body: Builder(
            builder: (context) => TextButton(onPressed: () => Scaffold.of(context).openDrawer(), child: const Text('open')),
          ),
        ),
      ),
    );

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
