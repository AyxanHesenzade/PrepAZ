import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/legal_document.dart';
import '../legal_screen.dart';

/// Qeydiyyat formasının altındakı razılıq qutusu: sənəd adlarına basanda mətn açılır.
class SignUpConsent extends StatefulWidget {
  const SignUpConsent({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<SignUpConsent> createState() => _SignUpConsentState();
}

class _SignUpConsentState extends State<SignUpConsent> {
  late final _terms = TapGestureRecognizer()..onTap = () => _open(LegalDocument.terms);
  late final _privacy = TapGestureRecognizer()..onTap = () => _open(LegalDocument.privacy);

  void _open(LegalDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LegalDocumentScreen(document: document)),
    );
  }

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline);
    return Row(
      children: [
        Checkbox(
          value: widget.value,
          onChanged: (value) => widget.onChanged(value ?? false),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(text: AppStrings.legalConsentStart),
                TextSpan(text: AppStrings.legalConsentTerms, style: link, recognizer: _terms),
                TextSpan(text: AppStrings.legalConsentJoin),
                TextSpan(text: AppStrings.legalConsentPrivacy, style: link, recognizer: _privacy),
                TextSpan(text: AppStrings.legalConsentEnd),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
