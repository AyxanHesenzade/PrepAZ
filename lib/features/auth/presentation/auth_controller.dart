import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

/// [choose]: istifadəçi hələ yeni olub-olmadığını seçməyib.
enum AuthMode { choose, signIn, signUp }

class AuthFormState {
  const AuthFormState({
    this.mode = AuthMode.choose,
    this.isBusy = false,
    this.error,
    this.info,
    this.pendingEmail,
  });

  final AuthMode mode;
  final bool isBusy;
  final String? error;
  final String? info;

  /// Təsdiq gözləyən e-poçt. Doludursa, ekranda forma yox, təlimat göstərilir.
  final String? pendingEmail;

  bool get isChoosing => mode == AuthMode.choose;
  bool get isSignUp => mode == AuthMode.signUp;
  bool get awaitingConfirmation => pendingEmail != null;

  AuthFormState busy() =>
      AuthFormState(mode: mode, isBusy: true, pendingEmail: pendingEmail);
  AuthFormState failed(String message) =>
      AuthFormState(mode: mode, error: message, pendingEmail: pendingEmail);
  AuthFormState notice(String message) =>
      AuthFormState(mode: mode, info: message, pendingEmail: pendingEmail);
  AuthFormState idle() => AuthFormState(mode: mode, pendingEmail: pendingEmail);
}

class AuthController extends Notifier<AuthFormState> {
  /// Təsdiqdən sonra parolu yenidən yazdırmamaq üçün. Yalnız yaddaşda qalır.
  String _pendingPassword = '';

  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  void setMode(AuthMode mode) {
    if (mode != state.mode) state = AuthFormState(mode: mode);
  }

  /// Uğurlu girişdən sonra heç nə etmirik: AuthGate sessiya dəyişikliyini görüb özü yönləndirir.
  Future<void> submit({required String email, required String password}) async {
    if (state.isBusy) return;
    final signUp = state.isSignUp;
    state = state.busy();
    try {
      if (signUp) {
        final outcome = await _repo.signUp(email: email, password: password);
        if (outcome == SignUpOutcome.confirmationRequired) {
          _awaitConfirmation(email, password);
        } else {
          state = state.idle();
        }
      } else {
        await _repo.signIn(email: email, password: password);
        state = state.idle();
      }
    } on EmailNotConfirmedException {
      _awaitConfirmation(email, password);
    } on AccountExistsException catch (e) {
      state = AuthFormState(mode: AuthMode.signIn, error: e.message);
    } on AppException catch (e) {
      state = state.failed(e.message);
    }
  }

  void _awaitConfirmation(String email, String password) {
    _pendingPassword = password;
    state = AuthFormState(mode: state.mode, pendingEmail: email);
  }

  /// "Təsdiqlədim" düyməsi: alınmasa, səbəbi göstərilir.
  Future<void> checkConfirmed() async {
    final email = state.pendingEmail;
    if (email == null || state.isBusy) return;
    state = state.busy();
    try {
      await _repo.signIn(email: email, password: _pendingPassword);
      if (ref.mounted) state = state.idle();
    } on EmailNotConfirmedException {
      if (ref.mounted) state = state.failed(AppStrings.emailStillNotConfirmed);
    } on AppException catch (e) {
      if (ref.mounted) state = state.failed(e.message);
    }
  }

  /// Tətbiqə qayıdanda səssiz yoxlama: hələ təsdiqlənməyibsə, ekranda heç nə dəyişmir.
  Future<void> checkConfirmedSilently() async {
    final email = state.pendingEmail;
    if (email == null || state.isBusy) return;
    try {
      await _repo.signIn(email: email, password: _pendingPassword);
    } on AppException {
      return;
    }
  }

  Future<void> resendConfirmation() async {
    final email = state.pendingEmail;
    if (email == null || state.isBusy) return;
    state = state.busy();
    try {
      await _repo.resendConfirmation(email: email);
      if (ref.mounted) state = state.notice(AppStrings.confirmationResent);
    } on AppException catch (e) {
      if (ref.mounted) state = state.failed(e.message);
    }
  }

  /// Gözləmə ekranından formaya qayıdır (məs. e-poçt səhv yazılıb).
  void cancelConfirmation() {
    _pendingPassword = '';
    state = AuthFormState(mode: state.mode);
  }
}

final authControllerProvider =
    NotifierProvider.autoDispose<AuthController, AuthFormState>(
      AuthController.new,
    );
