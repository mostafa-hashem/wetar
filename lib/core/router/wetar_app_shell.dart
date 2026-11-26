import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_artwork_image.dart';
import 'package:wetar/core/widgets/wetar_brand_logo.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/equalizer/presentation/screens/equalizer_screen.dart';
import 'package:wetar/features/library/domain/library_models.dart';
import 'package:wetar/features/library/presentation/bloc/library_cubit.dart';
import 'package:wetar/features/library/presentation/screens/home_screen.dart';
import 'package:wetar/features/library/presentation/screens/library_screen.dart';
import 'package:wetar/features/library/presentation/screens/search_screen.dart';
import 'package:wetar/features/lyrics/presentation/widgets/lyrics_sheet.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import 'package:wetar/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:wetar/features/personalization/data/artwork_palette_extractor.dart';
import 'package:wetar/features/personalization/domain/appearance_settings.dart';
import 'package:wetar/features/personalization/presentation/bloc/personalization_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/personalization/presentation/widgets/wetar_background_renderer.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/features/player/presentation/screens/car_mode_screen.dart';
import 'package:wetar/features/player/presentation/screens/now_playing_screen.dart';
import 'package:wetar/features/player/presentation/widgets/queue_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/share_track_card_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/track_details_sheet.dart';
import 'package:wetar/features/player/presentation/widgets/wetar_mini_player.dart';
import 'package:wetar/features/player/presentation/widgets/wetar_seek_bar.dart';
import 'package:wetar/features/playlists/presentation/screens/playlists_screen.dart';
import 'package:wetar/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/features/settings/presentation/screens/backup_stats_diagnostics_screen.dart';
import 'package:wetar/features/settings/presentation/screens/settings_screen.dart';
import 'package:wetar/l10n/app_localizations.dart';

enum _DesktopRightPane { none, queue, lyrics }

class _TogglePlayIntent extends Intent {
  const _TogglePlayIntent();
}

class _SeekStepIntent extends Intent {
  const _SeekStepIntent(this.deltaSeconds);
  final int deltaSeconds;
}

class _OpenSearchIntent extends Intent {
  const _OpenSearchIntent();
}

class _ToggleQueueIntent extends Intent {
  const _ToggleQueueIntent();
}

class _ToggleLyricsIntent extends Intent {
  const _ToggleLyricsIntent();
}

class _OpenSettingsIntent extends Intent {
  const _OpenSettingsIntent();
}

class _GuardedPlaybackAction<T extends Intent> extends Action<T> {
  _GuardedPlaybackAction({required this.canRun, required this.onInvoke});

  final bool Function() canRun;
  final void Function(T intent) onInvoke;

  @override
  bool isEnabled(T intent) => canRun();

  @override
  Object? invoke(T intent) {
    onInvoke(intent);
    return null;
  }
}

/// Top-level adaptive shell hosting mobile tabs or desktop sidebar + right inspector,
/// persistent mini player / transport bar, keyboard shortcuts, macOS menu bar,
/// compact mini-player window mode, and OS incoming file/folder events.
class WetarAppShell extends StatefulWidget {
  const WetarAppShell({super.key});

  @override
  State<WetarAppShell> createState() => _WetarAppShellState();
}

