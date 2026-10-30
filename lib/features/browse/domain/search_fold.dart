/// Axtarış üçün mətni sadələşdirir: böyük/kiçik hərf və Azərbaycan diakritikləri (ə→e, ı→i, ş→s …) fərq salmır.
String foldForSearch(String text) {
  const map = {
    'İ': 'i',
    'I': 'i',
    'ı': 'i',
    'ə': 'e',
    'Ə': 'e',
    'ö': 'o',
    'Ö': 'o',
    'ü': 'u',
    'Ü': 'u',
    'ş': 's',
    'Ş': 's',
    'ç': 'c',
    'Ç': 'c',
    'ğ': 'g',
    'Ğ': 'g',
  };
  final b = StringBuffer();
  for (final ch in text.runes.map(String.fromCharCode)) {
    b.write(map[ch] ?? ch.toLowerCase());
  }
  return b.toString().trim();
}
