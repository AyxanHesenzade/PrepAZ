import '../../../core/constants/app_strings.dart';
import '../../../core/error/app_exception.dart';

enum SignUpOutcome { signedIn, confirmationRequired }

/// Hesab var, amma e-poçt təsdiqlənməyib: UI gözləmə ekranına keçir.
class EmailNotConfirmedException extends AppException {
  EmailNotConfirmedException() : super(AppStrings.emailNotConfirmed);
}

/// Bu e-poçtla hesab artıq var: UI girişə keçir.
class AccountExistsException extends AppException {
  AccountExistsException() : super(AppStrings.userAlreadyExists);
}

/// UI yalnız bu interfeysi tanıyır; Supabase detalları data qatındadır.
abstract interface class AuthRepository {
  /// İlk dəyəri dərhal verir, sonra hər giriş/çıxışda yenisini.
  Stream<bool> watchSignedIn();

  Future<void> signIn({required String email, required String password});

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  });

  Future<void> resendConfirmation({required String email});

  Future<void> signOut();

  /// Hesabı və ona bağlı bütün məlumatları birdəfəlik silir, sonra çıxış edir.
  Future<void> deleteAccount();
}