class _WetarAppShellState extends State<WetarAppShell> {
  int _navIndex = 0;
  bool _initialTabApplied = false;
  bool _isCompactWindow = false;
  bool _isNowPlayingOpen = false;
  _DesktopRightPane _rightPane = _DesktopRightPane.none;
  String? _lastPaletteAlbumKey;
  StreamSubscription<PlatformIncomingEvent>? _eventsSub;
  Timer? _fsRescanDebounce;

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
        } else if (event.target == 'car_mode') {
          _openCarMode();
        }
      } else if (event is FolderChangedIncomingEvent) {
        _fsRescanDebounce?.cancel();
        _fsRescanDebounce = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            unawaited(context.read<MusicFoldersCubit>().rescanAll());
          }
        });
      } else if (event is FolderDroppedIncomingEvent) {
        if (event.rootPath.isEmpty) return;
        final l10n = AppLocalizations.of(context);
        unawaited(
          context
              .read<MusicFoldersCubit>()
              .addDroppedFolder(
                rootPath: event.rootPath,
                displayName: event.displayName.isNotEmpty
                    ? event.displayName
                    : event.rootPath.split('/').last,
                bookmarkData: event.bookmarkData,
              )
              .then((_) {
                if (mounted) {
                  WetarFeedback.showSuccess(
                    context,
                    l10n.foldersAddedSuccess(event.displayName),
                  );
                }
              }),
        );
      }
    });
  }

  @override
  void dispose() {
    _fsRescanDebounce?.cancel();
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  bool _isTextFieldFocused() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    return ctx.widget is EditableText ||
        ctx.findAncestorWidgetOfExactType<EditableText>() != null;
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

  void _openSearch() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SearchScreen(
            onOpenTrackDetails: _openTrackDetails,
            onAddToPlaylistRequested: _openAddToPlaylist,
          ),
        ),
      ),
    );
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

  void _openCarMode() {
    unawaited(
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const CarModeScreen())),
    );
  }

  void _openBackupAndStats() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const BackupStatsDiagnosticsScreen(),
        ),
      ),
    );
  }

  void _openNowPlaying() {
    if (_isNowPlayingOpen) return;
    _isNowPlayingOpen = true;
    unawaited(
      Navigator.of(context)
          .push(
            MaterialPageRoute<void>(
              builder: (ctx) => NowPlayingScreen(
                onOpenQueue: () => showWetarQueueSheet(ctx),
                onOpenLyrics: _openLyrics,
                onOpenEqualizer: _openEqualizer,
                onOpenCarMode: _openCarMode,
                onOpenTrackDetails: _openTrackDetails,
                onShareTrack: (track) => showShareTrackCardSheet(ctx, track),
              ),
            ),
          )
          .whenComplete(() {
            if (mounted) _isNowPlayingOpen = false;
          }),
    );
  }

  void _toggleRightPane(_DesktopRightPane pane, {required bool isDesktop}) {
    if (!isDesktop) {
      if (pane == _DesktopRightPane.queue) {
        showWetarQueueSheet(context);
      } else if (pane == _DesktopRightPane.lyrics) {
        _openLyrics();
      }
      return;
    }
    setState(() {
      _rightPane = _rightPane == pane ? _DesktopRightPane.none : pane;
    });
  }

  Future<void> _toggleCompactWindow() async {
    final next = !_isCompactWindow;
    setState(() => _isCompactWindow = next);
    await sl<SystemIntegrationService>().setCompactMiniPlayerMode(next);
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
          onOpenCarMode: _openCarMode,
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
        return SettingsScreen(
          onOpenEqualizer: _openEqualizer,
          onOpenBackupAndStats: _openBackupAndStats,
        );
    }
  }

  Widget _buildCompactWindowView(
    BuildContext context,
    PlayerStateSnapshot playerState,
    WetarTokens tokens,
    AppLocalizations l10n,
  ) {
    final track = playerState.currentTrack;
    final totalMs = (track?.durationMs ?? 0) <= 0 ? 1 : track!.durationMs;
    final progress = (playerState.position.inMilliseconds / totalMs).clamp(
      0.0,
      1.0,
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  WetarArtworkImage(
                    cacheKey: track?.albumKey ?? 'empty',
                    size: 58,
                    artworkUri: track?.artworkUri,
                    filePath: track?.filePath,
                    customArtPath: track?.customArtPath,
                    thumbnailCache: sl<ThumbnailPathCache>(),
                    decodeSizePx: 144,
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          track?.title ?? l10n.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          track?.displayArtist ?? l10n.queueEmpty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.desktopCompactMiniMode,
                    icon: const Icon(Icons.open_in_full_rounded, size: 18),
                    onPressed: _toggleCompactWindow,
                  ),
                ],
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      tooltip: l10n.actionPrevious,
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: track == null
                          ? null
                          : () => context.read<PlayerCubit>().previous(),
                    ),
                    IconButton.filled(
                      tooltip: playerState.isPlaying
                          ? l10n.actionPause
                          : l10n.actionPlay,
                      style: IconButton.styleFrom(
                        backgroundColor: tokens.accentPrimary,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: () =>
                          context.read<PlayerCubit>().togglePlayPause(),
                    ),
                    IconButton(
                      tooltip: l10n.actionNext,
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: track == null
                          ? null
                          : () => context.read<PlayerCubit>().next(),
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: track == null ? 0.0 : progress,
                  backgroundColor: tokens.borderSubtle,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    tokens.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context, {
    required List<WetarNavTab> tabs,
    required int safeIndex,
    required PlayerStateSnapshot playerState,
    required AppearanceSettings appearance,
    required NumeralStyle numerals,
    required PlatformCapabilities caps,
    required WetarTokens tokens,
    required AppLocalizations l10n,
  }) {
    final track = playerState.currentTrack;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Container(
                  width: 214,
                  decoration: BoxDecoration(
                    color: tokens.surface.withValues(alpha: 0.94),
                    border: BorderDirectional(
                      end: BorderSide(color: tokens.borderSubtle),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(tokens.spacingMd),
                          child: Row(
                            children: <Widget>[
                              const WetarBrandLogo(size: 28),
                              SizedBox(width: tokens.spacingSm),
                              Expanded(
                                child: Text(
                                  l10n.appName,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.actionSearch,
                                icon: const Icon(Icons.search_rounded),
                                onPressed: _openSearch,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.spacingSm,
                              vertical: tokens.spacingSm,
                            ),
                            children: <Widget>[
                              for (var i = 0; i < tabs.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: ListTile(
                                    dense: true,
                                    selected: i == safeIndex,
                                    selectedTileColor: tokens.accentPrimary
                                        .withValues(alpha: 0.14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        tokens.radiusCard * 0.75,
                                      ),
                                    ),
                                    leading: Icon(
                                      _tabIcon(tabs[i]),
                                      color: i == safeIndex
                                          ? tokens.accentPrimary
                                          : tokens.inkMuted,
                                    ),
                                    title: Text(
                                      _tabLabel(l10n, tabs[i]),
                                      style: TextStyle(
                                        color: i == safeIndex
                                            ? tokens.accentPrimary
                                            : tokens.inkPrimary,
                                        fontWeight: i == safeIndex
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () => setState(() => _navIndex = i),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (caps.supportsDesktopShell) ...<Widget>[
                          const Divider(height: 1),
                          ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.picture_in_picture_alt_rounded,
                            ),
                            title: Text(l10n.desktopCompactMiniMode),
                            onTap: _toggleCompactWindow,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              tokens.spacingMd,
                              0,
                              tokens.spacingMd,
                              tokens.spacingSm,
                            ),
                            child: Text(
                              l10n.desktopShortcutsHint,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: tokens.inkMuted),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: safeIndex,
                    children: tabs.map(_buildTabContent).toList(),
                  ),
                ),
                if (_rightPane != _DesktopRightPane.none)
                  Container(
                    width: 336,
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      border: BorderDirectional(
                        start: BorderSide(color: tokens.borderSubtle),
                      ),
                    ),
                    child: _rightPane == _DesktopRightPane.queue
                        ? const QueuePanel(embedded: true)
                        : const LyricsSheet(),
                  ),
              ],
            ),
          ),
          if (track != null)
            Container(
              height: 82,
              padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                border: Border(top: BorderSide(color: tokens.borderSubtle)),
              ),
              child: Row(
                children: <Widget>[
                  InkWell(
                    borderRadius: BorderRadius.circular(tokens.radiusCard),
                    onTap: _openNowPlaying,
                    child: SizedBox(
                      width: 220,
                      child: Row(
                        children: <Widget>[
                          WetarArtworkImage(
                            cacheKey: track.albumKey,
                            size: 52,
                            artworkUri: track.artworkUri,
                            filePath: track.filePath,
                            customArtPath: track.customArtPath,
                            thumbnailCache: sl<ThumbnailPathCache>(),
                            decodeSizePx: 144,
                          ),
                          SizedBox(width: tokens.spacingSm),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  track.displayArtist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spacingMd),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                tooltip: l10n.actionShuffle,
                                iconSize: 18,
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: playerState.shuffleEnabled
                                      ? tokens.accentPrimary
                                      : tokens.inkMuted,
                                ),
                                onPressed: () =>
                                    context.read<PlayerCubit>().toggleShuffle(),
                              ),
                              IconButton(
                                tooltip: l10n.actionPrevious,
                                icon: const Icon(Icons.skip_previous_rounded),
                                onPressed: () =>
                                    context.read<PlayerCubit>().previous(),
                              ),
                              IconButton.filled(
                                tooltip: playerState.isPlaying
                                    ? l10n.actionPause
                                    : l10n.actionPlay,
                                style: IconButton.styleFrom(
                                  backgroundColor: tokens.accentPrimary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: Icon(
                                  playerState.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                onPressed: () => context
                                    .read<PlayerCubit>()
                                    .togglePlayPause(),
                              ),
                              IconButton(
                                tooltip: l10n.actionNext,
                                icon: const Icon(Icons.skip_next_rounded),
                                onPressed: () =>
                                    context.read<PlayerCubit>().next(),
                              ),
                              Text(
                                '${NumeralFormatter.formatDuration(playerState.position, numerals)} / ${NumeralFormatter.formatDuration(track.duration, numerals)}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: tokens.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 22,
                          child: WetarSeekBar(
                            seedKey: track.stableKey,
                            style: appearance.seekBarStyle,
                            position: playerState.position,
                            duration: track.duration,
                            isPlaying: playerState.isPlaying,
                            abLoop: playerState.abLoop,
                            hapticsIntensity: appearance.hapticsIntensity,
                            onSeek: (d) => context.read<PlayerCubit>().seek(d),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: tokens.spacingMd),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: l10n.playerLyrics,
                        icon: Icon(
                          Icons.lyrics_outlined,
                          color: _rightPane == _DesktopRightPane.lyrics
                              ? tokens.accentPrimary
                              : null,
                        ),
                        onPressed: () => _toggleRightPane(
                          _DesktopRightPane.lyrics,
                          isDesktop: true,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.playerQueue,
                        icon: Icon(
                          Icons.queue_music_rounded,
                          color: _rightPane == _DesktopRightPane.queue
                              ? tokens.accentPrimary
                              : null,
                        ),
                        onPressed: () => _toggleRightPane(
                          _DesktopRightPane.queue,
                          isDesktop: true,
                        ),
                      ),
                      if (caps.supportsAnyAudioEffects)
                        IconButton(
                          tooltip: l10n.playerEqualizer,
                          icon: const Icon(Icons.equalizer_rounded),
                          onPressed: _openEqualizer,
                        ),
                      IconButton(
                        tooltip: l10n.playerNowPlaying,
                        icon: const Icon(Icons.open_in_full_rounded),
                        onPressed: _openNowPlaying,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
    final hasCompletedOnboarding = context.select(
      (SettingsCubit c) => c.state.hasCompletedOnboarding,
    );
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
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
    final isDesktopWidth = MediaQuery.sizeOf(context).width >= 760;

    final Widget scaffoldContent;
    if (_isCompactWindow) {
      scaffoldContent = _buildCompactWindowView(
        context,
        playerState,
        tokens,
        l10n,
      );
    } else if (isDesktopWidth) {
      scaffoldContent = _buildDesktopLayout(
        context,
        tabs: tabs,
        safeIndex: safeIndex,
        playerState: playerState,
        appearance: appearance,
        numerals: numerals,
        caps: caps,
        tokens: tokens,
        l10n: l10n,
      );
    } else {
      scaffoldContent = Scaffold(
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
      );
    }

    Widget shellBody = MultiBlocListener(
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
        child: scaffoldContent,
      ),
    );

    if (caps.supportsDesktopShell || isDesktopWidth) {
      shellBody = Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.space): _TogglePlayIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _SeekStepIntent(-5),
          SingleActivator(LogicalKeyboardKey.arrowRight): _SeekStepIntent(5),
          SingleActivator(LogicalKeyboardKey.keyF, meta: true):
              _OpenSearchIntent(),
          SingleActivator(LogicalKeyboardKey.keyF, control: true):
              _OpenSearchIntent(),
          SingleActivator(LogicalKeyboardKey.keyU, meta: true):
              _ToggleQueueIntent(),
          SingleActivator(LogicalKeyboardKey.keyU, control: true):
              _ToggleQueueIntent(),
          SingleActivator(LogicalKeyboardKey.keyL, meta: true):
              _ToggleLyricsIntent(),
          SingleActivator(LogicalKeyboardKey.keyL, control: true):
              _ToggleLyricsIntent(),
          SingleActivator(LogicalKeyboardKey.comma, meta: true):
              _OpenSettingsIntent(),
          SingleActivator(LogicalKeyboardKey.comma, control: true):
              _OpenSettingsIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _TogglePlayIntent: _GuardedPlaybackAction<_TogglePlayIntent>(
              canRun: () => !_isTextFieldFocused(),
              onInvoke: (_) =>
                  unawaited(context.read<PlayerCubit>().togglePlayPause()),
            ),
            _SeekStepIntent: _GuardedPlaybackAction<_SeekStepIntent>(
              canRun: () => !_isTextFieldFocused(),
              onInvoke: (intent) {
                final curr = context.read<PlayerCubit>().state.position;
                final dur =
                    context.read<PlayerCubit>().state.currentTrack?.duration ??
                    Duration.zero;
                final nextMs =
                    (curr.inMilliseconds + intent.deltaSeconds * 1000).clamp(
                      0,
                      dur.inMilliseconds > 0
                          ? dur.inMilliseconds
                          : curr.inMilliseconds + 30000,
                    );
                unawaited(
                  context.read<PlayerCubit>().seek(
                    Duration(milliseconds: nextMs),
                  ),
                );
              },
            ),
            _OpenSearchIntent: CallbackAction<_OpenSearchIntent>(
              onInvoke: (_) {
                _openSearch();
                return null;
              },
            ),
            _ToggleQueueIntent: CallbackAction<_ToggleQueueIntent>(
              onInvoke: (_) {
                _toggleRightPane(
                  _DesktopRightPane.queue,
                  isDesktop: isDesktopWidth,
                );
                return null;
              },
            ),
            _ToggleLyricsIntent: CallbackAction<_ToggleLyricsIntent>(
              onInvoke: (_) {
                _toggleRightPane(
                  _DesktopRightPane.lyrics,
                  isDesktop: isDesktopWidth,
                );
                return null;
              },
            ),
            _OpenSettingsIntent: CallbackAction<_OpenSettingsIntent>(
              onInvoke: (_) {
                _jumpToTab(WetarNavTab.settings);
                return null;
              },
            ),
          },
          child: shellBody,
        ),
      );
    }

    if (Platform.isMacOS && caps.supportsDesktopShell) {
      return PlatformMenuBar(
        menus: <PlatformMenuItem>[
          PlatformMenu(
            label: l10n.appName,
            menus: <PlatformMenuItem>[
              PlatformMenuItem(
                label: l10n.settingsTitle,
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.comma,
                  meta: true,
                ),
                onSelected: () => _jumpToTab(WetarNavTab.settings),
              ),
              const PlatformMenuItemGroup(
                members: <PlatformMenuItem>[
                  PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hide,
                  ),
                  PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.quit,
                  ),
                ],
              ),
            ],
          ),
          PlatformMenu(
            label: l10n.desktopMenuLibrary,
            menus: <PlatformMenuItem>[
              PlatformMenuItem(
                label: l10n.foldersAddButton,
                onSelected: () => unawaited(
                  context.read<MusicFoldersCubit>().pickSystemFolder(),
                ),
              ),
              PlatformMenuItem(
                label: l10n.actionRescan,
                onSelected: () =>
                    unawaited(context.read<MusicFoldersCubit>().rescanAll()),
              ),
              PlatformMenuItem(
                label: l10n.actionSearch,
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyF,
                  meta: true,
                ),
                onSelected: _openSearch,
              ),
            ],
          ),
          PlatformMenu(
            label: l10n.desktopMenuPlayback,
            menus: <PlatformMenuItem>[
              PlatformMenuItem(
                label: playerState.isPlaying
                    ? l10n.actionPause
                    : l10n.actionPlay,
                onSelected: () =>
                    unawaited(context.read<PlayerCubit>().togglePlayPause()),
              ),
              PlatformMenuItem(
                label: l10n.actionPrevious,
                onSelected: () =>
                    unawaited(context.read<PlayerCubit>().previous()),
              ),
              PlatformMenuItem(
                label: l10n.actionNext,
                onSelected: () => unawaited(context.read<PlayerCubit>().next()),
              ),
            ],
          ),
          PlatformMenu(
            label: l10n.desktopMenuView,
            menus: <PlatformMenuItem>[
              PlatformMenuItem(
                label: l10n.playerNowPlaying,
                onSelected: _openNowPlaying,
              ),
              PlatformMenuItem(
                label: l10n.playerQueue,
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyU,
                  meta: true,
                ),
                onSelected: () => _toggleRightPane(
                  _DesktopRightPane.queue,
                  isDesktop: isDesktopWidth,
                ),
              ),
              PlatformMenuItem(
                label: l10n.playerLyrics,
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyL,
                  meta: true,
                ),
                onSelected: () => _toggleRightPane(
                  _DesktopRightPane.lyrics,
                  isDesktop: isDesktopWidth,
                ),
              ),
              PlatformMenuItem(
                label: l10n.desktopCompactMiniMode,
                onSelected: () => unawaited(_toggleCompactWindow()),
              ),
            ],
          ),
        ],
        child: shellBody,
      );
    }

    return shellBody;
  }
}
