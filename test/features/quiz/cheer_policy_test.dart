import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/quiz/domain/cheer_policy.dart';

/// `'++-+'` kimi yazılır: `+` düz, `-` səhv.
List<bool> run(String s) => [for (final c in s.split('')) c == '+'];

void main() {
  group('praise for correct streaks', () {
    test('nothing for the first two, then a cheer at exactly 3', () {
      expect(CheerPolicy.after(run('+')), isNull);
      expect(CheerPolicy.after(run('++')), isNull);
      expect(CheerPolicy.after(run('+++')), const Cheer(CheerKind.three, 3));
    });

    test('4 is silent, 5 cheers again', () {
      expect(CheerPolicy.after(run('++++')), isNull);
      expect(CheerPolicy.after(run('+++++')), const Cheer(CheerKind.five, 5));
    });

    test('6 to 9 are silent', () {
      for (var n = 6; n <= 9; n++) {
        expect(CheerPolicy.after(run('+' * n)), isNull, reason: '$n');
      }
    });

    test('10, 15 and 20 are the big ones', () {
      for (final n in [10, 15, 20]) {
        expect(CheerPolicy.after(run('+' * n)), Cheer(CheerKind.big, n), reason: '$n');
      }
    });

    test('between the big ones it stays silent', () {
      for (final n in [11, 12, 13, 14, 16, 17, 18, 19]) {
        expect(CheerPolicy.after(run('+' * n)), isNull, reason: '$n');
      }
    });

    test('the streak counts only the trailing correct answers', () {
      expect(CheerPolicy.after(run('+++-+++')), const Cheer(CheerKind.three, 3), reason: 'a new streak of 3');
      expect(CheerPolicy.after(run('+++-++')), isNull);
    });

    test('a streak after a wrong answer starts from zero', () {
      expect(CheerPolicy.after(run('+++++-+++++')), const Cheer(CheerKind.five, 5));
    });
  });

  group('a wrong answer', () {
    test('after a long streak: encouragement, with the length of the streak that broke', () {
      expect(CheerPolicy.after(run('+++++-')), const Cheer(CheerKind.comeback, 5));
      expect(CheerPolicy.after(run('++++++++-')), const Cheer(CheerKind.comeback, 8));
      expect(CheerPolicy.after(run('+' * 20 + '-')), const Cheer(CheerKind.comeback, 20));
    });

    test('after a short streak: nothing (no need to make a fuss)', () {
      expect(CheerPolicy.after(run('-')), isNull);
      expect(CheerPolicy.after(run('+-')), isNull);
      expect(CheerPolicy.after(run('++++-')), isNull, reason: '4 is below the threshold');
    });

    test('a run of wrong answers never gets a message, however long', () {
      for (var n = 1; n <= 10; n++) {
        expect(CheerPolicy.after(run('-' * n)), isNull, reason: '$n wrong in a row');
      }
    });

    test('the second wrong in a row is silent even right after a long streak', () {
      expect(CheerPolicy.after(run('+++++--')), isNull);
      expect(CheerPolicy.after(run('++++++++++--------')), isNull, reason: '8 wrong in a row after 10 right');
    });

    test('after wrongs the next correct answers rebuild a streak', () {
      expect(CheerPolicy.after(run('--------+++')), const Cheer(CheerKind.three, 3));
    });
  });

  test('an empty session has nothing to say', () {
    expect(CheerPolicy.after(const []), isNull);
  });
}
