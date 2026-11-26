import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/router/wetar_app_shell.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/equalizer/presentation/bloc/equalizer_cubit.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/lyrics/presentation/bloc/lyrics_cubit.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/data/wetar_audio_handler.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/playlists/presentation/bloc/playlists_cubit.dart';
import 'package:wetar/features/settings/domain/playback_settings.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Root Wetar application widget wiring BLoC providers, lifecycle visibility,
/// and dynamic platform accent colors.
class WetarApp extends StatefulWidget {
  const WetarApp({super.key});

  @override
  State<WetarApp> createState() => _WetarAppState();
}

class _WetarAppState extends State<WetarApp> {
  late final AppLifecycleListener _lifecycleListener;
  bool _isUiVisible = true;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onShow: () => _setUiVisible(true),
      onResume: () => _setUiVisible(true),
      onHide: () => _setUiVisible(false),
      onPause: () => _setUiVisible(false),
    );
  }

  void _setUiVisible(bool visible) {
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
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<PersonalizationCubit>.value(
          value: sl<PersonalizationCubit>(),
        ),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        BlocProvider<MusicFoldersCubit>.value(value: sl<MusicFoldersCubit>()),
        BlocProvider<LibraryCubit>.value(value: sl<LibraryCubit>()),
        BlocProvider<PlaylistsCubit>.value(value: sl<PlaylistsCubit>()),
        BlocProvider<EqualizerCubit>.value(value: sl<EqualizerCubit>()),
        BlocProvider<LyricsCubit>.value(value: sl<LyricsCubit>()),
        BlocProvider<PlayerCubit>.value(value: sl<PlayerCubit>()),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return _WetarMaterialApp(
            isUiVisible: _isUiVisible,
            lightDynamicPrimary: lightDynamic?.primary,
            darkDynamicPrimary: darkDynamic?.primary,
          );
        },
      ),
    );
  }
}

class _WetarMaterialApp extends StatelessWidget {
  const _WetarMaterialApp({
    required this.isUiVisible,
    required this.lightDynamicPrimary,
    required this.darkDynamicPrimary,
  });

  final bool isUiVisible;
  final Color? lightDynamicPrimary;
  final Color? darkDynamicPrimary;

  @override
  Widget build(BuildContext context) {
    final caps = sl<PlatformCapabilities>();
    final personalization = context.watch<PersonalizationCubit>().state;
    final settings = context.watch<SettingsCubit>().state;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final isDarkResolved = WetarTokenResolver.resolveDarkMode(
      personalization.settings,
      platformBrightness,
    );
    final sysAccent = caps.supportsSystemDynamicColor
        ? (isDarkResolved ? darkDynamicPrimary : lightDynamicPrimary)
        : null;

    final theme = WetarTokenResolver.buildThemeData(
      personalization.settings,
      platformBrightness: platformBrightness,
      systemDisableAnimations: disableAnimations,
      isArabicLocale: settings.localeCode == 'ar',
      artworkPrimary: personalization.artworkPrimary,
      artworkSecondary: personalization.artworkSecondary,
      systemAccent: sysAccent,
    );

    final isLite = WetarTokenResolver.resolveLiteMode(
      personalization.settings,
      systemDisableAnimations: disableAnimations,
    );

    return BlocListener<SettingsCubit, PlaybackSettings>(
      listenWhen: (prev, curr) => prev != curr,
      listener: (context, nextSettings) {
        sl<LibraryCubit>().updateMinDurationSec(
          nextSettings.minTrackDurationSec,
        );
        unawaited(sl<WetarAudioHandler>().applyPlaybackSettings(nextSettings));
      },
      child: TickerMode(
        enabled: isUiVisible && !isLite,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: WetarFeedback.messengerKey,
          locale: Locale(settings.localeCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
          theme: theme,
          home: const WetarAppShell(),
        ),
      ),
    );
  }
}
