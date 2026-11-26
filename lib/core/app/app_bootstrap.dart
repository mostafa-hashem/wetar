import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/app/wetar_app.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/logging/app_logger.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/player/data/wetar_audio_handler.dart';

/// Initializes logging, dependency injection, and global error handlers before
/// mounting [WetarApp], deferring queue restoration and folder sync past frame 1.
Future<void> bootstrapWetarApp() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.installGlobalErrorHandlers();
      await initServiceLocator();
      runApp(const WetarApp());

      unawaited(sl<WetarAudioHandler>().restorePersistedQueue());
      unawaited(sl<MusicFoldersCubit>().initAndReconcile());
    },
    (Object error, StackTrace stack) {
      AppLogger.error(
        'ZoneGuard',
        'Uncaught async error',
        errorObj: error,
        stackTrace: stack,
      );
    },
  );
}
