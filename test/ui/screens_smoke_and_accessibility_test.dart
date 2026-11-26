import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/widgets/track_list_tile.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/screens/appearance_studio_screen.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/features/settings/presentation/screens/settings_screen.dart';
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

  testWidgets(
    'SettingsScreen and AppearanceStudioScreen keep titles single-line cleanly on narrow 360dp viewports',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = SettingsRepository.inMemory();
      final settingsCubit = SettingsCubit(repo);
      await settingsCubit.setLocaleCode('en');
      final personalizationCubit = PersonalizationCubit(repo);
      final db = WetarDatabase(NativeDatabase.memory());
      final fake = _FakePlatform();
      final foldersRepo = MusicFoldersRepository(db, fake, fake);
      final foldersCubit = MusicFoldersCubit(
        foldersRepo,
        fake,
        const PlatformCapabilities(
          supportsNativeEqualizer: false,
          supportsBassBoost: false,
          supportsVirtualizer: false,
          supportsLoudnessEnhancer: false,
          supportsSkipSilence: false,
          supportsPitchControl: false,
          supportsInAppFolderPicker: false,
          supportsSafFolderPicker: false,
          supportsSystemFolderBookmarks: false,
          supportsSystemDynamicColor: false,
          supportsHomeWidgets: false,
          supportsDesktopShell: false,
          supportsBatteryOptimizationGuide: false,
          supportsICloudStatus: false,
        ),
      );
      addTearDown(() async {
        await foldersCubit.close();
        await personalizationCubit.close();
        await settingsCubit.close();
        await db.close();
      });

      final theme = WetarTokenResolver.buildThemeData(
        personalizationCubit.state.settings,
        platformBrightness: Brightness.dark,
        systemDisableAnimations: false,
        isArabicLocale: false,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
            BlocProvider<MusicFoldersCubit>.value(value: foldersCubit),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: theme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final langTitle = find.text('Language & Numerals');
      expect(langTitle, findsOneWidget);
      final size = tester.getSize(langTitle);
      expect(size.width, greaterThan(220));
      expect(size.height, lessThanOrEqualTo(48.0));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: theme,
            home: const AppearanceStudioScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final tabLabel in const <String>[
        'Colors',
        'Typography & Fonts',
        'Now Playing & Mini Player',
        'Backgrounds',
        'Home & Library Layout',
        'Shape, Depth & Motion',
      ]) {
        final tabFinder = find.text(tabLabel);
        await tester.ensureVisible(tabFinder);
        await tester.pumpAndSettle();
        await tester.tap(tabFinder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}

class _FakePlatform
    implements LibrarySource, FolderPickerService, SystemIntegrationService {
  @override
  Stream<PlatformIncomingEvent> get incomingEvents => const Stream.empty();
  @override
  Future<WetarPermissionsStatus> checkPermissions() async =>
      const WetarPermissionsStatus(
        audioGranted: true,
        notificationsGranted: true,
      );
  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async => const [];
  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async => const FolderScanResult(
    availableFolderIds: <int>{},
    activeStableKeys: <String>{},
    changedTracks: <ScannedTrackDto>[],
  );
  @override
  Future<String?> loadAlbumArtThumbnail({
    required String? uri,
    required String? filePath,
    required String outputPath,
    int sizePx = 256,
  }) async => null;
  @override
  Future<bool> isIgnoringBatteryOptimizations() async => true;
  @override
  Future<bool> openAppSettings() async => true;
  @override
  Future<bool> openBatteryOptimizationSettings() async => true;
  @override
  Future<String?> pickFile({required List<String> mimeTypes}) async => null;
  @override
  Future<String?> pickGalleryImage() async => null;
  @override
  Future<PickedFolderResult?> pickSystemFolder() async => null;
  @override
  Future<WetarPermissionsStatus> requestPermissions({
    bool includeNotifications = true,
  }) async => checkPermissions();
  @override
  Future<bool> resolveBookmark(String bookmarkData) async => true;
  @override
  Future<bool> saveFile({
    required String fileName,
    required String mimeType,
    Uint8List? bytes,
    String? sourcePath,
  }) async => true;
  @override
  Future<bool> setCompactMiniPlayerMode(bool compact) async => true;
  @override
  Future<bool> setKeepScreenOn(bool keepOn) async => true;
  @override
  Future<bool> shareFiles({
    required List<String> paths,
    required String mimeType,
    String? subject,
  }) async => true;
  @override
  Future<void> startWatchingFolders(List<String> paths) async {}
  @override
  Future<void> stopAccessingBookmark(String bookmarkData) async {}
  @override
  Future<bool> triggerCloudDownload(String filePath) async => false;
  @override
  Future<void> updateHomeWidget({
    required String? title,
    required String? artist,
    required String? artworkPath,
    required bool isPlaying,
  }) async {}
}
