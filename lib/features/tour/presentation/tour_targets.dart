import 'package:flutter/material.dart';

import '../domain/tour_step.dart';

/// Turun göstərdiyi elementlərin açarları. Ekranlar bunları öz widget-lərinə taxır.
class TourTargets {
  TourTargets({this.hasBottomNav = false});

  /// Alt menyu yalnız `MainShell`-də var; ana ekran tək açılanda onun addımları atlanır.
  final bool hasBottomNav;

  final scaffold = GlobalKey<ScaffoldState>();
  final menuButton = GlobalKey();
  final language = GlobalKey();
  final appearance = GlobalKey();
  final teachers = GlobalKey();
  final shareApp = GlobalKey();
  final report = GlobalKey();
  final legal = GlobalKey();
  final deleteAccount = GlobalKey();
  final signOut = GlobalKey();
  final practice = GlobalKey();
  final weakPlaces = GlobalKey();
  final mistakes = GlobalKey();
  final topics = GlobalKey();
  final offline = GlobalKey();
  final progress = GlobalKey();
  final compete = GlobalKey();

  GlobalKey? keyFor(TourStep step) => switch (step) {
    TourStep.welcome || TourStep.done => null,
    TourStep.openMenu => menuButton,
    TourStep.language => language,
    TourStep.appearance => appearance,
    TourStep.teachers => teachers,
    TourStep.shareApp => shareApp,
    TourStep.report => report,
    TourStep.legal => legal,
    TourStep.deleteAccount => deleteAccount,
    TourStep.signOut => signOut,
    TourStep.practice => practice,
    TourStep.weakPlaces => weakPlaces,
    TourStep.mistakes => mistakes,
    TourStep.topics => topics,
    TourStep.offline => offline,
    TourStep.progress => progress,
    TourStep.compete => compete,
  };
}

/// Açarları ana ekranın və alt menyunun widget-lərinə çatdırır. Açarlar `MainShell`-in (ana ekran tək
/// açılanda `HomeScreen`-in) State-indədir, qlobal
/// saxlanmamalıdır: dil dəyişəndə MaterialApp yenidən qurulur və qlobal GlobalKey köhnə ekranı
/// (açıq yan menyu ilə) yeni ağaca köçürür, tətbiq donur.
class TourScope extends InheritedWidget {
  const TourScope({super.key, required this.targets, required super.child});

  final TourTargets targets;

  /// Ana ekrandan kənarda (məs. testdə tək yan menyu) null-dur.
  /// Asılılıq yaratmır: açarlar State yaşadıqca dəyişmir.
  static TourTargets? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TourScope>()?.targets;

  @override
  bool updateShouldNotify(TourScope oldWidget) => false;
}
