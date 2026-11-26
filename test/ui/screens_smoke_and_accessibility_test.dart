import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/widgets/track_list_tile.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'renders TrackListTile in Arabic RTL and 200% text scale without overflow',
    (tester) async {
      const sampleTrack = WetarTrack(
        stableKey: '/music/test.mp3',
        folderId: 1,
        uri: 'file:///music/test.mp3',
        filePath: '/music/test.mp3',
        folderPath: '/music',
        title: 'مقطوعة عود هادئة طويلة جداً للاختبار البصري',
        artist: 'فريد الأطرش',
        album: 'مختارات شرقية',
        albumArtist: 'فريد الأطرش',
        genre: 'Oriental',
        year: 1965,
        trackNumber: 1,
        discNumber: 1,
        durationMs: 245000,
        bitrateKbps: 320,
        sampleRateHz: 44100,
        channels: 2,
        sizeBytes: 9400000,
        mimeType: 'audio/mpeg',
        dateModifiedSec: 1000,
        dateAddedSec: 1000,
      );

      final theme = WetarTokenResolver.buildThemeData(
        const AppearanceSettings(listDensity: ListDensity.spacious),
        platformBrightness: Brightness.dark,
        systemDisableAnimations: false,
        isArabicLocale: true,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: theme,
            home: Scaffold(
              body: TrackListTile(
                track: sampleTrack,
                isPlayingTrack: true,
                showArtwork: true,
                numeralStyle: NumeralStyle.arabicIndic,
                thumbnailCache: null,
                onTap: () {},
                onMorePressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('٤:٠٥'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
