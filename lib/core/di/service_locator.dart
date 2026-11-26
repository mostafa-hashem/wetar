import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import '../../features/library/data/library_repository.dart';
import '../../features/library/presentation/bloc/library_cubit.dart';
import '../../features/library/presentation/bloc/search_cubit.dart';
import '../../features/music_folders/data/music_folders_repository.dart';
import '../../features/music_folders/presentation/bloc/music_folders_cubit.dart';
import '../../features/personalization/presentation/bloc/personalization_cubit.dart';
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
  final capabilities = PlatformCapabilities.detect();

  final foldersRepo = MusicFoldersRepository(db, channel, channel);
  final libraryRepo = LibraryRepository(db);
  final thumbCache = ThumbnailPathCache(channel, cacheManager);

  sl
    ..registerSingleton<WetarDatabase>(db)
    ..registerSingleton<CacheManager>(cacheManager)
    ..registerSingleton<SettingsRepository>(settingsRepo)
    ..registerSingleton<WetarPlatformChannel>(channel)
    ..registerSingleton<LibrarySource>(channel)
    ..registerSingleton<FolderPickerService>(channel)
    ..registerSingleton<NativeAudioEffectsService>(channel)
    ..registerSingleton<SystemIntegrationService>(channel)
    ..registerSingleton<PlatformCapabilities>(capabilities)
    ..registerSingleton<ThumbnailPathCache>(thumbCache)
    ..registerSingleton<MusicFoldersRepository>(foldersRepo)
    ..registerSingleton<LibraryRepository>(libraryRepo);

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
    ..registerLazySingleton<PlayerCubit>(() => PlayerCubit(audioHandler));
}
