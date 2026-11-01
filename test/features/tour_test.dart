import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_language.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/goal/domain/exam_goal.dart';
import 'package:prep_az/features/goal/presentation/goal_providers.dart';
import 'package:prep_az/features/goal/presentation/goal_screen.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/home/presentation/home_screen.dart';
import 'package:prep_az/features/home/presentation/widgets/header_mascot.dart';
import 'package:prep_az/features/settings/data/in_memory_settings_repository.dart';
import 'package:prep_az/features/settings/domain/app_settings.dart';
import 'package:prep_az/features/settings/presentation/settings_providers.dart';
import 'package:prep_az/features/tour/domain/tour_step.dart';
import 'package:prep_az/features/tour/presentation/tour_controller.dart';

import '../support/fakes.dart';
import 'goal_test.dart';
import 'home_screen_test.dart';

const _subject = Subject(id: 1, slug: 'kimya', name: 'Kimya');

void main() {
  late InMemorySettingsRepository settings;

  setUp(() => settings = InMemorySettingsRepository(const AppSettings()));

  Widget app({UserGoal? goal, List<Subject> subjects = const [_subject]}) {
    return ProviderScope(
      retry: (_, _) => null,
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        subjectRepositoryProvider.overrideWithValue(FakeSubjects(() async => subjects)),
        profileRepositoryProvider.overrideWithValue(FakeProfile(0)),
        progressRepositoryProvider.overrideWithValue(FakeProgressRepository(const [])),
        goalRepositoryProvider.overrideWithValue(FakeGoalRepository(goal: goal)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  // köməkçinin animasiyası sonsuzdur: pumpAndSettle burada bitmir
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpHome(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    await settle(tester);
  }

  Future<void> gotIt(WidgetTester tester) async {
    await tester.tap(find.text(AppStrings.tourGotIt));
    await settle(tester);
  }

  Future<void> tapMenu(WidgetTester tester) async {
    await tester.tapAt(tester.getCenter(find.byTooltip(AppStrings.menu)));
    await settle(tester);
  }

  testWidgets('walks through the menu and the subject card, then remembers it', (tester) async {
    await pumpHome(tester, app(goal: const UserGoal(periodId: 1)));
    expect(find.text(AppStrings.tourWelcome), findsOneWidget);

    await gotIt(tester);
    expect(find.text(AppStrings.tourOpenMenu), findsOneWidget);
    expect(find.text(AppStrings.tourGotIt), findsNothing, reason: 'here the student must tap the menu');

    await tapMenu(tester);
    expect(find.byType(Drawer), findsOneWidget);

    for (final message in [
      AppStrings.tourLanguage,
      AppStrings.tourAppearance,
      AppStrings.tourTeachers,
      AppStrings.tourReport,
      AppStrings.tourLegal,
      AppStrings.tourDeleteAccount,
      AppStrings.tourSignOut,
    ]) {
      expect(find.text(message), findsOneWidget);
      await gotIt(tester);
    }

    expect(find.byType(Drawer), findsNothing, reason: 'the drawer closes before the subject card');
    for (final message in [
      AppStrings.tourPractice,
      AppStrings.tourWeakPlaces,
      AppStrings.tourMistakes,
      AppStrings.tourTopics,
    ]) {
      expect(find.text(message), findsOneWidget);
      await gotIt(tester);
    }

    expect(find.text(AppStrings.tourDone), findsOneWidget);
    expect(settings.current.tourSeen, isFalse);

    await tester.tap(find.text(AppStrings.tourFinish));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.tourDone), findsNothing);
    expect(settings.current.tourSeen, isTrue);
  });

  testWidgets('a student who already saw it never gets it again', (tester) async {
    settings = InMemorySettingsRepository(const AppSettings(tourSeen: true));

    await tester.pumpWidget(app(goal: const UserGoal(periodId: 1)));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.tourWelcome), findsNothing);
  });

  // PrepAzApp dil dəyişəndə MaterialApp-ı açarla yenidən qurur: köhnə ekran yeni ağaca köçməməlidir
  testWidgets('changing the language closes the drawer and the app stays usable', (tester) async {
    settings = InMemorySettingsRepository(const AppSettings(tourSeen: true));
    addTearDown(() => AppStrings.language = AppLanguage.az);
    await pumpHome(
      tester,
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          subjectRepositoryProvider.overrideWithValue(FakeSubjects(() async => const [_subject])),
          profileRepositoryProvider.overrideWithValue(FakeProfile(0)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository(const [])),
          goalRepositoryProvider.overrideWithValue(FakeGoalRepository(goal: const UserGoal(periodId: 1))),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final language = ref.watch(settingsControllerProvider).language;
            return MaterialApp(key: ValueKey(language), home: const HomeScreen());
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip(AppStrings.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.languageTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip(AppStrings.menu));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget, reason: 'the home screen must still react to taps');
  });

  testWidgets('tapping the header mascot replays the tour for someone who saw it', (tester) async {
    settings = InMemorySettingsRepository(const AppSettings(tourSeen: true));
    await pumpHome(tester, app(goal: const UserGoal(periodId: 1)));
    expect(find.text(AppStrings.tourWelcome), findsNothing);

    await tester.tap(find.byType(HeaderMascot));
    await settle(tester);

    expect(find.text(AppStrings.tourWelcome), findsOneWidget);
  });

  testWidgets('starts right after the exam date screen closes', (tester) async {
    await pumpHome(tester, app());
    expect(find.byType(GoalScreen), findsOneWidget);
    expect(find.text(AppStrings.tourWelcome), findsNothing);

    await tester.tap(find.text(AppStrings.goalLater));
    await settle(tester);

    expect(find.byType(GoalScreen), findsNothing);
    expect(find.text(AppStrings.tourWelcome), findsOneWidget);
  });

  testWidgets('without subjects the card steps are skipped', (tester) async {
    await pumpHome(tester, app(goal: const UserGoal(periodId: 1), subjects: const []));

    await gotIt(tester);
    await tapMenu(tester);
    for (var i = 0; i < 7; i++) {
      await gotIt(tester);
    }

    expect(find.text(AppStrings.tourDone), findsOneWidget);
  });

  test('advance finishes after the last step and start does nothing once seen', () {
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
    final tour = container.read(tourControllerProvider.notifier);

    tour.start();
    expect(container.read(tourControllerProvider), TourStep.welcome);
    for (var i = 0; i < TourStep.values.length; i++) {
      tour.advance((_) => true);
    }

    expect(container.read(tourControllerProvider), isNull);
    tour.start();
    expect(container.read(tourControllerProvider), isNull);
  });
}
