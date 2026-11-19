import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/widgets/app_bottom_sheet.dart';

void main() {
  testWidgets('the sheet ends above the system navigation bar', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    // Android-in alt düymələri: 48 px (edge-to-edge)
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppBottomSheet<void>(
              context: context,
              builder: (_) => const SizedBox(key: Key('content'), height: 100, width: double.infinity),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final bottom = tester.getBottomLeft(find.byKey(const Key('content'))).dy;
    expect(bottom, lessThanOrEqualTo(800 - 48));
  });
}
