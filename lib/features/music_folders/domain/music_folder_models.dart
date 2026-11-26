import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Represents a user-selected music folder persisted in Drift.
class SelectedFolderEntity extends Equatable {
  const SelectedFolderEntity({
    required this.id,
    required this.rootPath,
    required this.sourceKind,
    required this.displayName,
    required this.volumeLabel,
    required this.includeSubfolders,
    required this.excludedSubfolders,
    required this.isAvailable,
    required this.addedAt,
    required this.lastScannedAt,
    this.bookmarkData,
    this.trackCount = 0,
  });

  final int id;
  final String rootPath;
  final String sourceKind;
  final String? bookmarkData;
  final String displayName;
  final String volumeLabel;
  final bool includeSubfolders;
  final List<String> excludedSubfolders;
  final bool isAvailable;
  final int addedAt;
  final int lastScannedAt;
  final int trackCount;

  static List<String> decodeExcluded(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
      return const <String>[];
    } catch (_) {
      return const <String>[];
    }
  }

  static String encodeExcluded(List<String> items) => jsonEncode(items);

  @override
  List<Object?> get props => [
    id,
    rootPath,
    sourceKind,
    bookmarkData,
    displayName,
    volumeLabel,
    includeSubfolders,
    excludedSubfolders,
    isAvailable,
    addedAt,
    lastScannedAt,
    trackCount,
  ];
}

/// Incremental scan progress snapshot for UI indicators and cancellation.
class ScanProgress extends Equatable {
  const ScanProgress({
    required this.isScanning,
    this.currentFolderName = '',
    this.processedCount = 0,
    this.totalCount = 0,
  });

  const ScanProgress.idle()
    : isScanning = false,
      currentFolderName = '',
      processedCount = 0,
      totalCount = 0;

  final bool isScanning;
  final String currentFolderName;
  final int processedCount;
  final int totalCount;

  double? get fraction =>
      totalCount > 0 ? (processedCount / totalCount).clamp(0.0, 1.0) : null;

  @override
  List<Object?> get props => [
    isScanning,
    currentFolderName,
    processedCount,
    totalCount,
  ];
}
