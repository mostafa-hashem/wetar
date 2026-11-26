/// Arabic-aware search and indexing normalizer.
/// Strips tashkeel/diacritics, tatweel, normalizes alef/ya/ta marbuta forms,
/// and converts Arabic-Indic digits to Western digits for consistent matching.
class ArabicNormalizer {
  ArabicNormalizer._();

  static final RegExp _diacriticsAndTatweel = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u0640]',
  );
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _arabicScript = RegExp(r'[\u0600-\u06FF]');

  static String normalize(String input) {
    if (input.isEmpty) return '';
    final stripped = input.replaceAll(_diacriticsAndTatweel, '');
    final buffer = StringBuffer();
    for (final rune in stripped.runes) {
      switch (rune) {
        // Alef variants (أ إ آ ٱ) -> ا
        case 0x0622:
        case 0x0623:
        case 0x0625:
        case 0x0671:
          buffer.writeCharCode(0x0627);
        // Alef maqsura (ى) & Farsi yeh (ی) -> ي
        case 0x0649:
        case 0x06CC:
          buffer.writeCharCode(0x064A);
        // Ta marbuta (ة) -> ه
        case 0x0629:
          buffer.writeCharCode(0x0647);
        // Yeh with hamza (ئ) / Waw with hamza (ؤ)
        case 0x0624:
          buffer.writeCharCode(0x0648);
        case 0x0626:
          buffer.writeCharCode(0x064A);
        // Kaf variant (ک) -> ك
        case 0x06A9:
          buffer.writeCharCode(0x0643);
        default:
          // Normalize Arabic-Indic digits (٠-٩) and Eastern Arabic digits (۰-۹).
          if (rune >= 0x0660 && rune <= 0x0669) {
            buffer.writeCharCode(0x0030 + (rune - 0x0660));
          } else if (rune >= 0x06F0 && rune <= 0x06F9) {
            buffer.writeCharCode(0x0030 + (rune - 0x06F0));
          } else {
            buffer.writeCharCode(rune);
          }
      }
    }
    return buffer.toString().toLowerCase().replaceAll(_whitespace, ' ').trim();
  }

  /// Returns true when the text starts with or predominantly contains Arabic letters.
  static bool isArabicText(String input) {
    return _arabicScript.hasMatch(input);
  }

  /// Returns an index key ('#' for digits/symbols, or normalized first letter)
  /// suitable for Wetar's fast alphabet scroll rail.
  static String indexLetter(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '#';
    final normalized = normalize(trimmed);
    if (normalized.isEmpty) return '#';
    final first = normalized.substring(0, 1).toUpperCase();
    final code = first.codeUnitAt(0);
    if (code >= 0x30 && code <= 0x39) return '#';
    if ((code >= 0x41 && code <= 0x5A) || (code >= 0x0621 && code <= 0x064A)) {
      return first;
    }
    return '#';
  }
}
