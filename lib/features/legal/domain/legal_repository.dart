abstract interface class LegalRepository {
  /// Daxil olmuş istifadəçinin [version]-u qəbul etdiyini qeyd edir; təkrar çağırış zərərsizdir.
  Future<void> recordAcceptance(int version);
}
