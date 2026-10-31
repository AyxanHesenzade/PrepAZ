import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/auth/domain/auth_repository.dart';
import 'package:prep_az/features/auth/presentation/auth_controller.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late ProviderContainer container;

  AuthController controller() => container.read(authControllerProvider.notifier);
  AuthFormState state() => container.read(authControllerProvider);

  setUp(() {
    repo = FakeAuthRepository();
    container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repo)]);
    // autoDispose provider-in sınaq boyu yaşaması üçün dinləyirik.
    container.listen(authControllerProvider, (_, _) {});
    addTearDown(container.dispose);
  });

  Future<void> signUpPending() async {
    controller().setMode(AuthMode.signUp);
    repo.signUpOutcome = SignUpOutcome.confirmationRequired;
    await controller().submit(email: 'a@b.az', password: '123456');
  }

  test('sign in success leaves form idle without error', () async {
    await controller().submit(email: 'a@b.az', password: '123456');

    expect(state().isBusy, isFalse);
    expect(state().error, isNull);
    expect(repo.signInCalls, 1);
  });

  test('sign in failure exposes the error message', () async {
    repo.signInError = AppException(AppStrings.invalidCredentials);

    await controller().submit(email: 'a@b.az', password: '123456');

    expect(state().error, AppStrings.invalidCredentials);
    expect(state().isBusy, isFalse);
  });

  test('sign up that needs confirmation opens the waiting step', () async {
    await signUpPending();

    expect(state().pendingEmail, 'a@b.az');
    expect(state().error, isNull);
  });

  test('sign in with an unconfirmed email opens the waiting step', () async {
    repo.signInError = EmailNotConfirmedException();

    await controller().submit(email: 'a@b.az', password: '123456');

    expect(state().pendingEmail, 'a@b.az');
    expect(state().error, isNull);
  });

  test('sign up with an existing account moves to sign in with the message', () async {
    controller().setMode(AuthMode.signUp);
    repo.signUpError = AccountExistsException();

    await controller().submit(email: 'a@b.az', password: '123456');

    expect(state().isSignUp, isFalse);
    expect(state().error, AppStrings.userAlreadyExists);
  });

  test('checkConfirmed signs in with the remembered password', () async {
    await signUpPending();

    await controller().checkConfirmed();

    expect(repo.lastSignInEmail, 'a@b.az');
    expect(repo.lastSignInPassword, '123456');
    expect(state().error, isNull);
  });

  test('checkConfirmed explains when the email is still unconfirmed', () async {
    await signUpPending();
    repo.signInError = EmailNotConfirmedException();

    await controller().checkConfirmed();

    expect(state().error, AppStrings.emailStillNotConfirmed);
    expect(state().pendingEmail, 'a@b.az');
  });

  test('silent check stays quiet while unconfirmed', () async {
    await signUpPending();
    repo.signInError = EmailNotConfirmedException();

    await controller().checkConfirmedSilently();

    expect(repo.signInCalls, 1);
    expect(state().error, isNull);
    expect(state().isBusy, isFalse);
  });

  test('resend sends to the pending email and confirms it', () async {
    await signUpPending();

    await controller().resendConfirmation();

    expect(repo.resentTo, ['a@b.az']);
    expect(state().info, AppStrings.confirmationResent);
  });

  test('a failed resend shows the error and keeps waiting', () async {
    await signUpPending();
    repo.resendError = AppException(AppStrings.emailRateLimit);

    await controller().resendConfirmation();

    expect(state().error, AppStrings.emailRateLimit);
    expect(state().pendingEmail, 'a@b.az');
  });

  test('cancelConfirmation returns to the form and forgets the password', () async {
    await signUpPending();

    controller().cancelConfirmation();
    await controller().checkConfirmed();

    expect(state().awaitingConfirmation, isFalse);
    expect(state().isSignUp, isTrue);
    expect(repo.signInCalls, 0);
  });

  test('setMode switches mode and clears messages', () async {
    repo.signInError = AppException(AppStrings.invalidCredentials);
    await controller().submit(email: 'a@b.az', password: '123456');

    controller().setMode(AuthMode.signUp);

    expect(state().isSignUp, isTrue);
    expect(state().error, isNull);
  });

  test('ignores a second submit while busy', () async {
    final first = controller().submit(email: 'a@b.az', password: '123456');
    final second = controller().submit(email: 'a@b.az', password: '123456');
    await Future.wait([first, second]);

    expect(repo.signInCalls, 1);
  });
}
