/// Şərtlərin cari versiyası. Mətn mahiyyətcə dəyişəndə artır: yeni qeydiyyatlar bu versiya ilə yazılır.
const currentLegalVersion = 1;

enum LegalDocument { terms, privacy }

class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final String body;
}
