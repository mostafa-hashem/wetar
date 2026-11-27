import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/music_folders/domain/music_folder_models.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/music_folders/presentation/screens/folder_picker_screen.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// Settings > Music Folders management view with include-subfolders toggle,
/// exclude-subfolder management, single-folder rescan, remove + undo, and availability badges.
class MusicFoldersSettingsScreen extends StatelessWidget {
  const MusicFoldersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foldersTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.actionRescan,
            onPressed: () => context.read<MusicFoldersCubit>().rescanAll(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: l10n.foldersAddButton,
            onPressed: () async {
              if (caps.supportsInAppFolderPicker) {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FolderPickerScreen(),
                  ),
                );
              } else {
                await context.read<MusicFoldersCubit>().pickSystemFolder();
              }
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<MusicFoldersCubit, MusicFoldersState>(
          builder: (context, state) {
            return Column(
              children: <Widget>[
                if (state.scanProgress.isScanning)
                  Material(
                    color: tokens.surfaceElevated,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                        vertical: tokens.spacingSm,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.foldersScanProgress(
                                    state.scanProgress.currentFolderName,
                                    state.scanProgress.processedCount,
                                    state.scanProgress.totalCount,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: tokens.spacingXs),
                                LinearProgressIndicator(
                                  value: state.scanProgress.fraction,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<MusicFoldersCubit>().cancelScan();
                              WetarFeedback.showInfo(
                                context,
                                l10n.foldersScanCancelled,
                              );
                            },
                            child: Text(l10n.actionCancel),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: state.selectedFolders.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(tokens.spacingLg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.folder_off_outlined,
                                  size: 56,
                                  color: tokens.accentPrimary,
                                ),
                                SizedBox(height: tokens.spacingMd),
                                Text(
                                  l10n.foldersEmptyTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: tokens.spacingSm),
                                Text(
                                  l10n.foldersEmptySubtitle,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: tokens.inkMuted),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: tokens.spacingLg),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: tokens.accentPrimary,
                                  ),
                                  onPressed: () async {
                                    if (caps.supportsInAppFolderPicker) {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const FolderPickerScreen(),
                                        ),
                                      );
                                    } else {
                                      await context
                                          .read<MusicFoldersCubit>()
                                          .pickSystemFolder();
                                    }
                                  },
                                  icon: const Icon(Icons.folder_open_rounded),
                                  label: Text(l10n.foldersChooseCta),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            tokens.spacingMd,
                            tokens.spacingMd,
                            tokens.spacingMd,
                            tokens.spacingLg,
                          ),
                          itemCount: state.selectedFolders.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: tokens.spacingSm),
                          itemBuilder: (context, index) {
                            final folder = state.selectedFolders[index];
                            return _FolderCard(
                              folder: folder,
                              numerals: numerals,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.folder, required this.numerals});

  final SelectedFolderEntity folder;
  final NumeralStyle numerals;

  Future<void> _showExcludeDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final subDirs = <String>[];
    if (!folder.rootPath.startsWith('content://')) {
      final dir = Directory(folder.rootPath);
      if (dir.existsSync()) {
        await for (final entity in dir.list(followLinks: false)) {
          if (entity is Directory) {
            subDirs.add(entity.path);
          }
        }
      }
    }

    if (!context.mounted) return;
    final selectedExcluded = Set<String>.from(folder.excludedSubfolders);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(l10n.foldersExcludeSubfolder),
              content: SizedBox(
                width: 360,
                child: subDirs.isEmpty
                    ? Text(l10n.foldersExcludedCount(selectedExcluded.length))
                    : ListView(
                        shrinkWrap: true,
                        children: subDirs.map((path) {
                          final checked = selectedExcluded.contains(path);
                          return CheckboxListTile(
                            value: checked,
                            activeColor: tokens.accentPrimary,
                            title: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                NumeralFormatter.shortenPath(path),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onChanged: (v) {
                              setStateDialog(() {
                                if (v ?? false) {
                                  selectedExcluded.add(path);
                                } else {
                                  selectedExcluded.remove(path);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    await context
                        .read<MusicFoldersCubit>()
                        .setExcludedSubfolders(
                          folder.id,
                          selectedExcluded.toList(),
                        );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.actionApply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  folder.isAvailable
                      ? Icons.folder_rounded
                      : Icons.folder_off_rounded,
                  color: folder.isAvailable
                      ? tokens.accentPrimary
                      : tokens.danger,
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Text(
                    folder.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: l10n.actionRescan,
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      context.read<MusicFoldersCubit>().rescanFolder(folder.id),
                ),
                IconButton(
                  tooltip: l10n.actionRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    final cubit = context.read<MusicFoldersCubit>();
                    await cubit.removeFolder(folder.id);
                    if (context.mounted) {
                      WetarFeedback.showUndo(
                        context,
                        message: l10n.foldersRemovedUndo(folder.displayName),
                        undoLabel: l10n.actionUndo,
                        onUndo: () {
                          cubit.addFolderPath(
                            rootPath: folder.rootPath,
                            displayName: folder.displayName,
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                NumeralFormatter.shortenPath(folder.rootPath),
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!folder.isAvailable) ...<Widget>[
              SizedBox(height: tokens.spacingXs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacingSm,
                  vertical: tokens.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: tokens.danger.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                ),
                child: Text(
                  l10n.foldersUnavailableBadge,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: tokens.danger),
                ),
              ),
              SizedBox(height: tokens.spacingXs),
              Text(
                l10n.foldersUnavailableHint,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: tokens.danger),
              ),
            ],
            SizedBox(height: tokens.spacingSm),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: tokens.spacingSm,
                runSpacing: tokens.spacingXs,
                children: <Widget>[
                  Text(
                    NumeralFormatter.formatString(
                      l10n.foldersTrackCount(folder.trackCount),
                      numerals,
                    ),
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: tokens.accentSecondary),
                  ),
                  TextButton(
                    onPressed: () => _showExcludeDialog(context),
                    child: Text(
                      l10n.foldersExcludedCount(
                        folder.excludedSubfolders.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.foldersIncludeSubfolders),
              value: folder.includeSubfolders,
              activeTrackColor: tokens.accentPrimary,
              onChanged: (v) => context
                  .read<MusicFoldersCubit>()
                  .toggleIncludeSubfolders(folder.id, v),
            ),
          ],
        ),
      ),
    );
  }
}
