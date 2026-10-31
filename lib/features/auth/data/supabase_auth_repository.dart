import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._auth);

  final GoTrueClient _auth;

  @override
  Stream<bool> watchSignedIn() async* {
    yield _auth.currentSession != null;
    yield* _auth.onAuthStateChange.map((state) => state.session != null);
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return guard(
      () => _auth.signInWithPassword(email: email, password: password),
      mapper: _mapAuthError,
    );
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final res = await _auth.signUp(email: email, password: password);
      if (res.session != null) return SignUpOutcome.signedIn;
      // Təsdiqli hesab olanda Supabase xəta vermir, boş identities qaytarır və məktub göndərmir.
      if (res.user?.identities?.isEmpty ?? false) {
        throw AccountExistsException();
      }
      return SignUpOutcome.confirmationRequired;
    }, mapper: _mapAuthError);
  }

  @override
  Future<void> resendConfirmation({required String email}) {
    return guard(
      () => _auth.resend(email: email, type: OtpType.signup),
      mapper: _mapAuthError,
    );
  }

  @override
  Future<void> signOut() => guard(_auth.signOut, mapper: _mapAuthError);

  static AppException? _mapAuthError(Object error) {
    if (error is! AuthException) return null;
    if (error is AuthRetryableFetchException) {
      return AppException(AppStrings.unknownError);
    }
    return switch (error.code) {
      'invalid_credentials' => AppException(
        AppStrings.invalidCredentials,
      ),
      'user_already_exists' => AccountExistsException(),
      'email_not_confirmed' => EmailNotConfirmedException(),
      'weak_password' => AppException(AppStrings.weakPassword),
      'email_address_invalid' => AppException(AppStrings.invalidEmail),
      'over_email_send_rate_limit' => AppException(AppStrings.emailRateLimit),
      _ => null,
    };
  }
}
