import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/logging/app_logger.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/storage/cache_manager.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/data/backup_service.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/features/settings/presentation/screens/listening_stats_screen.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Hub for local JSON Backup/Restore, Wetar Wrapped recap, bounded Cache management,
/// offline Diagnostics log viewer/share, and Android OEM battery exemption guidance.
class BackupStatsDiagnosticsScreen extends StatefulWidget {
  const BackupStatsDiagnosticsScreen({super.key});

  @override
  State<BackupStatsDiagnosticsScreen> createState() =>
      _BackupStatsDiagnosticsScreenState();
}

class _BackupStatsDiagnosticsScreenState
    extends State<BackupStatsDiagnosticsScreen> {
  CacheStats? _cacheStats;
  String _logs = '';
  bool _ignoringBattery = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final stats = await sl<CacheManager>().computeStats();
    final logText = await AppLogger.readFullLog();
    final batteryOk = await sl<SystemIntegrationService>()
        .isIgnoringBatteryOptimizations();
    if (mounted) {
      setState(() {
        _cacheStats = stats;
        _logs = logText;
        _ignoringBattery = batteryOk;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);
    final cacheBytes = _cacheStats?.clearableCacheBytes ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsBackup)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.spacingMd,
            tokens.spacingMd,
            tokens.spacingMd,
            tokens.spacingLg,
          ),
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.auto_graph_rounded,
                color: tokens.accentPrimary,
              ),
              title: Text(l10n.statsTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ListeningStatsScreen(),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(l10n.backupExportJson),
              onTap: () async {
                final jsonText = await sl<BackupService>().exportToJson();
                final ok = await sl<FolderPickerService>().saveFile(
                  fileName:
                      'wetar_backup_${DateTime.now().millisecondsSinceEpoch}.json',
                  mimeType: 'application/json',
                  bytes: Uint8List.fromList(utf8.encode(jsonText)),
                );
                if (ok && context.mounted) {
                  WetarFeedback.showSuccess(context, l10n.backupSuccess);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_outlined),
              title: Text(l10n.backupImportJson),
              onTap: () async {
                final path = await sl<FolderPickerService>().pickFile(
                  mimeTypes: const <String>['application/json', '*/*'],
                );
                if (path == null) return;
                final raw = await File(path).readAsString();
                final ok = await sl<BackupService>().importFromJson(raw);
                if (context.mounted) {
                  if (ok) {
                    WetarFeedback.showSuccess(context, l10n.backupRestored);
                    await context.read<MusicFoldersCubit>().rescanAll();
                  } else {
                    WetarFeedback.showError(context, l10n.backupInvalid);
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(l10n.cacheClearButton),
              subtitle: Text(
                l10n.cacheSizeLabel(
                  NumeralFormatter.formatBytes(cacheBytes, numerals),
                ),
              ),
              onTap: () async {
                await sl<CacheManager>().clearTemporaryCaches();
                await _refresh();
              },
            ),
            if (caps.supportsBatteryOptimizationGuide) ...<Widget>[
              const Divider(),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.batteryGuideTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.spacingXs),
                      Text(
                        _ignoringBattery
                            ? l10n.batteryGuideOptimizedOk
                            : l10n.batteryGuideBody,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: tokens.inkMuted),
                      ),
                      if (!_ignoringBattery) ...<Widget>[
                        SizedBox(height: tokens.spacingSm),
                        FilledButton.tonal(
                          onPressed: () => sl<SystemIntegrationService>()
                              .openBatteryOptimizationSettings(),
                          child: Text(l10n.batteryGuideAction),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l10n.diagnosticsTitle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.diagnosticsClear,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await AppLogger.clearLogs();
                      await _refresh();
                    },
                  ),
                  IconButton(
                    tooltip: l10n.diagnosticsShare,
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () async {
                      final logPath = AppLogger.logFilePath;
                      if (logPath != null && File(logPath).existsSync()) {
                        await sl<FolderPickerService>().shareFiles(
                          paths: <String>[logPath],
                          mimeType: 'text/plain',
                          subject: 'Wetar Diagnostics Log',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 180,
              padding: EdgeInsets.all(tokens.spacingSm),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radiusCard),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  child: SelectableText(
                    _logs.isEmpty ? 'No diagnostics entries yet.' : _logs,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
