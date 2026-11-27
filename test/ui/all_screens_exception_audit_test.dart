import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/utils/arabic_normalizer.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/equalizer/presentation/bloc/equalizer_cubit.dart';
import 'package:wetar/features/equalizer/presentation/screens/equalizer_screen.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/bloc/search_cubit.dart';
import 'package:wetar/features/library/presentation/screens/home_screen.dart';
import 'package:wetar/features/library/presentation/screens/library_screen.dart';
import 'package:wetar/features/library/presentation/screens/search_screen.dart';
import 'package:wetar/features/lyrics/presentation/bloc/lyrics_cubit.dart';
import 'package:wetar/features/lyrics/presentation/widgets/lyrics_sheet.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';
import 'package:wetar/features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import 'package:wetar/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/screens/appearance_studio_screen.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/player/presentation/screens/car_mode_screen.dart';
import 'package:wetar/features/player/presentation/screens/now_playing_screen.dart';
import 'package:wetar/features/player/presentation/widgets/queue_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/share_track_card_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/track_details_sheet.dart';
import 'package:wetar/features/playlists/data/playlists_repository.dart';
import 'package:wetar/features/playlists/presentation/bloc/playlists_cubit.dart';
import 'package:wetar/features/playlists/presentation/screens/playlists_screen.dart';
import 'package:wetar/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:wetar/features/settings/data/backup_service.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/features/settings/presentation/screens/backup_stats_diagnostics_screen.dart';
import 'package:wetar/features/settings/presentation/screens/listening_stats_screen.dart';
import 'package:wetar/features/settings/presentation/screens/settings_screen.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';
import 'package:wetar/l10n/app_localizations.dart';

class _TestEnv {
  _TestEnv._({
    required this.db,
    required this.settingsRepo,
    required this.platform,
    required this.libraryRepo,
    required this.playlistsRepo,
    required this.settingsCubit,
    required this.personalizationCubit,
    required this.foldersCubit,
    required this.libraryCubit,
    required this.playlistsCubit,
    required this.lyricsCubit,
    required this.playerCubit,
    required this.equalizerCubit,
    required this.tracks,
  });

  final WetarDatabase db;
  final SettingsRepository settingsRepo;
  final _FakePlatformServices platform;
  final LibraryRepository libraryRepo;
  final PlaylistsRepository playlistsRepo;
  final SettingsCubit settingsCubit;
  final PersonalizationCubit personalizationCubit;
  final MusicFoldersCubit foldersCubit;
  final LibraryCubit libraryCubit;
  final PlaylistsCubit playlistsCubit;
  final LyricsCubit lyricsCubit;
  final _StubPlayerCubit playerCubit;
  final _StubEqualizerCubit equalizerCubit;
  final List<WetarTrack> tracks;

