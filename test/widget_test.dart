import 'package:flutter_test/flutter_test.dart';
import 'package:wetar/core/utils/arabic_normalizer.dart';
import 'package:wetar/core/utils/artist_splitter.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';

void main() {
  group('ArabicNormalizer', () {
    test('strips tashkeel and normalizes alef, ya, and ta marbuta', () {
      expect(
        ArabicNormalizer.normalize('أُغْنِيَةٌ جَمِيلَةٌ عَلَى عُودٍ'),
        'اغنيه جميله علي عود',
      );
      expect(
        ArabicNormalizer.normalize('إِبْرَاهِيمُ — آلَاتُ مُوسِيقَى'),
        'ابراهيم — الات موسيقي',
      );
    });

    test('normalizes Arabic-Indic digits to ASCII digits', () {
      expect(ArabicNormalizer.normalize('تراك ٢٠٢٦ ١٢'), 'تراك 2026 12');
    });

    test('extracts index letter cleanly for Arabic and Latin titles', () {
      expect(ArabicNormalizer.indexLetter('أهواك'), 'ا');
      expect(ArabicNormalizer.indexLetter('Zay El Hawa'), 'Z');
      expect(ArabicNormalizer.indexLetter('1999 Intro'), '#');
    });
  });

  group('ArtistSplitter & NumeralFormatter', () {
    test('splits multi-artist separators cleanly', () {
      expect(
        ArtistSplitter.split('Amr Diab feat. Sherine & Mohamed Mounir'),
        <String>['Amr Diab', 'Sherine', 'Mohamed Mounir'],
      );
    });

    test('formats durations with Western and Arabic-Indic numerals', () {
      const d = Duration(minutes: 4, seconds: 7);
      expect(NumeralFormatter.formatDuration(d, NumeralStyle.western), '4:07');
      expect(
        NumeralFormatter.formatDuration(d, NumeralStyle.arabicIndic),
        '٤:٠٧',
      );
    });
  });
}
