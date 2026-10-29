import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Bir mətn parçası: adi mətn və ya LaTeX düsturu.
class TextPart {
  const TextPart(this.text, {required this.isMath});

  final String text;
  final bool isMath;

  @override
  bool operator ==(Object other) =>
      other is TextPart && other.text == text && other.isMath == isMath;

  @override
  int get hashCode => Object.hash(text, isMath);

  @override
  String toString() => isMath ? 'math($text)' : 'text($text)';
}

/// "$x^2$ tənliyi" → [math(x^2), text( tənliyi)].
/// `\$` adi dollar işarəsidir. `$` işarələri cüt deyilsə, hamısı adi mətn sayılır.
List<TextPart> splitMath(String input) {
  final parts = <TextPart>[];
  final buffer = StringBuffer();
  var inMath = false;

  void flush() {
    if (buffer.isNotEmpty) parts.add(TextPart(buffer.toString(), isMath: inMath));
    buffer.clear();
  }

  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == r'\' && i + 1 < input.length && input[i + 1] == r'$') {
      buffer.write(inMath ? r'\$' : r'$');
      i++;
    } else if (ch == r'$') {
      flush();
      inMath = !inMath;
    } else {
      buffer.write(ch);
    }
  }
  if (inMath) {
    // bağlanmamış $: təhlükəsiz variant, hamısını mətn kimi göstər
    return [TextPart(input.replaceAll(r'\$', r'$'), isMath: false)];
  }
  flush();
  return parts;
}

/// Adi mətn ilə LaTeX düsturlarını bir sətirdə göstərir.
class MathText extends StatelessWidget {
  const MathText(this.source, {super.key, this.style});

  final String source;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[
      for (final part in splitMath(source))
        if (part.isMath)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              part.text,
              mathStyle: MathStyle.text,
              textStyle: base,
              onErrorFallback: (_) => Text(part.text, style: base),
            ),
          )
        else
          TextSpan(text: part.text),
    ];
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
