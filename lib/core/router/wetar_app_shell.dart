import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/equalizer/presentation/screens/equalizer_screen.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/screens/home_screen.dart';
import 'package:wetar/features/library/presentation/screens/library_screen.dart';
import 'package:wetar/features/lyrics/presentation/widgets/lyrics_sheet.dart';
import 'package:wetar/features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import 'package:wetar/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:wetar/features/personalization/data/artwork_palette_extractor.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/personalization/presentation/widgets/wetar_background_renderer.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/player/presentation/screens/now_playing_screen.dart';
import 'package:wetar/features/player/presentation/widgets/queue_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/track_details_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/wetar_mini_player.dart';
import 'package:wetar/features/playlists/presentation/screens/playlists_screen.dart';
import 'package:wetar/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/features/settings/presentation/screens/settings_screen.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Top-level adaptive shell hosting onboarding gate, bottom nav (<=5 tabs),
/// persistent mini player, artwork palette synchronization, and Open-With events.
class WetarAppShell extends StatefulWidget {
  const WetarAppShell({super.key});

  @override
  State<WetarAppShell> createState() => _WetarAppShellState();
}

class _WetarAppShellState extends State<WetarAppShell> {
  int _navIndex = 0;
  bool _initialTabApplied = false;
  String? _lastPaletteAlbumKey;
  StreamSubscription<PlatformIncomingEvent>? _eventsSub;

