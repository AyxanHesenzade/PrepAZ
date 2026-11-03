import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._db);

  final SupabaseClient _db;

  GoTrueClient get _auth => _db.auth;

  /// `GoogleSignIn.initialize` yalnız bir dəfə çağırılmalıdır.
  static Future<void>? _googleReady;

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
  Future<bool> signInWithGoogle() {
    return guard(() async {
      final google = GoogleSignIn.instance;
      await (_googleReady ??= google.initialize(
        serverClientId: AppConfig.googleWebClientId,
      ));
      final GoogleSignInAccount account;
      try {
        account = await google.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) return false;
        rethrow;
      }
      final idToken = account.authentication.idToken;
      if (idToken == null) throw AppException(AppStrings.googleSignInFailed);
      await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return true;
    }, mapper: _mapGoogleError);
  }

  @override
  Future<void> resendConfirmation({required String email}) {
    return guard(
      () => _auth.resend(email: email, type: OtpType.signup),
      mapper: _mapAuthError,
    );
  }

  @override
  Future<void> signOut() {
    return guard(() async {
      await _googleSignOut();
      await _auth.signOut();
    }, mapper: _mapAuthError);
  }

  /// Google hesabı yadda qalmasın: növbəti girişdə hesab seçimi yenidən açılır.
  Future<void> _googleSignOut() async {
    if (_googleReady == null) return;
    try {
      await GoogleSignIn.instance.signOut();
    } on Object {
      // Supabase çıxışı bundan asılı deyil.
    }
  }

  @override
  Future<void> deleteAccount() {
    return guard(() async {
      await _db.rpc<void>('delete_my_account');
      await _googleSignOut();
      await _auth.signOut(scope: SignOutScope.local);
    }, mapper: _mapDeleteError);
  }

  static AppException? _mapDeleteError(Object error) {
    if (error is PostgrestException &&
        error.message.contains('admin_account')) {
      return AppException(AppStrings.deleteAccountAdmin);
    }
    return _mapAuthError(error);
  }

  static AppException? _mapGoogleError(Object error) {
    if (error is GoogleSignInException) {
      return AppException(AppStrings.googleSignInFailed);
    }
    return _mapAuthError(error);
  }

  static AppException? _mapAuthError(Object error) {
    if (error is! AuthException) return null;
    if (error is AuthRetryableFetchException) {
      return AppException(AppStrings.unknownError);
    }
    return switch (error.code) {
      'invalid_credentials' => AppException(AppStrings.invalidCredentials),
      'user_already_exists' => AccountExistsException(),
      'email_not_confirmed' => EmailNotConfirmedException(),
      'weak_password' => AppException(AppStrings.weakPassword),
      'email_address_invalid' => AppException(AppStrings.invalidEmail),
      'over_email_send_rate_limit' => AppException(AppStrings.emailRateLimit),
      _ => null,
    };
  }
}
