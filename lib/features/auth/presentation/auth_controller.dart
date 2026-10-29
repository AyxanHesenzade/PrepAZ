import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

enum AuthMode { signIn, signUp }

class AuthFormState {
  const AuthFormState({this.mode = AuthMode.signIn, this.isBusy = false, this.error, this.info});

  final AuthMode mode;
  final bool isBusy;
  final String? error;
  final String? info;

  bool get isSignUp => mode == AuthMode.signUp;

  AuthFormState busy() => AuthFormState(mode: mode, isBusy: true);
  AuthFormState failed(String message) => AuthFormState(mode: mode, error: message);
  AuthFormState notice(String message) => AuthFormState(mode: mode, info: message);
  AuthFormState idle() => AuthFormState(mode: mode);
}

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  void toggleMode() {
    state = AuthFormState(mode: state.isSignUp ? AuthMode.signIn : AuthMode.signUp);
  }

  /// Uğurlu girişdən sonra heç nə etmirik: AuthGate sessiya dəyişikliyini görüb özü yönləndirir.
  Future<void> submit({required String email, required String password}) async {
    if (state.isBusy) return;
    final signUp = state.isSignUp;
    state = state.busy();
    try {
      if (signUp) {
        final outcome = await _repo.signUp(email: email, password: password);
        state = outcome == SignUpOutcome.confirmationRequired
            ? state.notice(AppStrings.confirmEmailNotice)
            : state.idle();
      } else {
        await _repo.signIn(email: email, password: password);
        state = state.idle();
      }
    } on AppException catch (e) {
      state = state.failed(e.message);
    }
  }
}

final authControllerProvider =
    NotifierProvider.autoDispose<AuthController, AuthFormState>(AuthController.new);
