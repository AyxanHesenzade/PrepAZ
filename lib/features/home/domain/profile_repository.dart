abstract interface class ProfileRepository {
  /// Ardıcıl məşq günləri. Serverdə avtomatik hesablanır, tətbiq dəyişə bilməz.
  Future<int> getStreakDays();
}
