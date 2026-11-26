import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import 'package:wetar/features/equalizer/presentation/bloc/equalizer_cubit.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/bloc/search_cubit.dart';
import 'package:wetar/features/lyrics/presentation/bloc/lyrics_cubit.dart';
import 'package:wetar/features/music_folders/data/file_system_library_source.dart';
import 'package:wetar/features/music_folders/data/music_folders_repository.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/personalization/data/artwork_palette_extractor.dart';
import 'package:wetar/features/personalization/data/custom_font_loader_service.dart';
import 'package:wetar/features/personalization/data/custom_image_processor.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/playlists/data/playlists_repository.dart';
import 'package:wetar/features/playlists/presentation/bloc/playlists_cubit.dart';
import 'package:wetar/features/settings/data/backup_service.dart';

import '../../features/player/data/wetar_audio_handler.dart';
import '../../features/player/presentation/bloc/player_cubit.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../capabilities/platform_capabilities.dart';
import '../database/wetar_database.dart';
import '../logging/app_logger.dart';
import '../platform/platform_interfaces.dart';
import '../platform/wetar_platform_channel.dart';
import '../storage/cache_manager.dart';
import '../widgets/wetar_artwork_image.dart';

final GetIt sl = GetIt.instance;

/// Initializes core singletons without performing slow disk scans on cold start.
Future<void> initServiceLocator() async {
  if (sl.isRegistered<WetarDatabase>()) return;

  await AppLogger.init();
  final settingsRepo = await SettingsRepository.create();
  final cacheManager = CacheManager();
  await cacheManager.init();

  final db = WetarDatabase();
  final channel = WetarPlatformChannel();
  final LibrarySource librarySource = (Platform.isMacOS || Platform.isIOS)
      ? FileSystemLibrarySource()
      : channel;
  final capabilities = PlatformCapabilities.detect();

  final foldersRepo = MusicFoldersRepository(db, librarySource, channel);
  final libraryRepo = LibraryRepository(db);
  final playlistsRepo = PlaylistsRepository(db, libraryRepo);
  final thumbCache = ThumbnailPathCache(librarySource, cacheManager);
  final paletteExtractor = ArtworkPaletteExtractor(db, thumbCache);
  final fontLoaderService = CustomFontLoaderService(cacheManager);
  final imageProcessor = CustomImageProcessor(cacheManager);
  final savedAppearance = settingsRepo.loadAppearance();
  await fontLoaderService.reloadStoredFontIfNeeded(
    savedAppearance.importedFontFamily,
  );

  sl
    ..registerSingleton<WetarDatabase>(db)
    ..registerSingleton<CacheManager>(cacheManager)
    ..registerSingleton<SettingsRepository>(settingsRepo)
    ..registerSingleton<WetarPlatformChannel>(channel)
    ..registerSingleton<LibrarySource>(librarySource)
    ..registerSingleton<FolderPickerService>(channel)
    ..registerSingleton<NativeAudioEffectsService>(channel)
    ..registerSingleton<SystemIntegrationService>(channel)
    ..registerSingleton<PlatformCapabilities>(capabilities)
    ..registerSingleton<ThumbnailPathCache>(thumbCache)
    ..registerSingleton<ArtworkPaletteExtractor>(paletteExtractor)
    ..registerSingleton<CustomFontLoaderService>(fontLoaderService)
    ..registerSingleton<CustomImageProcessor>(imageProcessor)
    ..registerSingleton<MusicFoldersRepository>(foldersRepo)
    ..registerSingleton<LibraryRepository>(libraryRepo)
    ..registerSingleton<PlaylistsRepository>(playlistsRepo);

  late final WetarAudioHandler audioHandler;
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    audioHandler = await AudioService.init<WetarAudioHandler>(
      builder: () => WetarAudioHandler(
        db: db,
        libraryRepo: libraryRepo,
        settingsRepo: settingsRepo,
        nativeEffects: channel,
        systemService: channel,
        thumbnailCache: thumbCache,
        capabilities: capabilities,
      ),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yourname.wetar.playback',
        androidNotificationChannelName: 'Wetar Playback',
        androidNotificationChannelDescription:
            'Offline music playback controls',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
  } else {
    audioHandler = WetarAudioHandler(
      db: db,
      libraryRepo: libraryRepo,
      settingsRepo: settingsRepo,
      nativeEffects: channel,
      systemService: channel,
      thumbnailCache: thumbCache,
      capabilities: capabilities,
    );
  }

  sl
    ..registerSingleton<WetarAudioHandler>(audioHandler)
    ..registerLazySingleton<PersonalizationCubit>(
      () => PersonalizationCubit(settingsRepo),
    )
    ..registerLazySingleton<SettingsCubit>(() => SettingsCubit(settingsRepo))
    ..registerLazySingleton<MusicFoldersCubit>(
      () => MusicFoldersCubit(foldersRepo, channel, capabilities),
    )
    ..registerLazySingleton<LibraryCubit>(
      () => LibraryCubit(
        libraryRepo,
        minDurationSec: settingsRepo.loadPlayback().minTrackDurationSec,
      ),
    )
    ..registerFactory<SearchCubit>(() => SearchCubit(libraryRepo))
    ..registerLazySingleton<PlaylistsCubit>(() => PlaylistsCubit(playlistsRepo))
    ..registerLazySingleton<EqualizerCubit>(
      () => EqualizerCubit(db, audioHandler, channel, capabilities),
    )
    ..registerLazySingleton<LyricsCubit>(
      () => LyricsCubit(libraryRepo, channel),
    )
    ..registerLazySingleton<PlayerCubit>(() => PlayerCubit(audioHandler))
    ..registerLazySingleton<BackupService>(
      () => BackupService(db, sl<PersonalizationCubit>(), sl<SettingsCubit>()),
    );
}