  @override
  void initState() {
    super.initState();
    _eventsSub = sl<SystemIntegrationService>().incomingEvents.listen((event) {
      if (!mounted) return;
      if (event is OpenWithIncomingEvent) {
        final path = event.filePath ?? event.uri;
        if (path.isEmpty) return;
        final tempTrack = WetarTrack(
          stableKey: 'ext_${event.uri}',
          folderId: -1,
          uri: event.uri,
          filePath: path,
          folderPath: event.parentFolderPath ?? '',
          title: event.displayName ?? path.split('/').last,
          artist: '',
          album: '',
          albumArtist: '',
          genre: '',
          year: 0,
          trackNumber: 0,
          discNumber: 1,
          durationMs: 0,
          bitrateKbps: 0,
          sampleRateHz: 0,
          channels: 2,
          sizeBytes: 0,
          mimeType: event.mimeType ?? 'audio/*',
          dateModifiedSec: 0,
          dateAddedSec: 0,
          isTemporaryExternal: true,
        );
        unawaited(context.read<PlayerCubit>().playExternal(tempTrack));
      } else if (event is ShortcutIncomingEvent) {
        if (event.target == 'shuffle_all') {
          final tracks = context.read<LibraryCubit>().state.allTracks;
          unawaited(context.read<PlayerCubit>().shuffleAll(tracks));
        } else if (event.target == 'favorites') {
          context.read<LibraryCubit>().setCategory(LibraryCategory.favorites);
          _jumpToTab(WetarNavTab.library);
        }
      }
    });
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  void _jumpToTab(WetarNavTab target) {
    final tabs = context
        .read<PersonalizationCubit>()
        .state
        .settings
        .visibleNavTabs;
    final idx = tabs.indexOf(target);
    if (idx >= 0) {
      setState(() => _navIndex = idx);
    }
  }

  Future<void> _syncArtworkPalette(WetarTrack? track) async {
    if (track == null) {
      _lastPaletteAlbumKey = null;
      context.read<PersonalizationCubit>().setArtworkColors();
      return;
    }
    if (track.albumKey == _lastPaletteAlbumKey) return;
    _lastPaletteAlbumKey = track.albumKey;
    final palette = await sl<ArtworkPaletteExtractor>().extractForTrack(
      albumKey: track.albumKey,
      customArtPath: track.customArtPath,
      artworkUri: track.artworkUri,
      filePath: track.filePath,
    );
    if (!mounted) return;
    context.read<PersonalizationCubit>().setArtworkColors(
      primary: palette?.primary,
      secondary: palette?.secondary,
    );
  }

  void _openTrackDetails(WetarTrack track) {
    final numerals = context.read<SettingsCubit>().state.numeralStyle;
    showTrackDetailsSheet(context, track: track, numerals: numerals);
  }

  void _openAddToPlaylist(List<WetarTrack> tracks) {
    showAddToPlaylistSheet(context, tracks: tracks);
  }

  void _openEqualizer() {
    unawaited(
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const EqualizerScreen())),
    );
  }

  void _openLyrics() {
    unawaited(
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const LyricsSheet())),
    );
  }

  void _openNowPlaying() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (ctx) => NowPlayingScreen(
            onOpenQueue: () => showWetarQueueSheet(ctx),
            onOpenLyrics: _openLyrics,
            onOpenEqualizer: _openEqualizer,
            onOpenTrackDetails: _openTrackDetails,
          ),
        ),
      ),
    );
  }

  String _tabLabel(AppLocalizations l10n, WetarNavTab tab) {
    return switch (tab) {
      WetarNavTab.home => l10n.navHome,
      WetarNavTab.library => l10n.navLibrary,
      WetarNavTab.folders => l10n.navFolders,
      WetarNavTab.playlists => l10n.navPlaylists,
      WetarNavTab.settings => l10n.navSettings,
    };
  }

  IconData _tabIcon(WetarNavTab tab) {
    return switch (tab) {
      WetarNavTab.home => Icons.home_rounded,
      WetarNavTab.library => Icons.library_music_rounded,
      WetarNavTab.folders => Icons.folder_copy_rounded,
      WetarNavTab.playlists => Icons.queue_music_rounded,
      WetarNavTab.settings => Icons.settings_rounded,
    };
  }

  Widget _buildTabContent(WetarNavTab tab) {
    switch (tab) {
      case WetarNavTab.home:
        return HomeScreen(
          onOpenNowPlaying: _openNowPlaying,
          onOpenFavorites: () {
            context.read<LibraryCubit>().setCategory(LibraryCategory.favorites);
            _jumpToTab(WetarNavTab.library);
          },
          onOpenPlaylists: () => _jumpToTab(WetarNavTab.playlists),
          onOpenCarMode: () {},
          onOpenTrackDetails: _openTrackDetails,
          onAddToPlaylistRequested: _openAddToPlaylist,
        );
      case WetarNavTab.library:
        return LibraryScreen(
          onOpenTrackDetails: _openTrackDetails,
          onAddToPlaylistRequested: _openAddToPlaylist,
        );
      case WetarNavTab.folders:
        return const MusicFoldersSettingsScreen();
      case WetarNavTab.playlists:
        return PlaylistsScreen(onOpenTrackDetails: _openTrackDetails);
      case WetarNavTab.settings:
        return SettingsScreen(onOpenEqualizer: _openEqualizer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final hasCompletedOnboarding = context.select(
      (SettingsCubit c) => c.state.hasCompletedOnboarding,
    );
    final appearance = context.select(
      (PersonalizationCubit c) => c.state.settings,
    );
    final tabs = appearance.visibleNavTabs;

    if (!hasCompletedOnboarding) {
      return OnboardingScreen(onFinished: () => setState(() {}));
    }

    if (!_initialTabApplied) {
      _initialTabApplied = true;
      final defaultIdx = tabs.indexOf(appearance.defaultStartTab);
      if (defaultIdx >= 0) _navIndex = defaultIdx;
    }

    final safeIndex = _navIndex.clamp(0, tabs.length - 1);
    final playerState = context.watch<PlayerCubit>().state;

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<PlayerCubit, PlayerStateSnapshot>(
          listenWhen: (prev, curr) =>
              curr.lastCorruptSkippedTitle != null &&
              prev.lastCorruptSkippedTitle != curr.lastCorruptSkippedTitle,
          listener: (context, state) {
            final title = state.lastCorruptSkippedTitle;
            if (title != null) {
              WetarFeedback.showError(
                context,
                l10n.playerCorruptSkipped(title),
              );
              context.read<PlayerCubit>().clearCorruptNotice();
            }
          },
        ),
        BlocListener<PlayerCubit, PlayerStateSnapshot>(
          listenWhen: (prev, curr) =>
              prev.currentTrack?.albumKey != curr.currentTrack?.albumKey,
          listener: (context, state) {
            unawaited(_syncArtworkPalette(state.currentTrack));
          },
        ),
      ],
      child: WetarBackgroundRenderer(
        surfaceLocation: BackgroundScope.wholeApp,
        activeTrack: playerState.currentTrack,
        isPlaying: playerState.isPlaying,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: safeIndex,
            children: tabs.map(_buildTabContent).toList(),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              WetarMiniPlayer(onTap: _openNowPlaying),
              NavigationBar(
                backgroundColor: tokens.surface,
                indicatorColor: tokens.accentPrimary.withValues(alpha: 0.2),
                selectedIndex: safeIndex,
                onDestinationSelected: (idx) => setState(() => _navIndex = idx),
                destinations: tabs
                    .map(
                      (tab) => NavigationDestination(
                        icon: Icon(_tabIcon(tab)),
                        label: _tabLabel(l10n, tab),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
