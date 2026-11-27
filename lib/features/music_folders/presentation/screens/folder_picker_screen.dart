import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wetar/core/capabilities/platform_capabilities.dart';
import 'package:wetar/core/di/service_locator.dart';
import 'package:wetar/core/platform/platform_interfaces.dart';
import 'package:wetar/core/utils/numeral_formatter.dart';
import 'package:wetar/core/widgets/wetar_feedback.dart';
import 'package:wetar/features/music_folders/presentation/bloc/music_folders_cubit.dart';
import 'package:wetar/features/personalization/presentation/theme/wetar_tokens.dart';
import 'package:wetar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:wetar/l10n/app_localizations.dart';

/// In-app audio folder picker grouped by volume with live track totals,
/// search filter, select all/clear, and manual SAF picker entry point.
class FolderPickerScreen extends StatefulWidget {
  const FolderPickerScreen({super.key});

  @override
  State<FolderPickerScreen> createState() => _FolderPickerScreenState();
}

class _FolderPickerScreenState extends State<FolderPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _checkedPaths = <String>{};
  bool _initialized = false;
  bool _applying = false;
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MusicFoldersCubit>();
    if (cubit.state.discoveredFolders.isEmpty) {
      cubit.refreshDiscoveredFolders();
    }
    _seedChecked(cubit.state);
  }

  void _seedChecked(MusicFoldersState state) {
    if (_initialized) return;
    _checkedPaths.addAll(state.selectedFolders.map((f) => f.rootPath));
    _initialized = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _apply(List<DiscoveredAudioFolder> allDiscovered) async {
    if (_applying) return;
    setState(() => _applying = true);
    try {
      final chosen = allDiscovered
          .where((f) => _checkedPaths.contains(f.rootPath))
          .toList();
      await context.read<MusicFoldersCubit>().applyInAppSelection(chosen);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.wetarTokens;
    final caps = sl<PlatformCapabilities>();
    final numerals = context.select((SettingsCubit c) => c.state.numeralStyle);

    return BlocConsumer<MusicFoldersCubit, MusicFoldersState>(
      listener: (context, state) {
        if (!_initialized && state.selectedFolders.isNotEmpty) {
          _seedChecked(state);
        }
      },
      builder: (context, state) {
        final filtered = state.discoveredFolders.where((f) {
          if (_filterQuery.isEmpty) return true;
          final q = _filterQuery.toLowerCase();
          return f.displayName.toLowerCase().contains(q) ||
              f.rootPath.toLowerCase().contains(q);
        }).toList();

        final grouped = <String, List<DiscoveredAudioFolder>>{};
        for (final f in filtered) {
          grouped
              .putIfAbsent(f.volumeLabel, () => <DiscoveredAudioFolder>[])
              .add(f);
        }

        final selectedTracksCount = state.discoveredFolders
            .where((f) => _checkedPaths.contains(f.rootPath))
            .fold<int>(0, (sum, f) => sum + f.trackCount);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.foldersPickerTitle),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_checkedPaths.length ==
                        state.discoveredFolders.length) {
                      _checkedPaths.clear();
                    } else {
                      _checkedPaths.addAll(
                        state.discoveredFolders.map((e) => e.rootPath),
                      );
                    }
                  });
                },
                child: Text(
                  _checkedPaths.length == state.discoveredFolders.length &&
                          state.discoveredFolders.isNotEmpty
                      ? l10n.actionClear
                      : l10n.actionSelectAll,
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _filterQuery = v.trim()),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: l10n.foldersSearchHint,
                          filled: true,
                          fillColor: tokens.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              tokens.radiusCard,
                            ),
                            borderSide: BorderSide(color: tokens.borderSubtle),
                          ),
                        ),
                      ),
                      if (caps.supportsSafFolderPicker) ...<Widget>[
                        SizedBox(height: tokens.spacingSm),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () async {
                              final added = await context
                                  .read<MusicFoldersCubit>()
                                  .pickSystemFolder();
                              if (added != null && context.mounted) {
                                WetarFeedback.showSuccess(
                                  context,
                                  l10n.foldersAddedSuccess(added.displayName),
                                );
                              }
                            },
                            icon: const Icon(Icons.create_new_folder_outlined),
                            label: Text(l10n.foldersAddManualSaf),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoadingDiscovery
                      ? const Center(child: CircularProgressIndicator())
                      : !state.permissions.audioGranted
                      ? Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(tokens.spacingLg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  l10n.permissionDeniedTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: tokens.spacingSm),
                                Text(
                                  l10n.permissionDeniedBody,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: tokens.spacingMd),
                                FilledButton(
                                  onPressed: () => context
                                      .read<MusicFoldersCubit>()
                                      .requestPermissions(),
                                  child: Text(l10n.onboardingGrantPermission),
                                ),
                              ],
                            ),
                          ),
                        )
                      : grouped.isEmpty
                      ? Center(child: Text(l10n.libraryFilteredEmpty))
                      : ListView(
                          children: <Widget>[
                            for (final entry in grouped.entries) ...<Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: tokens.spacingMd,
                                  vertical: tokens.spacingSm,
                                ),
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: tokens.accentPrimary),
                                ),
                              ),
                              for (final folder in entry.value)
                                CheckboxListTile(
                                  value: _checkedPaths.contains(
                                    folder.rootPath,
                                  ),
                                  activeColor: tokens.accentPrimary,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked ?? false) {
                                        _checkedPaths.add(folder.rootPath);
                                      } else {
                                        _checkedPaths.remove(folder.rootPath);
                                      }
                                    });
                                  },
                                  title: Text(
                                    folder.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(
                                          NumeralFormatter.shortenPath(
                                            folder.rootPath,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                      Text(
                                        l10n.foldersTrackCount(
                                          folder.trackCount,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: tokens.accentSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                ),
                Container(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    border: Border(top: BorderSide(color: tokens.borderSubtle)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          NumeralFormatter.formatString(
                            l10n.foldersSelectedSummary(
                              _checkedPaths.length,
                              selectedTracksCount,
                            ),
                            numerals,
                          ),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.accentPrimary,
                          disabledBackgroundColor: tokens.accentPrimary,
                          foregroundColor:
                              tokens.isDark &&
                                  tokens.accentPrimary.computeLuminance() > 0.45
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: _applying
                            ? null
                            : () => _apply(state.discoveredFolders),
                        child: _applying
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      tokens.accentPrimary.computeLuminance() >
                                          0.45
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              )
                            : Text(l10n.actionApply),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
