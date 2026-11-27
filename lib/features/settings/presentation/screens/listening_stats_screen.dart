import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:wetar/core/database/wetar_database.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/core/widgets/wetar_responsive.dart';
import 'package:wetar/features/library/data/library_repository.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/player/data/wetar_audio_handler.dart';
import 'package:wetar/features/player/domain/listening_session_tracker.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

class _RecapSummary {
  const _RecapSummary({
    required this.totalMs,
    required this.totalPlays,
    required this.topTracks,
    required this.topArtists,
  });

  final int totalMs;
  final int totalPlays;
  final List<(String, int)> topTracks;
  final List<(String, int)> topArtists;
}

/// Offline listening recap ("Wetar Wrapped") strictly computed from local Drift history.
class ListeningStatsScreen extends StatefulWidget {
  const ListeningStatsScreen({super.key});

  @override
  State<ListeningStatsScreen> createState() => _ListeningStatsScreenState();
}

class _ListeningStatsScreenState extends State<ListeningStatsScreen> {
  final GlobalKey _posterKey = GlobalKey();
  late Future<_RecapSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<_RecapSummary> _loadSummary() async {
    if (sl.isRegistered<WetarAudioHandler>()) {
      await sl<WetarAudioHandler>().flushListeningSession();
    }
    final db = sl<WetarDatabase>();
    final rows = await db.customSelect('''
      SELECT h.track_title, h.artist_name, h.listened_ms, t.duration_ms
      FROM play_history_events h
      INNER JOIN tracks t ON t.stable_key = h.track_stable_key
      INNER JOIN selected_folders sf ON sf.id = t.folder_id AND sf.is_available = 1
      ''').get();

    var totalMs = 0;
    var totalPlays = 0;
    final trackCounts = <String, int>{};
    final artistCounts = <String, int>{};

    for (final r in rows) {
      final ms = r.read<int>('listened_ms');
      final durationMs = r.read<int>('duration_ms');
      final title = r.read<String>('track_title');
      final artist = r.read<String>('artist_name');
      totalMs += ms;
      if (ms >= ListeningSessionTracker.qualifyingPlayThresholdMs(durationMs)) {
        totalPlays++;
        trackCounts[title] = (trackCounts[title] ?? 0) + 1;
        if (artist.isNotEmpty) {
          artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
        }
      }
    }

    final topTracks = trackCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _RecapSummary(
      totalMs: totalMs,
      totalPlays: totalPlays,
      topTracks: topTracks.take(5).map((e) => (e.key, e.value)).toList(),
      topArtists: topArtists.take(5).map((e) => (e.key, e.value)).toList(),
    );
  }

  Future<void> _confirmResetStats() async {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.statsResetTitle),
        content: Text(l10n.statsResetBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: tokens.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionReset),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (sl.isRegistered<WetarAudioHandler>()) {
      await sl<WetarAudioHandler>().flushListeningSession(endSession: true);
    }
    if (sl.isRegistered<LibraryRepository>()) {
      await sl<LibraryRepository>().clearListeningHistory();
    }
    if (!mounted) return;
    setState(() {
      _summaryFuture = _loadSummary();
    });
    WetarFeedback.showSuccess(context, l10n.statsResetSuccess);
  }

  String _formatTotalListeningTime(
    AppLocalizations l10n,
    int totalMs,
    NumeralStyle numerals,
  ) {
    if (totalMs <= 0) {
      return l10n.statsDurationMinutes(NumeralFormatter.formatInt(0, numerals));
    }
    if (totalMs < 60000) {
      final sec = math.max(1, (totalMs / 1000).round());
      return l10n.statsDurationSeconds(
        NumeralFormatter.formatInt(sec, numerals),
      );
    }
    if (totalMs < 3600000) {
      final min = (totalMs / 60000).round();
      return l10n.statsDurationMinutes(
        NumeralFormatter.formatInt(min, numerals),
      );
    }
    final hours = totalMs ~/ 3600000;
    final mins = (totalMs % 3600000) ~/ 60000;
    return l10n.statsDurationHoursMinutes(
      NumeralFormatter.formatInt(hours, numerals),
      NumeralFormatter.formatInt(mins, numerals),
    );
  }

  Future<void> _sharePoster() async {
    final boundary =
        _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2.5);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) return;
    final cache = sl<CacheManager>();
    await cache.init();
    final path = p.join(
      cache.exportsDir.path,
      'wetar_wrapped_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await File(path).writeAsBytes(data.buffer.asUint8List(), flush: true);
    await sl<FolderPickerService>().shareFiles(
      paths: <String>[path],
      mimeType: 'image/png',
      subject: 'Wetar Wrapped',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.actionReset,
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _confirmResetStats,
          ),
          IconButton(
            tooltip: l10n.statsSharePoster,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _sharePoster,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<_RecapSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            final summary = snapshot.data;
            if (summary == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return LayoutBuilder(
              builder: (context, constraints) => ListView(
                padding: WetarResponsive.listPadding(
                  constraints.maxWidth,
                  minHorizontal: tokens.spacingMd,
                  top: tokens.spacingMd,
                  bottom: tokens.spacingLg,
                  maxWidth: 720,
                ),
                children: <Widget>[
                  RepaintBoundary(
                    key: _posterKey,
                    child: Container(
                      padding: EdgeInsets.all(tokens.spacingLg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color.lerp(
                              tokens.canvas,
                              tokens.accentPrimary,
                              0.35,
                            )!,
                            tokens.surface,
                            Color.lerp(
                              tokens.canvas,
                              tokens.accentSecondary,
                              0.25,
                            )!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          tokens.radiusCard * 1.3,
                        ),
                        border: Border.all(
                          color: tokens.accentPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${l10n.appName} Wrapped',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: tokens.accentPrimary,
                                ),
                          ),
                          SizedBox(height: tokens.spacingMd),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _StatTile(
                                  label: l10n.statsTotalTime,
                                  value: _formatTotalListeningTime(
                                    l10n,
                                    summary.totalMs,
                                    numerals,
                                  ),
                                ),
                              ),
                              SizedBox(width: tokens.spacingSm),
                              Expanded(
                                child: _StatTile(
                                  label: l10n.statsTotalPlays,
                                  value: NumeralFormatter.formatInt(
                                    summary.totalPlays,
                                    numerals,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: tokens.spacingMd),
                          Text(
                            l10n.statsTopArtists,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          for (var i = 0; i < summary.topArtists.length; i++)
                            Text(
                              '${NumeralFormatter.formatInt(i + 1, numerals)}. ${summary.topArtists[i].$1} (${NumeralFormatter.formatInt(summary.topArtists[i].$2, numerals)})',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          SizedBox(height: tokens.spacingMd),
                          Text(
                            l10n.statsTopTracks,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          for (var i = 0; i < summary.topTracks.length; i++)
                            Text(
                              '${NumeralFormatter.formatInt(i + 1, numerals)}. ${summary.topTracks[i].$1}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spacingLg),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.accentPrimary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _sharePoster,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.statsSharePoster),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wetarTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: tokens.inkMuted),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            maxLines: 1,
            softWrap: false,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
