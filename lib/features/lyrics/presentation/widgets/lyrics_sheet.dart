import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/features/lyrics/presentation/bloc/lyrics_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/presentation/bloc/player_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Synced & unsynced lyrics sheet with auto-scroll, tap-to-seek,
/// per-line Arabic RTL / Latin LTR alignment, font scaling, and +/-100ms offset.
class LyricsSheet extends StatefulWidget {
  const LyricsSheet({super.key});

  @override
  State<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends State<LyricsSheet> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIdx = -1;

  @override
  void initState() {
    super.initState();
    final track = context.read<PlayerCubit>().state.currentTrack;
    unawaited(context.read<LyricsCubit>().loadForTrack(track));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLine(int idx) {
    if (idx < 0 || idx == _lastActiveIdx || !_scrollController.hasClients) {
      return;
    }
    _lastActiveIdx = idx;
    final target = (idx * 52.0 - 140.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    unawaited(
      _scrollController.animateTo(
        target,
        duration: context.wetarTokens.motionDuration,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;

    return BlocListener<PlayerCubit, PlayerStateSnapshot>(
      listenWhen: (prev, curr) =>
          prev.currentTrack?.stableKey != curr.currentTrack?.stableKey,
      listener: (context, pState) {
        unawaited(
          context.read<LyricsCubit>().loadForTrack(pState.currentTrack),
        );
      },
      child: BlocBuilder<LyricsCubit, LyricsState>(
        builder: (context, lyricsState) {
          final playerState = context.watch<PlayerCubit>().state;
          final track = playerState.currentTrack;
          final activeIdx = lyricsState.parsed.activeLineIndexAt(
            playerState.position,
            userOffsetMs: lyricsState.userOffsetMs,
          );
          if (activeIdx >= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _scrollToLine(activeIdx);
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.playerLyrics),
              actions: <Widget>[
                if (track != null)
                  IconButton(
                    tooltip: l10n.lyricsAttachLrc,
                    icon: const Icon(Icons.attach_file_rounded),
                    onPressed: () =>
                        context.read<LyricsCubit>().attachLrcFromPicker(track),
                  ),
              ],
            ),
            body: Column(
              children: <Widget>[
                if (track != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacingMd,
                      vertical: tokens.spacingXs,
                    ),
                    color: tokens.surface,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => context
                              .read<LyricsCubit>()
                              .adjustOffset(track, -200),
                        ),
                        Expanded(
                          child: Text(
                            l10n.lyricsOffsetLabel(lyricsState.userOffsetMs),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => context
                              .read<LyricsCubit>()
                              .adjustOffset(track, 200),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
                  child: Row(
                    children: <Widget>[
                      Text(
                        l10n.lyricsFontSize,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Expanded(
                        child: Slider(
                          min: 14,
                          max: 30,
                          value: lyricsState.fontSize,
                          onChanged: (v) =>
                              context.read<LyricsCubit>().setFontSize(v),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: lyricsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : lyricsState.parsed.lines.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(tokens.spacingLg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.lyrics_outlined,
                                  size: 52,
                                  color: tokens.accentPrimary,
                                ),
                                SizedBox(height: tokens.spacingMd),
                                Text(
                                  l10n.lyricsEmptyTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                SizedBox(height: tokens.spacingSm),
                                Text(
                                  l10n.lyricsEmptyBody,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (track != null) ...<Widget>[
                                  SizedBox(height: tokens.spacingMd),
                                  FilledButton.tonalIcon(
                                    onPressed: () => context
                                        .read<LyricsCubit>()
                                        .attachLrcFromPicker(track),
                                    icon: const Icon(Icons.file_open_outlined),
                                    label: Text(l10n.lyricsAttachLrc),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(tokens.spacingLg),
                          itemCount: lyricsState.parsed.lines.length,
                          itemBuilder: (context, idx) {
                            final line = lyricsState.parsed.lines[idx];
                            final isActive = idx == activeIdx;
                            return InkWell(
                              borderRadius: BorderRadius.circular(
                                tokens.radiusCard,
                              ),
                              onTap: line.timestamp == null
                                  ? null
                                  : () =>
                                        sl<PlayerCubit>().seek(line.timestamp!),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: tokens.spacingSm,
                                  horizontal: tokens.spacingSm,
                                ),
                                child: Directionality(
                                  textDirection: line.isRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: Text(
                                    line.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isActive
                                          ? lyricsState.fontSize + 3
                                          : lyricsState.fontSize,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isActive
                                          ? tokens.accentPrimary
                                          : tokens.inkMuted,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
