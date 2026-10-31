import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/auth/domain/auth_repository.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';
import 'package:prep_az/features/auth/presentation/auth_screen.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: AuthScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> register(WidgetTester tester) async {
    repo.signUpOutcome = SignUpOutcome.confirmationRequired;
    await tester.tap(find.text(AppStrings.signUpTab));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.az');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    final submit = find.widgetWithText(FilledButton, AppStrings.signUpAction);
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
  }

  setUp(() => repo = FakeAuthRepository());

  testWidgets('the sign in tab tells new users to tap the link first', (tester) async {
    await pumpScreen(tester);

    expect(find.text(AppStrings.signInGuideForm), findsOneWidget);
    expect(find.text(AppStrings.signInGuideNewUser), findsOneWidget);
  });

  testWidgets('the sign up tab explains the email step', (tester) async {
    await pumpScreen(tester);
    expect(find.text(AppStrings.signUpGuideTitle), findsNothing);

    await tester.tap(find.text(AppStrings.signUpTab));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.signUpGuideTitle), findsOneWidget);
    expect(find.text(AppStrings.signUpGuideLink), findsOneWidget);
    expect(find.widgetWithText(FilledButton, AppStrings.signUpAction), findsOneWidget);
  });

  testWidgets('the link under the button switches to sign up', (tester) async {
    await pumpScreen(tester);

    final link = find.text(AppStrings.switchToSignUp);
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.signUpGuideTitle), findsOneWidget);
  });

  testWidgets('the eye button reveals the password', (tester) async {
    await pumpScreen(tester);
    bool obscured() => tester.widget<EditableText>(find.byType(EditableText).at(1)).obscureText;
    expect(obscured(), isTrue);

    await tester.ensureVisible(find.byTooltip(AppStrings.showPassword));
    await tester.tap(find.byTooltip(AppStrings.showPassword));
    await tester.pump();

    expect(obscured(), isFalse);
  });

  testWidgets('after sign up the steps and the email are shown', (tester) async {
    await pumpScreen(tester);

    await register(tester);

    expect(find.text('a@b.az'), findsOneWidget);
    expect(find.text(AppStrings.confirmStepOpen), findsOneWidget);
    expect(find.text(AppStrings.confirmStepTap), findsOneWidget);
    expect(find.text(AppStrings.confirmStepReturn), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('returning to the app signs in without another password entry', (tester) async {
    await pumpScreen(tester);
    await register(tester);
    expect(repo.signInCalls, 0);

    for (final lifecycle in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(lifecycle);
    }
    await tester.pumpAndSettle();

    expect(repo.signInCalls, 1);
    expect(repo.lastSignInPassword, '123456');
  });

  testWidgets('going back keeps the typed email in the form', (tester) async {
    await pumpScreen(tester);
    await register(tester);

    await tester.ensureVisible(find.text(AppStrings.confirmBackAction));
    await tester.tap(find.text(AppStrings.confirmBackAction));
    await tester.pumpAndSettle();

    expect(find.text('a@b.az'), findsOneWidget);
    expect(find.text(AppStrings.confirmStepTap), findsNothing);
  });
}
