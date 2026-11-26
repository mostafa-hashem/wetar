/// Numeral display preference: Western (0123) or Arabic-Indic (٠١٢٣).
enum NumeralStyle {
  western,
  arabicIndic;

  static NumeralStyle fromKey(String? raw) {
    return raw == 'arabicIndic'
        ? NumeralStyle.arabicIndic
        : NumeralStyle.western;
  }
}

/// Formats numbers and track durations respecting the user's numeral preference.
class NumeralFormatter {
  NumeralFormatter._();

  static const List<String> _arabicDigits = <String>[
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  static String formatString(String input, NumeralStyle style) {
    if (style == NumeralStyle.western) return input;
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(_arabicDigits[rune - 0x30]);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String formatInt(int value, NumeralStyle style) {
    return formatString(value.toString(), style);
  }

  static String formatDuration(Duration duration, NumeralStyle style) {
    final totalSeconds = duration.inSeconds.clamp(0, 359999);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final minStr = hours > 0 ? minutes.toString().padLeft(2, '0') : '$minutes';
    final secStr = seconds.toString().padLeft(2, '0');
    final raw = hours > 0 ? '$hours:$minStr:$secStr' : '$minStr:$secStr';
    return formatString(raw, style);
  }

  static String formatBytes(int bytes, NumeralStyle style) {
    if (bytes < 1024) return formatString('$bytes B', style);
    if (bytes < 1024 * 1024) {
      return formatString('${(bytes / 1024).toStringAsFixed(1)} KB', style);
    }
    return formatString(
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB',
      style,
    );
  }

  /// Shortens long storage paths while keeping folder hierarchy recognizable.
  static String shortenPath(String path) {
    var display = path;
    if (display.startsWith('/storage/emulated/0')) {
      display = display.replaceFirst('/storage/emulated/0', 'Internal');
    } else if (display.startsWith('/Users/')) {
      final parts = display.split('/');
      if (parts.length > 3) {
        display = '~/${parts.skip(3).join('/')}';
      }
    }
    return display;
  }
}
