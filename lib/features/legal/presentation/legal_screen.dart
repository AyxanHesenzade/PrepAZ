import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/legal_texts.dart';
import '../domain/legal_document.dart';

String legalTitle(LegalDocument document) => switch (document) {
  LegalDocument.terms => AppStrings.legalTermsTitle,
  LegalDocument.privacy => AppStrings.legalPrivacyTitle,
};

/// Sənədlərə keçid sətirləri: razılıq ekranında və yan menyudan açılan ekranda.
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final document in LegalDocument.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.description_outlined, size: 20),
            title: Text(legalTitle(document)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => LegalDocumentScreen(document: document)),
            ),
          ),
      ],
    );
  }
}

/// Yan menyudan açılır: qəbul edilmiş sənədləri sonradan oxumaq üçün.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.legalMenuTitle)),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: LegalLinks(),
        ),
      ),
    );
  }
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(legalTitle(document))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Text(AppStrings.legalLastUpdated, style: text.bodySmall),
            for (final section in legalSections(document, AppStrings.language)) ...[
              AppSpacing.gapL,
              Text(section.heading, style: text.titleSmall),
              const SizedBox(height: AppSpacing.s),
              Text(section.body, style: text.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
