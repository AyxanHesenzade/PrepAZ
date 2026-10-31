import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts a normal address', () => expect(Validators.email(' a@b.az '), isNull));
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('rejects null', () => expect(Validators.email(null), isNotNull));
    test('rejects missing @', () => expect(Validators.email('abc.az'), isNotNull));
    test('rejects a missing domain', () => expect(Validators.email('ad@gmail'), isNotNull));
  });

  group('Validators.password', () {
    test('accepts min length', () => expect(Validators.password('123456'), isNull));
    test('rejects short', () => expect(Validators.password('12345'), isNotNull));
    test('rejects null', () => expect(Validators.password(null), isNotNull));
  });
}
