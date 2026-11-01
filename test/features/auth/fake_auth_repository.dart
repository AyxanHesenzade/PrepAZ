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

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<SignUpOutcome> signUp({required String email, required String password}) async {
    if (signUpError != null) throw signUpError!;
    return signUpOutcome;
  }

  @override
  Future<void> resendConfirmation({required String email}) async {
    if (resendError != null) throw resendError!;
    resentTo.add(email);
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
