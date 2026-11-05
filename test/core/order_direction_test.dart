import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// postgrest-də `.order(column)` defolt olaraq AZALAN sıradır (`ascending = false`).
/// İstiqamət yazılmayanda suallar sondan başlayır, "son cavab həlledicidir" isə tərsinə işləyir.
/// Bu test lib/ içindəki hər `.order(` çağırışında `ascending:` tələb edir.
void main() {
  test('every .order( call in lib/ states ascending: explicitly', () {
    final missing = <String>[];
    var calls = 0;
    final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final match in RegExp(r'\.order\(').allMatches(source)) {
        calls++;
        final args = _argumentsFrom(source, match.end);
        if (!RegExp(r'\bascending\s*:').hasMatch(args)) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
          missing.add('${file.path}:$line  .order($args)');
        }
      }
    }
    expect(calls, greaterThan(0), reason: 'the scan found no .order( calls: the test itself is broken');
    expect(missing, isEmpty, reason: 'add ascending: true (or a deliberate false) to:\n${missing.join('\n')}');
  });

  test('the scanner catches a call without a direction', () {
    expect(_argumentsFrom(".order('code').limit(5)", 7), "'code'");
    expect(_argumentsFrom(".order('id', ascending: true)", 7), "'id', ascending: true");
    expect(_argumentsFrom(".order(f('x'), ascending: false)", 7), "f('x'), ascending: false");
  });
}

/// `(` -dan sonrakı mətni bağlayan `)`-a qədər qaytarır (iç-içə mötərizələr nəzərə alınır).
String _argumentsFrom(String source, int start) {
  var depth = 1;
  for (var i = start; i < source.length; i++) {
    final c = source[i];
    if (c == '(') depth++;
    if (c == ')' && --depth == 0) return source.substring(start, i);
  }
  return source.substring(start);
}
