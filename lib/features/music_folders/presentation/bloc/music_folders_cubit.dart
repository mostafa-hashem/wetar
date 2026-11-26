import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/capabilities/platform_capabilities.dart';
import '../../../../core/platform/platform_interfaces.dart';
import '../../data/music_folders_repository.dart';
import '../../domain/music_folder_models.dart';

class MusicFoldersState extends Equatable {
  const MusicFoldersState({
    this.selectedFolders = const <SelectedFolderEntity>[],
    this.discoveredFolders = const <DiscoveredAudioFolder>[],
    this.permissions = const WetarPermissionsStatus(
      audioGranted: false,
      notificationsGranted: true,
    ),
    this.scanProgress = const ScanProgress.idle(),
    this.isLoadingDiscovery = false,
    this.errorMessage,
  });

  final List<SelectedFolderEntity> selectedFolders;
  final List<DiscoveredAudioFolder> discoveredFolders;
  final WetarPermissionsStatus permissions;
  final ScanProgress scanProgress;
  final bool isLoadingDiscovery;
  final String? errorMessage;

  int get totalLibraryTracks => selectedFolders.fold(
    0,
    (sum, f) => sum + (f.isAvailable ? f.trackCount : 0),
  );

  MusicFoldersState copyWith({
    List<SelectedFolderEntity>? selectedFolders,
    List<DiscoveredAudioFolder>? discoveredFolders,
    WetarPermissionsStatus? permissions,
    ScanProgress? scanProgress,
    bool? isLoadingDiscovery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MusicFoldersState(
      selectedFolders: selectedFolders ?? this.selectedFolders,
      discoveredFolders: discoveredFolders ?? this.discoveredFolders,
      permissions: permissions ?? this.permissions,
      scanProgress: scanProgress ?? this.scanProgress,
      isLoadingDiscovery: isLoadingDiscovery ?? this.isLoadingDiscovery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedFolders,
    discoveredFolders,
    permissions,
    scanProgress,
    isLoadingDiscovery,
    errorMessage,
  ];
}

/// Manages selected music folders, permissions, discovery, and incremental scanning.
class MusicFoldersCubit extends Cubit<MusicFoldersState> {
  MusicFoldersCubit(this._repo, this._systemService, this._capabilities)
    : super(const MusicFoldersState()) {
    _foldersSub = _repo.watchSelectedFolders().listen((folders) {
      emit(state.copyWith(selectedFolders: folders));
    });
    _scanSub = _repo.scanProgressStream.listen((progress) {
      emit(state.copyWith(scanProgress: progress));
    });
  }

  final MusicFoldersRepository _repo;
  final SystemIntegrationService _systemService;
  final PlatformCapabilities _capabilities;

  StreamSubscription<List<SelectedFolderEntity>>? _foldersSub;
  StreamSubscription<ScanProgress>? _scanSub;

  Future<void> initAndReconcile() async {
    final perms = await _systemService.checkPermissions();
    emit(state.copyWith(permissions: perms));
    if (perms.audioGranted) {
      await _repo.reconcileAllSelectedFolders();
    }
  }

  Future<WetarPermissionsStatus> requestPermissions({
    bool includeNotifications = true,
  }) async {
    final perms = await _systemService.requestPermissions(
      includeNotifications: includeNotifications,
    );
    emit(state.copyWith(permissions: perms));
    if (perms.audioGranted && _capabilities.supportsInAppFolderPicker) {
      await refreshDiscoveredFolders();
    }
    return perms;
  }

  Future<void> openAppPermissionSettings() => _systemService.openAppSettings();

  Future<void> refreshDiscoveredFolders() async {
    if (!_capabilities.supportsInAppFolderPicker) return;
    emit(state.copyWith(isLoadingDiscovery: true, clearError: true));
    try {
      final list = await _repo.discoverDeviceAudioFolders();
      emit(state.copyWith(discoveredFolders: list, isLoadingDiscovery: false));
    } catch (e) {
      emit(
        state.copyWith(isLoadingDiscovery: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> applyInAppSelection(List<DiscoveredAudioFolder> chosen) async {
    await _repo.applyFolderSelection(chosen);
  }

  Future<void> selectAllDiscoveredMusicFolders() async {
    if (state.discoveredFolders.isEmpty) {
      await refreshDiscoveredFolders();
    }
    await _repo.applyFolderSelection(state.discoveredFolders);
  }

  Future<SelectedFolderEntity?> pickSystemFolder() async {
    return _repo.addSystemPickedFolder();
  }

  Future<void> addFolderPath({
    required String rootPath,
    required String displayName,
  }) async {
    await _repo.addOrReactivateFolder(
      rootPath: rootPath,
      displayName: displayName,
    );
  }

  Future<void> removeFolder(int folderId) => _repo.removeFolder(folderId);

  Future<void> toggleIncludeSubfolders(int folderId, bool include) =>
      _repo.setIncludeSubfolders(folderId, include);

  Future<void> setExcludedSubfolders(int folderId, List<String> paths) =>
      _repo.setExcludedSubfolders(folderId, paths);

  Future<void> rescanFolder(int folderId) =>
      _repo.scanFoldersByIds(<int>[folderId]);

  Future<void> rescanAll() => _repo.reconcileAllSelectedFolders();

  void cancelScan() => _repo.cancelCurrentScan();

  @override
  Future<void> close() async {
    await _foldersSub?.cancel();
    await _scanSub?.cancel();
    return super.close();
  }
}
