import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/widgets/mascot/mascot.dart';
import 'package:prep_az/core/widgets/mascot/mascot_behavior.dart';
import 'package:prep_az/core/widgets/mascot/mascot_pose.dart';

void main() {
  Iterable<double> samples() => List.generate(1001, (i) => i / 1000);

  group('every behavior', () {
    for (final behavior in const <MascotBehavior>[TalkingMascot(), IdleMascot()]) {
      test('${behavior.runtimeType} loops without a visible jump', () {
        final start = behavior.poseAt(0);
        final end = behavior.poseAt(1);
        for (final (a, b) in [
          (start.lookX, end.lookX),
          (start.lift, end.lift),
          (start.tilt, end.tilt),
          (start.squash, end.squash),
          (start.armWave, end.armWave),
        ]) {
          expect(a, closeTo(b, 0.001));
        }
      });

      test('${behavior.runtimeType} keeps the eyes between open and closed', () {
        for (final t in samples()) {
          expect(behavior.poseAt(t).blink, inInclusiveRange(0, 1));
        }
      });
    }
  });

  group('IdleMascot', () {
    const idle = IdleMascot();
    final poses = samples().map(idle.poseAt).toList();
    double highest(double Function(MascotPose) of) =>
        poses.map(of).reduce((a, b) => a > b ? a : b);

    test('looks both left and right', () {
      expect(highest((p) => p.lookX), 1);
      expect(highest((p) => -p.lookX), 1);
    });

    test('jumps and squashes when it lands', () {
      expect(highest((p) => p.lift), greaterThan(0.15));
      expect(highest((p) => p.squash), greaterThan(0.1));
    });

    test('waves its hand', () => expect(highest((p) => p.armWave), greaterThan(0.9)));
  });

  testWidgets('moves only when allowed', (tester) async {
    Widget app({required bool animate, bool disable = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disable),
        child: Mascot(behavior: const IdleMascot(), animate: animate),
      ),
    );

    await tester.pumpWidget(app(animate: false));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(app(animate: true));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(app(animate: true, disable: true));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
