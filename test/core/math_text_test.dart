import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/widgets/math_text.dart';

void main() {
  group('splitMath', () {
    test('splits text and math', () {
      expect(
        splitMath(r'$x^2$ tənliyi'),
        const [TextPart('x^2', isMath: true), TextPart(' tənliyi', isMath: false)],
      );
    });

    test('keeps chemistry formulas in mathrm form as one math part', () {
      expect(
        splitMath(r'Turşu $\mathrm{H_{2}SO_{4}}$ və $\mathrm{Fe^{3+}}$ ionu'),
        const [
          TextPart('Turşu ', isMath: false),
          TextPart(r'\mathrm{H_{2}SO_{4}}', isMath: true),
          TextPart(' və ', isMath: false),
          TextPart(r'\mathrm{Fe^{3+}}', isMath: true),
          TextPart(' ionu', isMath: false),
        ],
      );
    });

    test('escaped dollar is a normal character', () {
      expect(splitMath(r'Qiymət 5\$'), const [TextPart(r'Qiymət 5$', isMath: false)]);
    });

    test('unbalanced dollar falls back to plain text', () {
      expect(splitMath(r'a $ b'), const [TextPart(r'a $ b', isMath: false)]);
    });

    test('plain text and empty input', () {
      expect(splitMath('sadə mətn'), const [TextPart('sadə mətn', isMath: false)]);
      expect(splitMath(''), isEmpty);
    });
  });

  group('MathText', () {
    testWidgets('renders every kind of formula the importer produces without throwing', (tester) async {
      const samples = [
        r'$\mathrm{H_{2}SO_{4}}$',
        r'$\mathrm{Fe^{3+}}$',
        r'$\mathrm{2H_{2} + O_{2} \rightarrow 2H_{2}O}$',
        r'$\mathrm{N_{2} + 3H_{2} \rightleftharpoons 2NH_{3}}$',
        r'$\mathrm{BaSO_{4} \downarrow}$',
        r'$\mathrm{CH_{2}=CH_{2}}$',
        r'$\mathrm{(NH_{4})_{2}SO_{4}}$',
        r'$\mathrm{C_{n}H_{2n}}$',
        r'$\mathrm{k \cdot [N_{2}] \cdot [H_{2}]^{3}}$',
        r'$\mathrm{A_{r}(X) < A_{r}(Y)}$',
        r'$\mathrm{\omega_{1}}$',
      ];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListView(children: [for (final s in samples) MathText(s)]),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.byType(MathText), findsNWidgets(samples.length));
    });
  });
}
