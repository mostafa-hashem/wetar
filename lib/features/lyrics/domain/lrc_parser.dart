import 'package:equatable/equatable.dart';
import 'package:wetar/core/utils/arabic_normalizer.dart';

class LyricLine extends Equatable {
  const LyricLine({
    required this.timestamp,
    required this.text,
    required this.isRtl,
  });

  final Duration? timestamp;
  final String text;
  final bool isRtl;

  @override
  List<Object?> get props => [timestamp, text, isRtl];
}

class ParsedLyrics extends Equatable {
  const ParsedLyrics({
    required this.lines,
    required this.isSynced,
    this.offsetMs = 0,
  });

  final List<LyricLine> lines;
  final bool isSynced;
  final int offsetMs;

  int activeLineIndexAt(Duration position, {int userOffsetMs = 0}) {
    if (!isSynced || lines.isEmpty) return -1;
    final adjustedMs = position.inMilliseconds + offsetMs + userOffsetMs;
    var active = -1;
    for (var i = 0; i < lines.length; i++) {
      final ts = lines[i].timestamp;
      if (ts != null && ts.inMilliseconds <= adjustedMs) {
        active = i;
      }
    }
    return active;
  }

  @override
  List<Object?> get props => [lines, isSynced, offsetMs];
}

/// Pure-Dart LRC & plain lyrics parser supporting multi-timestamps, `[offset:]`,
/// and automatic Arabic RTL / English LTR per-line direction detection.
class LrcParser {
  LrcParser._();

  static final RegExp _timeTagRegex = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );
  static final RegExp _offsetTagRegex = RegExp(
    r'^\[offset:([+-]?\d+)\]$',
    caseSensitive: false,
  );
  static final RegExp _metaTagRegex = RegExp(
    r'^\[(ar|ti|al|au|by|length|re|ve):.*\]$',
    caseSensitive: false,
  );

  static ParsedLyrics parse(String rawContent) {
    final normalized = rawContent.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return const ParsedLyrics(lines: <LyricLine>[], isSynced: false);
    }

    var fileOffsetMs = 0;
    final syncedLines = <LyricLine>[];
    final plainLines = <LyricLine>[];

    for (final rawLine in normalized.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final offsetMatch = _offsetTagRegex.firstMatch(line);
      if (offsetMatch != null) {
        fileOffsetMs = int.tryParse(offsetMatch.group(1) ?? '0') ?? 0;
        continue;
      }
      if (_metaTagRegex.hasMatch(line)) continue;

      final matches = _timeTagRegex.allMatches(line).toList();
      if (matches.isNotEmpty) {
        final lyricText = line.replaceAll(_timeTagRegex, '').trim();
        if (lyricText.isEmpty) continue;
        final isRtl = ArabicNormalizer.isArabicText(lyricText);
        for (final m in matches) {
          final minutes = int.parse(m.group(1)!);
          final seconds = int.parse(m.group(2)!);
          final fracStr = m.group(3) ?? '0';
          final millis = fracStr.length == 1
              ? int.parse(fracStr) * 100
              : (fracStr.length == 2
                    ? int.parse(fracStr) * 10
                    : int.parse(fracStr.substring(0, 3)));
          final ts = Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: millis,
          );
          syncedLines.add(
            LyricLine(timestamp: ts, text: lyricText, isRtl: isRtl),
          );
        }
      } else {
        plainLines.add(
          LyricLine(
            timestamp: null,
            text: line,
            isRtl: ArabicNormalizer.isArabicText(line),
          ),
        );
      }
    }

    if (syncedLines.isNotEmpty) {
      syncedLines.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
      return ParsedLyrics(
        lines: syncedLines,
        isSynced: true,
        offsetMs: fileOffsetMs,
      );
    }
    return ParsedLyrics(
      lines: plainLines,
      isSynced: false,
      offsetMs: fileOffsetMs,
    );
  }
}
