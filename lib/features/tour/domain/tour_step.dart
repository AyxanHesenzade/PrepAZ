/// Öyrədici turun addımları, göstərilmə sırası ilə.
enum TourStep {
  welcome,
  openMenu,
  language,
  appearance,
  teachers,
  report,
  signOut,
  practice,
  weakPlaces,
  mistakes,
  topics,
  done;

  bool get inDrawer => index >= language.index && index <= signOut.index;

  bool get onSubjectCard => index >= practice.index && index <= topics.index;
}
