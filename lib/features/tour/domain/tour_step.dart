/// Öyrədici turun addımları, göstərilmə sırası ilə.
enum TourStep {
  welcome,
  openMenu,
  language,
  appearance,
  teachers,
  shareApp,
  report,
  legal,
  deleteAccount,
  signOut,
  practice,
  weakPlaces,
  mistakes,
  topics,
  offline,
  progress,
  compete,
  done;

  bool get inDrawer => index >= language.index && index <= signOut.index;

  bool get onSubjectCard => index >= practice.index && index <= offline.index;

  /// Alt menyunun düymələri (yalnız `MainShell`-də var).
  bool get onBottomNav => this == progress || this == compete;
}
