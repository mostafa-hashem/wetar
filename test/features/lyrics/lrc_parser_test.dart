import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/features/lyrics/domain/lrc_parser.dart';

void main() {
  group('LrcParser', () {
    test(
      'parses synced LRC timestamps, multi-timestamps, offset, and RTL script',
      () {
        const sample = '''
[ar:Fairuz]
[offset:500]
[00:12.50][00:45.00]أهواك وأتمنى لو أنساك
[00:25.100]Strings resonate in Cairo
''';
        final parsed = LrcParser.parse(sample);

        expect(parsed.isSynced, isTrue);
        expect(parsed.offsetMs, 500);
        expect(parsed.lines, hasLength(3));
        expect(parsed.lines[0].isRtl, isTrue);
        expect(
          parsed.lines[0].timestamp,
          const Duration(seconds: 12, milliseconds: 500),
        );
        expect(parsed.lines[1].isRtl, isFalse);
        expect(parsed.lines[2].timestamp, const Duration(seconds: 45));

        final idx = parsed.activeLineIndexAt(
          const Duration(seconds: 12, milliseconds: 100),
        );
        expect(idx, 0);
      },
    );

    test('falls back cleanly to plain unsynced lyrics', () {
      final parsed = LrcParser.parse('Line one\nسطر عربي');
      expect(parsed.isSynced, isFalse);
      expect(parsed.lines[0].isRtl, isFalse);
      expect(parsed.lines[1].isRtl, isTrue);
    });
  });
}