  static Future<_TestEnv> create() async {
    await sl.reset();

    final db = WetarDatabase(NativeDatabase.memory());
    final settingsRepo = SettingsRepository.inMemory();
    final platform = _FakePlatformServices();
    final cacheManager = CacheManager();
    final libraryRepo = LibraryRepository(db);
    final playlistsRepo = PlaylistsRepository(db, libraryRepo);
    final thumbCache = ThumbnailPathCache(platform, cacheManager);
    const caps = PlatformCapabilities(
      supportsNativeEqualizer: true,
      supportsBassBoost: true,
      supportsVirtualizer: true,
      supportsLoudnessEnhancer: true,
      supportsSkipSilence: true,
      supportsPitchControl: true,
      supportsInAppFolderPicker: true,
      supportsSafFolderPicker: true,
      supportsSystemFolderBookmarks: false,
      supportsSystemDynamicColor: false,
      supportsHomeWidgets: false,
      supportsDesktopShell: false,
      supportsBatteryOptimizationGuide: true,
      supportsICloudStatus: false,
    );
    final foldersRepo = MusicFoldersRepository(db, platform, platform);
    await foldersRepo.addOrReactivateFolder(
      rootPath: '/storage/emulated/0/Music',
      displayName: 'Music',
    );

    final sampleTracks = <WetarTrack>[
      const WetarTrack(
        stableKey: '/storage/emulated/0/Music/oud_dawn.mp3',
        folderId: 1,
        uri: 'file:///storage/emulated/0/Music/oud_dawn.mp3',
        filePath: '/storage/emulated/0/Music/oud_dawn.mp3',
        folderPath: '/storage/emulated/0/Music',
        title: 'Oud Dawn • فجر العود الطويل للاختبار البصري الكامل',
        artist: 'Ziryab Ensemble',
        album: 'Cordoba Evenings',
        albumArtist: 'Ziryab Ensemble',
        genre: 'Instrumental',
        year: 2024,
        trackNumber: 1,
        discNumber: 1,
        durationMs: 245000,
        bitrateKbps: 320,
        sampleRateHz: 48000,
        channels: 2,
        sizeBytes: 9800000,
        mimeType: 'audio/flac+lossless-extended-descriptor',
        dateModifiedSec: 1700000000,
        dateAddedSec: 1700000000,
        playCount: 12,
        lastPlayedAt: 1700001000,
        isFavorite: true,
      ),
      const WetarTrack(
        stableKey: '/storage/emulated/0/Music/desert_strings.mp3',
        folderId: 1,
        uri: 'file:///storage/emulated/0/Music/desert_strings.mp3',
        filePath: '/storage/emulated/0/Music/desert_strings.mp3',
        folderPath: '/storage/emulated/0/Music',
        title: 'Desert Strings',
        artist: 'Nadia Mansour',
        album: 'Sands',
        albumArtist: 'Nadia Mansour',
        genre: 'Acoustic',
        year: 2023,
        trackNumber: 2,
        discNumber: 1,
        durationMs: 192000,
        bitrateKbps: 256,
        sampleRateHz: 44100,
        channels: 2,
        sizeBytes: 6200000,
        mimeType: 'audio/mpeg',
        dateModifiedSec: 1700000100,
        dateAddedSec: 1700000100,
        playCount: 4,
      ),
      const WetarTrack(
        stableKey: '/storage/emulated/0/Music/night_nawa.mp3',
        folderId: 1,
        uri: 'file:///storage/emulated/0/Music/night_nawa.mp3',
        filePath: '/storage/emulated/0/Music/night_nawa.mp3',
        folderPath: '/storage/emulated/0/Music',
        title: 'Night Nawa',
        artist: 'Fairuz Trio',
        album: 'Cordoba Evenings',
        albumArtist: 'Fairuz Trio',
        genre: 'Oriental',
        year: 2022,
        trackNumber: 3,
        discNumber: 1,
        durationMs: 310000,
        bitrateKbps: 320,
        sampleRateHz: 44100,
        channels: 2,
        sizeBytes: 12400000,
        mimeType: 'audio/mpeg',
        dateModifiedSec: 1700000200,
        dateAddedSec: 1700000200,
      ),
    ];

    await db.batch((b) {
      b.insertAll(
        db.tracks,
        sampleTracks
            .map(
              (t) => TracksCompanion.insert(
                stableKey: t.stableKey,
                folderId: t.folderId,
                uri: t.uri,
                filePath: t.filePath,
                folderPath: t.folderPath,
                title: t.title,
                titleNormalized: ArabicNormalizer.normalize(t.title),
                artist: Value(t.artist),
                artistNormalized: Value(ArabicNormalizer.normalize(t.artist)),
                album: Value(t.album),
                albumNormalized: Value(ArabicNormalizer.normalize(t.album)),
                albumArtist: Value(t.albumArtist),
                genre: Value(t.genre),
                year: Value(t.year),
                trackNumber: Value(t.trackNumber),
                discNumber: Value(t.discNumber),
                durationMs: Value(t.durationMs),
                bitrateKbps: Value(t.bitrateKbps),
                sampleRateHz: Value(t.sampleRateHz),
                channels: Value(t.channels),
                sizeBytes: Value(t.sizeBytes),
                mimeType: Value(t.mimeType),
                dateModifiedSec: Value(t.dateModifiedSec),
                dateAddedSec: Value(t.dateAddedSec),
              ),
            )
            .toList(),
      );
    });

    final settingsCubit = SettingsCubit(settingsRepo);
    await settingsCubit.setLocaleCode('en');
    await settingsCubit.completeOnboarding();
    final personalizationCubit = PersonalizationCubit(settingsRepo);
    final foldersCubit = MusicFoldersCubit(foldersRepo, platform, caps);
    final libraryCubit = LibraryCubit(libraryRepo, minDurationSec: 0);
    final playlistsCubit = PlaylistsCubit(playlistsRepo);
    for (var i = 1; i <= 10; i++) {
      final pid = await playlistsCubit.createPlaylist('Playlist #$i Long Name');
      if (i == 1) {
        await playlistsCubit.addTracks(pid, sampleTracks);
      }
    }
    final lyricsCubit = LyricsCubit(libraryRepo, platform);
    final playerCubit = _StubPlayerCubit(sampleTracks);
    final equalizerCubit = _StubEqualizerCubit();
    final backupService = BackupService(
      db,
      personalizationCubit,
      settingsCubit,
    );

    sl
      ..registerSingleton<WetarDatabase>(db)
      ..registerSingleton<CacheManager>(cacheManager)
      ..registerSingleton<SettingsRepository>(settingsRepo)
      ..registerSingleton<LibrarySource>(platform)
      ..registerSingleton<FolderPickerService>(platform)
      ..registerSingleton<NativeAudioEffectsService>(platform)
      ..registerSingleton<SystemIntegrationService>(platform)
      ..registerSingleton<PlatformCapabilities>(caps)
      ..registerSingleton<ThumbnailPathCache>(thumbCache)
      ..registerSingleton<LibraryRepository>(libraryRepo)
      ..registerSingleton<PlaylistsRepository>(playlistsRepo)
      ..registerFactory<SearchCubit>(() => SearchCubit(libraryRepo))
      ..registerSingleton<PersonalizationCubit>(personalizationCubit)
      ..registerSingleton<SettingsCubit>(settingsCubit)
      ..registerSingleton<MusicFoldersCubit>(foldersCubit)
      ..registerSingleton<LibraryCubit>(libraryCubit)
      ..registerSingleton<PlaylistsCubit>(playlistsCubit)
      ..registerSingleton<LyricsCubit>(lyricsCubit)
      ..registerSingleton<EqualizerCubit>(equalizerCubit)
      ..registerSingleton<PlayerCubit>(playerCubit)
      ..registerSingleton<BackupService>(backupService);

    return _TestEnv._(
      db: db,
      settingsRepo: settingsRepo,
      platform: platform,
      libraryRepo: libraryRepo,
      playlistsRepo: playlistsRepo,
      settingsCubit: settingsCubit,
      personalizationCubit: personalizationCubit,
      foldersCubit: foldersCubit,
      libraryCubit: libraryCubit,
      playlistsCubit: playlistsCubit,
      lyricsCubit: lyricsCubit,
      playerCubit: playerCubit,
      equalizerCubit: equalizerCubit,
      tracks: sampleTracks,
    );
  }

