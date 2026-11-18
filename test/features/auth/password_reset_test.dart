import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';
import 'package:prep_az/features/auth/presentation/auth_screen.dart';
import 'package:prep_az/features/auth/presentation/password_reset_controller.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  group('PasswordResetController', () {
    late ProviderContainer container;

    PasswordResetController controller() =>
        container.read(passwordResetControllerProvider.notifier);
    PasswordResetState state() =>
        container.read(passwordResetControllerProvider);

    setUp(() {
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      container.listen(passwordResetControllerProvider, (_, _) {});
      addTearDown(container.dispose);
    });

    test('sending the code moves to the code step', () async {
      await controller().sendCode('a@b.az');

      expect(repo.resetCodesSentTo, ['a@b.az']);
      expect(state().step, ResetStep.code);
      expect(state().email, 'a@b.az');
      expect(state().info, isNull);
    });

    test('a send error stays on the email step', () async {
      repo.resetCodeError = AppException(AppStrings.emailRateLimit);
      await controller().sendCode('a@b.az');

      expect(state().step, ResetStep.email);
      expect(state().error, AppStrings.emailRateLimit);
    });

    test('resend reuses the email and says so', () async {
      await controller().sendCode('a@b.az');
      await controller().resendCode();

      expect(repo.resetCodesSentTo, ['a@b.az', 'a@b.az']);
      expect(state().info, AppStrings.resetCodeResent);
    });

    test('confirm sends the code without spaces', () async {
      await controller().sendCode('a@b.az');
      await controller().confirm(code: '123 456', newPassword: 'yeni123');

      expect(repo.lastResetEmail, 'a@b.az');
      expect(repo.lastResetCode, '123456');
      expect(repo.lastNewPassword, 'yeni123');
      expect(state().error, isNull);
    });

    test('a wrong code shows the error and keeps the step', () async {
      await controller().sendCode('a@b.az');
      repo.resetError = AppException(AppStrings.resetCodeInvalid);
      await controller().confirm(code: '000000', newPassword: 'yeni123');

      expect(state().step, ResetStep.code);
      expect(state().error, AppStrings.resetCodeInvalid);
    });

    test('change email goes back and keeps the address', () async {
      await controller().sendCode('a@b.az');
      controller().changeEmail();

      expect(state().step, ResetStep.email);
      expect(state().email, 'a@b.az');
    });
  });

  group('reset screen', () {
    Future<void> openReset(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: AuthScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.choiceExistingTitle));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.az');
      final forgot = find.text(AppStrings.forgotPassword);
      await tester.ensureVisible(forgot);
      await tester.tap(forgot);
      await tester.pumpAndSettle();
    }

    testWidgets('full flow: email is prefilled, code + new password sent', (
      tester,
    ) async {
      await openReset(tester);
      expect(find.text(AppStrings.resetEmailIntro), findsOneWidget);
      expect(find.text('a@b.az'), findsOneWidget);

      await tester.tap(find.text(AppStrings.resetSendCodeAction));
      await tester.pumpAndSettle();
      expect(repo.resetCodesSentTo, ['a@b.az']);
      expect(find.text(AppStrings.resetCodeSentTo), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '123456');
      await tester.enterText(find.byType(TextFormField).at(1), 'yeni123');
      final confirm = find.text(AppStrings.resetConfirmAction);
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(repo.lastResetCode, '123456');
      expect(repo.lastNewPassword, 'yeni123');
    });

    testWidgets('a short code is rejected before calling the server', (
      tester,
    ) async {
      await openReset(tester);
      await tester.tap(find.text(AppStrings.resetSendCodeAction));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '12');
      await tester.enterText(find.byType(TextFormField).at(1), 'yeni123');
      final confirm = find.text(AppStrings.resetConfirmAction);
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.resetCodeFormat), findsOneWidget);
      expect(repo.lastResetCode, isNull);
    });

    testWidgets('back from reset returns to sign in', (tester) async {
      await openReset(tester);
      await tester.tap(find.byTooltip(AppStrings.back));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.forgotPassword, skipOffstage: false), findsOneWidget);
      expect(find.text(AppStrings.resetEmailIntro), findsNothing);
    });
  });
}
