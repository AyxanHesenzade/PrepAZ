import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/logging/app_log.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

/// [email]: ünvan yazılır; [code]: məktubdakı kod və yeni parol yazılır.
enum ResetStep { email, code }

class PasswordResetState {
  const PasswordResetState({
    this.step = ResetStep.email,
    this.email = '',
    this.isBusy = false,
    this.error,
    this.info,
  });

  final ResetStep step;
  final String email;
  final bool isBusy;
  final String? error;
  final String? info;

  PasswordResetState copy({
    ResetStep? step,
    String? email,
    bool isBusy = false,
    String? error,
    String? info,
  }) => PasswordResetState(
    step: step ?? this.step,
    email: email ?? this.email,
    isBusy: isBusy,
    error: error,
    info: info,
  );
}

class PasswordResetController extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// İlk göndərişdə kod addımına keçir; kod addımında "yenidən göndərildi" deyir.
  Future<void> sendCode(String email) async {
    if (state.isBusy) return;
    final resend = state.step == ResetStep.code;
    state = state.copy(email: email, isBusy: true);
    try {
      await _repo.sendPasswordResetCode(email: email);
      _log('reset_code_sent', email);
      if (!ref.mounted) return;
      state = state.copy(
        step: ResetStep.code,
        info: resend ? AppStrings.resetCodeResent : null,
      );
    } on AppException catch (e) {
      _log('reset_code_failed', email, e.message);
      if (ref.mounted) state = state.copy(error: e.message);
    }
  }

  Future<void> resendCode() => sendCode(state.email);

  /// Uğurda istifadəçi daxil olur və AuthGate özü yönləndirir.
  Future<void> confirm({
    required String code,
    required String newPassword,
  }) async {
    if (state.isBusy) return;
    state = state.copy(isBusy: true);
    try {
      await _repo.resetPassword(
        email: state.email,
        code: code.replaceAll(' ', ''),
        newPassword: newPassword,
      );
      _log('reset_ok', state.email);
      if (ref.mounted) state = state.copy();
    } on AppException catch (e) {
      _log('reset_failed', state.email, e.message);
      if (ref.mounted) state = state.copy(error: e.message);
    }
  }

  static void _log(String name, String email, [String? message]) =>
      AppLog.auth(name, message: message, meta: {'email': email.trim().toLowerCase()});

  void changeEmail() {
    if (!state.isBusy) state = PasswordResetState(email: state.email);
  }
}

final passwordResetControllerProvider =
    NotifierProvider.autoDispose<PasswordResetController, PasswordResetState>(
      PasswordResetController.new,
    );
