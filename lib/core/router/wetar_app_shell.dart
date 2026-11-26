import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/library/domain/library_models.dart';
import '../../features/library/presentation/bloc/library_cubit.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/music_folders/presentation/screens/music_folders_settings_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/personalization/domain/appearance_settings.dart';
import '../../features/personalization/presentation/bloc/personalization_cubit.dart';
import '../../features/personalization/presentation/theme/wetar_tokens.dart';
import '../../features/player/presentation/bloc/player_cubit.dart';
import '../../features/player/presentation/screens/now_playing_screen.dart';
import '../../features/player/presentation/widgets/wetar_mini_player.dart';
import '../../features/playlists/presentation/screens/playlists_screen.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../l10n/app_localizations.dart';
import '../di/service_locator.dart';
import '../platform/platform_interfaces.dart';
import '../widgets/wetar_feedback.dart';

/// Top-level adaptive shell hosting onboarding gate, bottom nav (<=5 tabs),
/// persistent mini player, and incoming Open-With / shortcut event listener.
class WetarAppShell extends StatefulWidget {
  const WetarAppShell({super.key});

  @override
  State<WetarAppShell> createState() => _WetarAppShellState();
}

class _WetarAppShellState extends State<WetarAppShell> {
  int _navIndex = 0;
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
        context.read<PlayerCubit>().playExternal(tempTrack);
      } else if (event is ShortcutIncomingEvent) {
        if (event.target == 'shuffle_all') {
          final tracks = context.read<LibraryCubit>().state.allTracks;
          context.read<PlayerCubit>().shuffleAll(tracks);
        } else if (event.target == 'favorites') {
          context.read<LibraryCubit>().setCategory(LibraryCategory.favorites);
          setState(() => _navIndex = 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
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
      case WetarNavTab.library:
        return LibraryScreen(
          onOpenTrackDetails: (_) {},
          onAddToPlaylistRequested: (_) {},
        );
      case WetarNavTab.folders:
        return const MusicFoldersSettingsScreen();
      case WetarNavTab.playlists:
        return const PlaylistsScreen();
      case WetarNavTab.settings:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final hasCompletedOnboarding = context.select(
      (SettingsCubit c) => c.state.hasCompletedOnboarding,
    );
    final tabs = context.select(
      (PersonalizationCubit c) => c.state.settings.visibleNavTabs,
    );

    if (!hasCompletedOnboarding) {
      return OnboardingScreen(onFinished: () => setState(() {}));
    }

    final safeIndex = _navIndex.clamp(0, tabs.length - 1);

    return BlocListener<PlayerCubit, PlayerStateSnapshot>(
      listenWhen: (prev, curr) =>
          curr.lastCorruptSkippedTitle != null &&
          prev.lastCorruptSkippedTitle != curr.lastCorruptSkippedTitle,
      listener: (context, state) {
        final title = state.lastCorruptSkippedTitle;
        if (title != null) {
          WetarFeedback.showError(context, l10n.playerCorruptSkipped(title));
          context.read<PlayerCubit>().clearCorruptNotice();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: safeIndex,
          children: tabs.map(_buildTabContent).toList(),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            WetarMiniPlayer(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NowPlayingScreen(),
                ),
              ),
            ),
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
    );
  }
}
