import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'core/capabilities/platform_capabilities.dart';
import 'core/di/service_locator.dart';
import 'core/logging/app_logger.dart';
import 'core/router/wetar_app_shell.dart';
import 'core/widgets/wetar_feedback.dart';
import 'features/library/presentation/bloc/library_cubit.dart';
import 'features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'features/personalization/presentation/bloc/personalization_cubit.dart';
import 'features/personalization/presentation/theme/wetar_tokens.dart';
import 'features/player/data/wetar_audio_handler.dart';
import 'features/player/presentation/bloc/player_cubit.dart';
import 'features/settings/domain/playback_settings.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.installGlobalErrorHandlers();
      await initServiceLocator();
      runApp(const WetarRootApp());
      // Restore queue and reconcile folders asynchronously after first frame.
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

class WetarRootApp extends StatefulWidget {
  const WetarRootApp({super.key});

  @override
  State<WetarRootApp> createState() => _WetarRootAppState();
}

class _WetarRootAppState extends State<WetarRootApp> {
  late final AppLifecycleListener _lifecycleListener;
  bool _isUiVisible = true;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onShow: () => _setVisible(true),
      onResume: () => _setVisible(true),
      onHide: () => _setVisible(false),
      onPause: () => _setVisible(false),
    );
  }

  void _setVisible(bool visible) {
    if (_isUiVisible != visible && mounted) {
      setState(() => _isUiVisible = visible);
    }
    sl<PlayerCubit>().setUiVisible(visible);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caps = sl<PlatformCapabilities>();

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<PersonalizationCubit>.value(
          value: sl<PersonalizationCubit>(),
        ),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        BlocProvider<MusicFoldersCubit>.value(value: sl<MusicFoldersCubit>()),
        BlocProvider<LibraryCubit>.value(value: sl<LibraryCubit>()),
        BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return Builder(
            builder: (context) {
              final pState = context.watch<PersonalizationCubit>().state;
              final settings = context.watch<SettingsCubit>().state;
              final localeCode = settings.localeCode;
              final isArabic = localeCode == 'ar';
              final platformBrightness = MediaQuery.platformBrightnessOf(
                context,
              );
              final disableAnimations = MediaQuery.disableAnimationsOf(context);

              final isDarkResolved = WetarTokenResolver.resolveDarkMode(
                pState.settings,
                platformBrightness,
              );
              final Color? sysAccent = caps.supportsSystemDynamicColor
                  ? (isDarkResolved
                        ? darkDynamic?.primary
                        : lightDynamic?.primary)
                  : null;

              final theme = WetarTokenResolver.buildThemeData(
                pState.settings,
                platformBrightness: platformBrightness,
                systemDisableAnimations: disableAnimations,
                isArabicLocale: isArabic,
                artworkPrimary: pState.artworkPrimary,
                artworkSecondary: pState.artworkSecondary,
                systemAccent: sysAccent,
              );

              final isLite = WetarTokenResolver.resolveLiteMode(
                pState.settings,
                systemDisableAnimations: disableAnimations,
              );

              return BlocListener<SettingsCubit, PlaybackSettings>(
                listenWhen: (prev, curr) => prev != curr,
                listener: (context, nextSettings) {
                  sl<LibraryCubit>().updateMinDurationSec(
                    nextSettings.minTrackDurationSec,
                  );
                  unawaited(
                    sl<WetarAudioHandler>().applyPlaybackSettings(nextSettings),
                  );
                },
                child: TickerMode(
                  enabled: _isUiVisible && !isLite,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    scaffoldMessengerKey: WetarFeedback.messengerKey,
                    locale: Locale(localeCode),
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
                    theme: theme,
                    home: const WetarAppShell(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
