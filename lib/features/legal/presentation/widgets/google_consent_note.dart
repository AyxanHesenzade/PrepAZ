import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/legal_document.dart';
import '../legal_screen.dart';

/// Google ilə davam et düyməsinin altında: qutu yoxdur, davam etmək razılıq sayılır.
class GoogleConsentNote extends StatefulWidget {
  const GoogleConsentNote({super.key});

  @override
  State<GoogleConsentNote> createState() => _GoogleConsentNoteState();
}

class _GoogleConsentNoteState extends State<GoogleConsentNote> {
  late final _terms = TapGestureRecognizer()
    ..onTap = () => _open(LegalDocument.terms);
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => _open(LegalDocument.privacy);

  void _open(LegalDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentScreen(document: document),
      ),
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
    final link = TextStyle(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: theme.textTheme.bodySmall,
        children: [
          TextSpan(text: AppStrings.googleConsentStart),
          TextSpan(
            text: AppStrings.legalConsentTerms,
            style: link,
            recognizer: _terms,
          ),
          TextSpan(text: AppStrings.legalConsentJoin),
          TextSpan(
            text: AppStrings.legalConsentPrivacy,
            style: link,
            recognizer: _privacy,
          ),
          TextSpan(text: AppStrings.googleConsentEnd),
        ],
      ),
    );
  }
}
