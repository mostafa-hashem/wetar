import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/screens/home_screen.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import 'package:wetar/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/settings/data/settings_repository.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

class _EmptyScanFakePlatform
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
      const <DiscoveredAudioFolder>[];
  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async => FolderScanResult(
    availableFolderIds: folders.map((f) => f.id).toSet(),
    activeStableKeys: const <String>{},
    changedTracks: const <ScannedTrackDto>[],
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
  Future<({bool bassBoost, bool virtualizer})> attachSession(
    int sessionId,
  ) async => (bassBoost: false, virtualizer: false);
  @override
  Future<bool> setBassBoost({
    required bool enabled,
    required int strength,
  }) async => false;
  @override
  Future<bool> setVirtualizer({
    required bool enabled,
    required int strength,
  }) async => false;
  @override
  Future<bool> setCompactMiniPlayerMode(bool compact) async => false;
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

class _SilentPlayerCubit extends Cubit<PlayerStateSnapshot>
    implements PlayerCubit {
  _SilentPlayerCubit() : super(const PlayerStateSnapshot());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ShortClipSource extends _EmptyScanFakePlatform {
  @override
  Future<FolderScanResult> scanSelectedFolders({
    required List<FolderScanRequest> folders,
    required Map<String, int> existingModifiedByStableKey,
  }) async {
    return FolderScanResult(
      availableFolderIds: folders.map((f) => f.id).toSet(),
      activeStableKeys: const <String>{'/music/ring.mp3'},
      changedTracks: <ScannedTrackDto>[
        ScannedTrackDto(
          stableKey: '/music/ring.mp3',
          folderId: folders.first.id,
          uri: 'file:///music/ring.mp3',
          filePath: '/music/ring.mp3',
          folderPath: folders.first.rootPath,
          title: 'Short Ringtone',
          durationMs: 4000,
        ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'HomeScreen never shows a blank screen and folder cards count indexed short tracks',
    (tester) async {
      await sl.reset();
      final db = WetarDatabase(NativeDatabase.memory());
      final settingsRepo = SettingsRepository.inMemory();
      final source = _ShortClipSource();
      final cacheManager = CacheManager();
      final thumbCache = ThumbnailPathCache(source, cacheManager);
      sl.registerSingleton<ThumbnailPathCache>(thumbCache);
      const caps = PlatformCapabilities(
        supportsNativeEqualizer: false,
        supportsBassBoost: false,
        supportsVirtualizer: false,
        supportsLoudnessEnhancer: false,
        supportsSkipSilence: false,
        supportsPitchControl: false,
        supportsInAppFolderPicker: true,
        supportsSafFolderPicker: true,
        supportsSystemFolderBookmarks: false,
        supportsSystemDynamicColor: false,
        supportsHomeWidgets: false,
        supportsDesktopShell: false,
        supportsBatteryOptimizationGuide: false,
        supportsICloudStatus: false,
      );
      sl.registerSingleton<PlatformCapabilities>(caps);

      final foldersRepo = MusicFoldersRepository(db, source, source);
      final libraryRepo = LibraryRepository(db);
      final foldersCubit = MusicFoldersCubit(foldersRepo, source, caps);
      final libraryCubit = LibraryCubit(libraryRepo, minDurationSec: 30);
      final settingsCubit = SettingsCubit(settingsRepo);
      await settingsCubit.setLocaleCode('en');
      final personalizationCubit = PersonalizationCubit(settingsRepo);
      final playerCubit = _SilentPlayerCubit();

      addTearDown(() async {
        await foldersCubit.close();
        await libraryCubit.close();
        await settingsCubit.close();
        await personalizationCubit.close();
        await playerCubit.close();
        await foldersRepo.dispose();
        await db.close();
        await sl.reset();
      });

      await foldersRepo.addOrReactivateFolder(
        rootPath: '/music/Ringtones',
        displayName: 'Ringtones',
      );
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
            BlocProvider<MusicFoldersCubit>.value(value: foldersCubit),
            BlocProvider<LibraryCubit>.value(value: libraryCubit),
            BlocProvider<PlayerCubit>.value(value: playerCubit),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: WetarTokenResolver.buildThemeData(
              personalizationCubit.state.settings,
              platformBrightness: Brightness.dark,
              systemDisableAnimations: false,
              isArabicLocale: false,
            ),
            home: HomeScreen(
              onOpenNowPlaying: () {},
              onOpenFavorites: () {},
              onOpenPlaylists: () {},
              onOpenCarMode: () {},
              onOpenTrackDetails: (_) {},
              onAddToPlaylistRequested: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // HomeScreen shows duration-filter recovery hint instead of blank space.
      expect(find.text('No tracks match this filter'), findsOneWidget);
      expect(find.text('Rescan'), findsOneWidget);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<PersonalizationCubit>.value(
              value: personalizationCubit,
            ),
            BlocProvider<MusicFoldersCubit>.value(value: foldersCubit),
            BlocProvider<LibraryCubit>.value(value: libraryCubit),
            BlocProvider<PlayerCubit>.value(value: playerCubit),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: WetarTokenResolver.buildThemeData(
              personalizationCubit.state.settings,
              platformBrightness: Brightness.dark,
              systemDisableAnimations: false,
              isArabicLocale: false,
            ),
            home: const MusicFoldersSettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Folder card still shows 1 track for the indexed short audio file.
      expect(find.text('1 track'), findsOneWidget);
    },
  );

  testWidgets(
    'Desktop macOS viewport keeps Onboarding look tiles compact and centered',
    (tester) async {
      await sl.reset();
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final db = WetarDatabase(NativeDatabase.memory());
      final settingsRepo = SettingsRepository.inMemory();
      final source = _EmptyScanFakePlatform();
      const caps = PlatformCapabilities(
        supportsNativeEqualizer: false,
        supportsBassBoost: false,
        supportsVirtualizer: false,
        supportsLoudnessEnhancer: false,
        supportsSkipSilence: false,
        supportsPitchControl: false,
        supportsInAppFolderPicker: false,
        supportsSafFolderPicker: false,
        supportsSystemFolderBookmarks: true,
        supportsSystemDynamicColor: false,
        supportsHomeWidgets: false,
        supportsDesktopShell: true,
        supportsBatteryOptimizationGuide: false,
        supportsICloudStatus: false,
      );
      sl.registerSingleton<PlatformCapabilities>(caps);

      final foldersRepo = MusicFoldersRepository(db, source, source);
      final foldersCubit = MusicFoldersCubit(foldersRepo, source, caps);
      final settingsCubit = SettingsCubit(settingsRepo);
      await settingsCubit.setLocaleCode('en');
      final personalizationCubit = PersonalizationCubit(settingsRepo);

      addTearDown(() async {
        await foldersCubit.close();
        await settingsCubit.close();
        await personalizationCubit.close();
        await foldersRepo.dispose();
        await db.close();
        await sl.reset();
      });

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
            theme: WetarTokenResolver.buildThemeData(
              personalizationCubit.state.settings,
              platformBrightness: Brightness.dark,
              systemDisableAnimations: false,
              isArabicLocale: false,
            ),
            home: OnboardingScreen(onFinished: () {}, capabilities: caps),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Advance to the Look selection step.
      await tester.tap(find.text('Continue').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue').last);
      await tester.pumpAndSettle();

      final lookRect = tester.getRect(find.text('Oud Nocturne'));
      final doneRect = tester.getRect(find.text('Done'));
      expect(lookRect.width, lessThan(260));
      expect(doneRect.width, lessThanOrEqualTo(680));
      expect(tester.takeException(), isNull);
    },
  );
}
