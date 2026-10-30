import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/auth/domain/auth_repository.dart';
import 'package:prep_az/features/auth/presentation/auth_controller.dart';
import 'package:prep_az/features/auth/presentation/auth_providers.dart';

class FakeAuthRepository implements AuthRepository {
  Object? signInError;
  SignUpOutcome signUpOutcome = SignUpOutcome.signedIn;
  int signInCalls = 0;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<SignUpOutcome> signUp({required String email, required String password}) async =>
      signUpOutcome;

  @override
  Future<void> signOut() async {}

  @override
  Stream<bool> watchSignedIn() => Stream.value(false);
}

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

  test('sign up that needs confirmation shows the notice', () async {
    controller().toggleMode();
    repo.signUpOutcome = SignUpOutcome.confirmationRequired;

    await controller().submit(email: 'a@b.az', password: '123456');

    expect(state().info, AppStrings.confirmEmailNotice);
    expect(state().error, isNull);
  });

  test('toggleMode switches mode and clears messages', () async {
    repo.signInError = AppException(AppStrings.invalidCredentials);
    await controller().submit(email: 'a@b.az', password: '123456');

    controller().toggleMode();

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
