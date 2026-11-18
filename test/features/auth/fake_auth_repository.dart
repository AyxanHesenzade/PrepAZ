import 'package:prep_az/features/auth/domain/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  Object? signInError;
  Object? signUpError;
  Object? resendError;
  SignUpOutcome signUpOutcome = SignUpOutcome.signedIn;
  int signInCalls = 0;
  String? lastSignInEmail;
  String? lastSignInPassword;
  final resentTo = <String>[];
  Object? deleteError;
  int deleteCalls = 0;
  Object? googleError;
  bool googleCancelled = false;
  int googleCalls = 0;

  @override
  Future<bool> signInWithGoogle() async {
    googleCalls++;
    if (googleError != null) throw googleError!;
    return !googleCancelled;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    if (signUpError != null) throw signUpError!;
    return signUpOutcome;
  }

  @override
  Future<void> resendConfirmation({required String email}) async {
    if (resendError != null) throw resendError!;
    resentTo.add(email);
  }

  Object? resetCodeError;
  Object? resetError;
  final resetCodesSentTo = <String>[];
  String? lastResetEmail;
  String? lastResetCode;
  String? lastNewPassword;

  @override
  Future<void> sendPasswordResetCode({required String email}) async {
    if (resetCodeError != null) throw resetCodeError!;
    resetCodesSentTo.add(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    lastResetEmail = email;
    lastResetCode = code;
    lastNewPassword = newPassword;
    if (resetError != null) throw resetError!;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    if (deleteError != null) throw deleteError!;
  }

  @override
  Stream<bool> watchSignedIn() => Stream.value(false);
}
