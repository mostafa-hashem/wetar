import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/domain/sleep_timer_config.dart';
import 'package:wetar/features/player/presentation/widgets/wetar_seek_bar.dart';
import 'package:wetar/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'resolves RTL Arabic and LTR English tokens across Light/Dark/AMOLED',
    (tester) async {
      Future<void> pumpLocaleAndTheme(
        String localeCode,
        WetarThemeMode mode,
        String font,
      ) async {
        final settings = AppearanceSettings(
          themeMode: mode,
          arabicFontFamily: font,
          latinFontFamily: 'PlusJakartaSans',
        );
        final theme = WetarTokenResolver.buildThemeData(
          settings,
          platformBrightness: Brightness.dark,
          systemDisableAnimations: false,
          isArabicLocale: localeCode == 'ar',
        );

        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey<String>('$localeCode-${mode.name}'),
            locale: Locale(localeCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: theme,
            home: Builder(
              builder: (ctx) {
                final l10n = AppLocalizations.of(ctx);
                final tokens = ctx.wetarTokens;
                return Scaffold(
                  body: Column(
                    children: <Widget>[
                      Text(l10n.appName),
                      WetarSeekBar(
                        seedKey: 'test_track',
                        style: SeekBarStyle.stringWaveform,
                        position: const Duration(seconds: 30),
                        duration: const Duration(minutes: 3),
                        isPlaying: false,
                        abLoop: const AbLoopState(),
                        hapticsIntensity: HapticsIntensity.off,
                        onSeek: (_) {},
                      ),
                      Text(tokens.isAmoled ? 'amoled' : 'normal'),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpLocaleAndTheme('ar', WetarThemeMode.amoled, 'Cairo');
      expect(find.text('وتر'), findsOneWidget);
      expect(find.text('amoled'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('وتر'))),
        TextDirection.rtl,
      );

      await pumpLocaleAndTheme('en', WetarThemeMode.light, 'Almarai');
      expect(find.text('Wetar'), findsOneWidget);
      expect(find.text('normal'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('Wetar'))),
        TextDirection.ltr,
      );
    },
  );
}