  Future<void> dispose() async {
    await equalizerCubit.close();
    await playerCubit.close();
    await lyricsCubit.close();
    await playlistsCubit.close();
    await libraryCubit.close();
    await foldersCubit.close();
    await personalizationCubit.close();
    await settingsCubit.close();
    await db.close();
    await sl.reset();
  }

  Widget wrapScreen(
    Widget child, {
    Locale locale = const Locale('en'),
    double textScale = 1.45,
  }) {
    final theme = WetarTokenResolver.buildThemeData(
      personalizationCubit.state.settings,
      platformBrightness: Brightness.dark,
      systemDisableAnimations: false,
      isArabicLocale: locale.languageCode == 'ar',
    );
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<PersonalizationCubit>.value(value: personalizationCubit),
        BlocProvider<MusicFoldersCubit>.value(value: foldersCubit),
        BlocProvider<LibraryCubit>.value(value: libraryCubit),
        BlocProvider<PlaylistsCubit>.value(value: playlistsCubit),
        BlocProvider<LyricsCubit>.value(value: lyricsCubit),
        BlocProvider<EqualizerCubit>.value(value: equalizerCubit),
        BlocProvider<PlayerCubit>.value(value: playerCubit),
      ],
      child: Builder(
        builder: (ctx) => MediaQuery(
          data: MediaQueryData.fromView(View.of(ctx))
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: theme,
            home: child,
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'SettingsScreen and AppearanceStudioScreen all 7 tabs + Home block reorder run without exceptions on narrow scaled viewports (EN & AR)',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final env = await _TestEnv.create();
      addTearDown(env.dispose);

      // Persist an unknown font family to verify WetarDropdownTile fallback guard.
      await env.personalizationCubit.updateSettings(
        env.personalizationCubit.state.settings.copyWith(
          arabicFontFamily: 'NonExistentCustomFont',
        ),
      );

      for (final locale in const <Locale>[Locale('en'), Locale('ar')]) {
        await env.settingsCubit.setLocaleCode(locale.languageCode);

        await tester.pumpWidget(
          env.wrapScreen(
            SettingsScreen(onOpenEqualizer: () {}, onOpenBackupAndStats: () {}),
            locale: locale,
            textScale: 1.45,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byWidgetPredicate((w) => w is SegmentedButton),
          findsNothing,
        );

        // Expand Advanced section on SettingsScreen.
        final advancedFinder = find.text(
          locale.languageCode == 'ar' ? 'خيارات متقدمة' : 'Advanced',
        );
        await tester.scrollUntilVisible(
          advancedFinder,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(advancedFinder);
        await tester.pumpAndSettle();
        await tester.tap(advancedFinder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Mount OnboardingScreen (all 3 steps including Look step) and verify no SegmentedButton.
        await tester.pumpWidget(
          env.wrapScreen(
            OnboardingScreen(onFinished: () {}),
            locale: locale,
            textScale: 1.35,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byWidgetPredicate((w) => w is SegmentedButton),
          findsNothing,
        );

        // Mount AppearanceStudioScreen and visit all 7 tabs.
        await tester.pumpWidget(
          env.wrapScreen(
            const AppearanceStudioScreen(),
            locale: locale,
            textScale: 1.45,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final tabs = locale.languageCode == 'ar'
            ? const <String>[
                'المظاهر الجاهزة',
                'الألوان',
                'الخطوط',
                'المشغل والمشغل المصغر',
                'الخلفيات',
                'تخطيط الرئيسية والمكتبة',
                'الحواف والظلال والحركة',
              ]
            : const <String>[
                'Looks',
                'Colors',
                'Typography & Fonts',
                'Now Playing & Mini Player',
                'Backgrounds',
                'Home & Library Layout',
                'Shape, Depth & Motion',
              ];

        for (final label in tabs) {
          final tab = find.text(label);
          await tester.ensureVisible(tab);
          await tester.pumpAndSettle();
          await tester.tap(tab);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Tab "$label" (${locale.languageCode}) threw an exception',
          );
          expect(
            find.byWidgetPredicate((w) => w is SegmentedButton),
            findsNothing,
          );

          if (label == 'Home & Library Layout' ||
              label == 'تخطيط الرئيسية والمكتبة') {
            final densityLabel = locale.languageCode == 'ar'
                ? 'مريحة'
                : 'Comfortable';
            final densityFinder = find.text(densityLabel);
            expect(densityFinder, findsOneWidget);
            final densitySize = tester.getSize(densityFinder);
            expect(densitySize.height, lessThanOrEqualTo(32.0));
            if (locale.languageCode == 'en') {
              expect(densitySize.width, greaterThanOrEqualTo(75.0));
            }

            // Drag-to-reorder a Home block via its drag handle.
            final handle = find.byIcon(Icons.drag_handle_rounded).first;
            await tester.ensureVisible(handle);
            await tester.pumpAndSettle();
            await tester.drag(handle, const Offset(0, 64));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        }
      }
    },
  );

  testWidgets(
    'Every other screen, bottom sheet, and drag-reorder list runs without exceptions across portrait & landscape viewports',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final env = await _TestEnv.create();
      addTearDown(env.dispose);

      // Wait briefly so Drift streams populate cubit states cleanly.
      await tester.pump(const Duration(milliseconds: 50));

      final screens = <Widget>[
        HomeScreen(
          onOpenNowPlaying: () {},
          onOpenFavorites: () {},
          onOpenPlaylists: () {},
          onOpenCarMode: () {},
          onOpenTrackDetails: (_) {},
          onAddToPlaylistRequested: (_) {},
        ),
        LibraryScreen(
          onOpenTrackDetails: (_) {},
          onAddToPlaylistRequested: (_) {},
        ),
        SearchScreen(
          onOpenTrackDetails: (_) {},
          onAddToPlaylistRequested: (_) {},
        ),
        const MusicFoldersSettingsScreen(),
        const FolderPickerScreen(),
        PlaylistsScreen(onOpenTrackDetails: (_) {}),
        const BackupStatsDiagnosticsScreen(),
        const ListeningStatsScreen(),
        const EqualizerScreen(),
        const LyricsSheet(),
        const CarModeScreen(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(env.wrapScreen(screen, textScale: 1.4));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} threw on 360x740 portrait',
        );
      }

      // Also test FolderPickerScreen once audio permission & discovered folders load.
      await env.foldersCubit.initAndReconcile();
      await env.foldersCubit.refreshDiscoveredFolders();
      await tester.pumpWidget(
        env.wrapScreen(const FolderPickerScreen(), textScale: 1.4),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Now Playing across all 5 variants on narrow screen + sheets.
      for (final variant in PlayerLayoutVariant.values) {
        await env.personalizationCubit.updateSettings(
          env.personalizationCubit.state.settings.copyWith(
            playerLayout: variant,
          ),
        );
        await tester.pumpWidget(
          env.wrapScreen(
            NowPlayingScreen(
              onOpenQueue: () {},
              onOpenLyrics: () {},
              onOpenEqualizer: () {},
              onOpenCarMode: () {},
              onOpenTrackDetails: (_) {},
              onShareTrack: (_) {},
            ),
            textScale: 1.35,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'NowPlayingScreen $variant threw an exception',
        );
      }

      // Trigger Sleep Timer, Speed/Pitch, A-B Loop, TrackDetails, ShareCard, AddToPlaylist, and Queue sheets.
      await tester.tap(find.byIcon(Icons.bedtime_outlined));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.text('10 min'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.speed_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.text('Speed'))).pop();
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        env.wrapScreen(
          Builder(
            builder: (ctx) => Scaffold(
              body: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => showTrackDetailsSheet(
                      ctx,
                      track: env.tracks.first,
                      numerals: NumeralStyle.western,
                    ),
                    child: const Text('Details'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        showShareTrackCardSheet(ctx, env.tracks.first),
                    child: const Text('Share'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        showAddToPlaylistSheet(ctx, tracks: env.tracks),
                    child: const Text('AddPlaylist'),
                  ),
                  ElevatedButton(
                    onPressed: () => showWetarQueueSheet(ctx),
                    child: const Text('Queue'),
                  ),
                ],
              ),
            ),
          ),
          textScale: 1.4,
        ),
      );
      await tester.pumpAndSettle();

      for (final btn in const <String>[
        'Details',
        'Share',
        'AddPlaylist',
        'Queue',
      ]) {
        await tester.tap(find.text(btn));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Sheet "$btn" threw an exception',
        );
        if (btn == 'Queue') {
          final handle = find.byIcon(Icons.drag_handle_rounded).first;
          final gesture = await tester.startGesture(tester.getCenter(handle));
          await tester.pump(
            kLongPressTimeout + const Duration(milliseconds: 50),
          );
          await gesture.moveBy(const Offset(0, 80));
          await gesture.up();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        Navigator.of(tester.element(find.text(btn))).pop();
        await tester.pumpAndSettle();
      }

      // Landscape 740x360 stress test on CarMode & NowPlayingScreen.
      tester.view.physicalSize = const Size(740, 360);
      await tester.pumpWidget(env.wrapScreen(const CarModeScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(env.wrapScreen(const NowPlayingScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Android edge-to-edge 48dp bottom nav bar does not overlap Equalizer or Wrapped stats',
    (tester) async {
      final env = await _TestEnv.create();
      addTearDown(env.dispose);

      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(392, 850);
      tester.view.padding = const FakeViewPadding(top: 36, bottom: 48);
      tester.view.viewPadding = const FakeViewPadding(top: 36, bottom: 48);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
        tester.view.resetViewPadding();
      });

      env.equalizerCubit.emitLoudness(12.0);
      await tester.pumpWidget(
        env.wrapScreen(const EqualizerScreen(), textScale: 1.0),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final eqScrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      eqScrollable.position.jumpTo(eqScrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final warningFinder = find.text(
        'High volume boost may cause speaker distortion',
      );
      expect(warningFinder, findsOneWidget);
      final warningRect = tester.getRect(warningFinder);
      expect(warningRect.bottom, lessThanOrEqualTo(850.0 - 48.0));

      // Verify ListeningStatsScreen displays real seconds & resets cleanly.
      await (env.db.update(env.db.selectedFolders)
            ..where((t) => t.id.equals(1)))
          .write(const SelectedFoldersCompanion(isAvailable: Value(true)));
      await env.libraryRepo.upsertPlayHistorySession(
        track: env.tracks.first,
        playedAtMs: 1700000000,
        listenedMs: 18000,
      );
      await tester.pumpWidget(
        env.wrapScreen(const ListeningStatsScreen(), textScale: 1.0),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('18 sec'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      final shareBtnRect = tester.getRect(find.text('Share Wrapped card'));
      expect(shareBtnRect.bottom, lessThanOrEqualTo(850.0 - 48.0));

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('0 min'), findsOneWidget);
    },
  );
}

class _StubPlayerCubit extends Cubit<PlayerStateSnapshot>
    implements PlayerCubit {
  _StubPlayerCubit(List<WetarTrack> tracks)
    : super(
        PlayerStateSnapshot(
          queue: tracks,
          currentIndex: 0,
          isPlaying: false,
          position: const Duration(seconds: 42),
          speed: 1.0,
          pitch: 1.0,
        ),
      );

  @override
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final next = List<WetarTrack>.from(state.queue);
    if (oldIndex < 0 || oldIndex >= next.length) return;
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex.clamp(0, next.length), moved);
    emit(state.copyWith(queue: next));
  }

  @override
  Future<void> setSpeed(double speed) async =>
      emit(state.copyWith(speed: speed));

  @override
  Future<void> setPitch(double pitch) async =>
      emit(state.copyWith(pitch: pitch));

  @override
  void setSleepTimerMinutes(int min) {}

  @override
  void setSleepTimerEndOfTrack() {}

  @override
  void setSleepTimerAfterTracks(int count) {}

  @override
  void cancelSleepTimer() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubEqualizerCubit extends Cubit<EqualizerState>
    implements EqualizerCubit {
  _StubEqualizerCubit()
    : super(
        const EqualizerState(
          isAvailable: true,
          isEnabled: true,
          minDb: -15.0,
          maxDb: 15.0,
          bands: <EqBandInfo>[
            EqBandInfo(index: 0, centerFreqHz: 60, gainDb: 1.5),
            EqBandInfo(index: 1, centerFreqHz: 230, gainDb: 0.0),
            EqBandInfo(index: 2, centerFreqHz: 910, gainDb: -1.0),
            EqBandInfo(index: 3, centerFreqHz: 3600, gainDb: 2.0),
            EqBandInfo(index: 4, centerFreqHz: 14000, gainDb: 1.0),
          ],
          presets: <EqPresetItem>[
            EqPresetItem(
              name: 'Flat',
              isCustom: false,
              bandGainsDb: <double>[0, 0, 0, 0, 0],
            ),
          ],
        ),
      );

  void emitLoudness(double db) => emit(state.copyWith(loudnessGainDb: db));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakePlatformServices
    implements
        LibrarySource,
        FolderPickerService,
        NativeAudioEffectsService,
        SystemIntegrationService {
  @override
  Stream<PlatformIncomingEvent> get incomingEvents => const Stream.empty();
  @override
  Future<WetarPermissionsStatus> checkPermissions() async =>
      const WetarPermissionsStatus(
        audioGranted: true,
        notificationsGranted: true,
      );
  @override
  Future<List<DiscoveredAudioFolder>> listAudioFolders() async =>
      const <DiscoveredAudioFolder>[
        DiscoveredAudioFolder(
          volumeLabel: 'Internal Storage',
          rootPath: '/storage/emulated/0/Music',
          displayName: 'Music',
          trackCount: 3,
          sourceKind: 'mediastore',
        ),
      ];
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
  Future<bool> isIgnoringBatteryOptimizations() async => false;
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
  Future<({bool bassBoost, bool virtualizer})> attachSession(
    int sessionId,
  ) async => (bassBoost: true, virtualizer: true);
  @override
  Future<bool> setBassBoost({
    required bool enabled,
    required int strength,
  }) async => true;
  @override
  Future<bool> setVirtualizer({
    required bool enabled,
    required int strength,
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
