import '../../../core/platform/platform_interfaces.dart';

/// Pure-Dart diff calculator comparing existing Drift rows for the scanned
/// folders against freshly scanned folder metadata.
class ExistingTrackSignature {
  const ExistingTrackSignature({
    required this.stableKey,
    required this.folderId,
    required this.dateModifiedSec,
    required this.sizeBytes,
  });

  final String stableKey;
  final int folderId;
  final int dateModifiedSec;
  final int sizeBytes;
}

class ScanDiffPlan {
  const ScanDiffPlan({
    required this.tracksToUpsert,
    required this.staleStableKeysToDelete,
  });

  final List<ScannedTrackDto> tracksToUpsert;
  final List<String> staleStableKeysToDelete;
}

class ScanDiffEngine {
  ScanDiffEngine._();

  static ScanDiffPlan compute({
    required Set<int> scannedFolderIds,
    required List<ExistingTrackSignature> existing,
    required FolderScanResult scannedResult,
  }) {
    final existingMap = <String, ExistingTrackSignature>{
      for (final item in existing)
        if (scannedFolderIds.contains(item.folderId)) item.stableKey: item,
    };

    final toUpsert = <ScannedTrackDto>[];
    for (final dto in scannedResult.changedTracks) {
      final prev = existingMap[dto.stableKey];
      if (prev == null ||
          prev.folderId != dto.folderId ||
          prev.dateModifiedSec != dto.dateModifiedSec ||
          prev.sizeBytes != dto.sizeBytes) {
        toUpsert.add(dto);
      }
    }

    final toDelete = <String>[];
    for (final entry in existingMap.entries) {
      if (!scannedResult.activeStableKeys.contains(entry.key)) {
        toDelete.add(entry.key);
      }
    }

    return ScanDiffPlan(
      tracksToUpsert: toUpsert,
      staleStableKeysToDelete: toDelete,
    );
  }
}
