import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/logging/device_info.dart';

void main() {
  testWidgets('screen info has the size in dp, font scale and language', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    final info = readScreenInfo(tester.binding.platformDispatcher);

    expect(info['screen'], '411x914');
    expect(info['dpr'], 2.63);
    expect(info.keys, containsAll(['text_scale', 'system_locale', 'app_language', 'dark']));
  });
}
