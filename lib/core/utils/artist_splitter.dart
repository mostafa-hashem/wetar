/// Splits multi-artist strings (e.g. "Artist A feat. Artist B & C")
/// using user-configurable separator tokens without corrupting single artist names.
class ArtistSplitter {
  ArtistSplitter._();

  static const List<String> defaultSeparators = <String>[
    'feat.',
    'ft.',
    'featuring',
    '&',
    ',',
    '،',
    ';',
    '/',
  ];

  static List<String> split(
    String? rawArtist, {
    List<String> separators = defaultSeparators,
    String fallback = 'Unknown Artist',
  }) {
    final trimmed = rawArtist?.trim() ?? '';
    if (trimmed.isEmpty) return <String>[fallback];
    if (separators.isEmpty) return <String>[trimmed];

    final escaped = separators
        .where((s) => s.trim().isNotEmpty)
        .map((s) {
          final clean = s.trim();
          // Require word boundaries around alphabetic separators like feat. or ft.
          if (RegExp(r'^[a-zA-Z]+\.?$').hasMatch(clean)) {
            return r'\s+' + RegExp.escape(clean) + r'\s+';
          }
          return r'\s*' + RegExp.escape(clean) + r'\s*';
        })
        .join('|');

    if (escaped.isEmpty) return <String>[trimmed];
    final parts = trimmed
        .split(RegExp(escaped, caseSensitive: false))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? <String>[fallback] : parts;
  }
}
