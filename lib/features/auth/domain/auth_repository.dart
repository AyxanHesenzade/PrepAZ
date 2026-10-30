enum SignUpOutcome { signedIn, confirmationRequired }

/// UI yalnız bu interfeysi tanıyır; Supabase detalları data qatındadır.
abstract interface class AuthRepository {
  /// İlk dəyəri dərhal verir, sonra hər giriş/çıxışda yenisini.
  Stream<bool> watchSignedIn();

  Future<void> signIn({required String email, required String password});

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
