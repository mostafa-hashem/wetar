# Wetar (وتر) — Technical Architecture

## 1. Architectural Overview

Wetar follows a strict **feature-first Clean/BLoC architecture** separated into a platform-neutral core and thin native adapters:

```text
+-------------------------------------------------------------------+
| Presentation (lib/features/*/presentation/)                       |
| - Adaptive Phone/Desktop Screens (thin shells, GoRouter)          |
| - BLoCs / Cubits (PlayerBloc, LibraryBloc, MusicFoldersCubit,     |
|   PersonalizationCubit, EqualizerCubit, LyricsCubit, etc.)        |
| - WetarTokens (ThemeExtension) + AppLocalizations (en / ar)       |
+-------------------------------+-----------------------------------+
                                | Intents / Immutable Streams
+-------------------------------v-----------------------------------+
| Domain & Core (Platform-Neutral Pure Dart)                        |
| - WetarAudioHandler (single source of truth, audio_service)       |
| - Repositories over abstract LibrarySource / FolderPickerService  |
| - LrcParser, ArabicNormalizer, ReplayGainMath, ScanDiffEngine     |
| - AppearanceSettings + Schema Migration + Look Sanitizer          |
| - Drift SQLite Database (WetarDatabase)                           |
+-------------------------------+-----------------------------------+
                                | Abstract Interfaces
+-------------------------------v-----------------------------------+
| Platform Implementations (Kotlin / Swift / Isolate FS Scanner)    |
| - Android: WetarPlatformPlugin.kt (MediaStore, SAF, BassBoost,    |
|   Virtualizer, FileProvider Share, WidgetProvider, Permissions)   |
| - macOS: WetarMacPlugin.swift (NSOpenPanel, Bookmarks, FSEvents,  |
|   Window Mini-Player, DropView) + Isolate FileSystemLibrarySource |
| - iOS: WetarIosPlugin.swift (UIDocumentPicker, Bookmarks, iCloud  |
|   status/download, Share) + Isolate FileSystemLibrarySource       |
+-------------------------------------------------------------------+
```

---

## 2. Single Audio Source of Truth (`WetarAudioHandler`)

- Registered once in `main.dart` via `AudioService.init(...)` (non-blocking startup).
- Owns:
  - `just_audio.AudioPlayer` with `AudioPipeline(androidAudioEffects: [AndroidEqualizer, AndroidLoudnessEnhancer])`
  - `AudioSession` configuration (`music` profile, call interruption pause/resume, transient ducking, `becomingNoisy` pause on headphone unplug)
  - Gapless queue (`AudioSource` list / `ConcatenatingAudioSource`), Shuffle order, Loop modes (`off`, `all`, `one`)
  - Playback rate, pitch, Android skip silence, play/pause volume fade ramp (180ms), ReplayGain attenuation, A–B loop boundary monitor, and Sleep Timer (duration, end-of-track, N-tracks + fade-out)
  - Queue snapshot writer persisting `{trackStableKeys, currentIndex, positionMs, shuffle, repeatMode}` on pause, track change, and throttled every 10s while playing
  - Corrupt/missing file handler marking `Tracks.isCorruptOrMissing` and skipping to next valid item cleanly

---

## 3. Folder-Whitelist-Only Library Invariant & Drift Schema

Every library query enforces:
```sql
WHERE folder_id IN (SELECT id FROM selected_folders WHERE is_available = 1)
  AND duration_ms >= :minTrackDurationMs
```

### Drift Tables (`lib/core/database/wetar_database.dart`)

1. **`selected_folders`**:
   - `id` (PK), `rootPath` (unique text), `sourceKind` (`mediastore` | `saf` | `filesystem` | `bookmark`), `bookmarkData` (nullable base64), `displayName`, `volumeLabel`, `includeSubfolders` (bool), `excludedSubfoldersJson` (text), `isAvailable` (bool), `addedAt`, `lastScannedAt`.
2. **`tracks`**:
   - `id` (PK), `stableKey` (unique text — deterministic hash of canonical path/URI), `folderId` (FK -> `selected_folders.id` ON DELETE CASCADE), `uri` (text), `filePath` (text), `folderPath` (text, indexed), `title`, `titleNormalized`, `artist`, `artistNormalized`, `album`, `albumNormalized`, `albumArtist`, `genre`, `year`, `trackNumber`, `discNumber`, `durationMs`, `bitrateKbps`, `sampleRateHz`, `channels`, `sizeBytes`, `mimeType`, `dateModifiedSec`, `dateAddedSec`, `artworkUri`, `embeddedLyrics`, `replayGainTrackDb`, `replayGainAlbumDb`, `isCloudPending` (bool), `isCorruptOrMissing` (bool).
   - Indexes: `(folderId)`, `(albumNormalized)`, `(artistNormalized)`, `(titleNormalized)`, `(dateAddedSec)`.
3. **`album_palettes`**:
   - `albumKey` (PK), `primaryArgb`, `secondaryArgb`, `backgroundArgb`, `isDark`, `updatedAt`.
4. **`track_user_meta`** *(keyed by `stableKey`, NOT `tracks.id`, so hiding/deselecting folders preserves favorites & counts)*:
   - `stableKey` (PK), `isFavorite` (bool), `playCount` (int), `lastPlayedAt` (nullable int), `rememberedPositionMs` (nullable int), `attachedLrcPath` (nullable text), `lyricOffsetMs` (int, default 0), `customArtPath` (nullable text).
5. **`playlists`**:
   - `id` (PK), `name`, `smartKind` (nullable: `most_played` | `recently_added` | `never_played` | `long_tracks`), `customCoverPath` (nullable), `createdAt`, `updatedAt`.
6. **`playlist_entries`**:
   - `id` (PK), `playlistId` (FK CASCADE), `trackStableKey` (text, indexed), `position` (int), `addedAt`.
   - *Display queries INNER JOIN `tracks` on `trackStableKey` so entries outside selected folders stay hidden in UI without losing user ordering.*
7. **`play_history_events`**:
   - `id` (PK), `trackStableKey` (text, indexed), `artistName`, `albumName`, `playedAt` (indexed), `listenedMs`.
8. **`queue_snapshots`**:
   - `id` (PK = 1 singleton), `itemsJson`, `currentIndex`, `positionMs`, `shuffleEnabled`, `repeatMode`, `updatedAt`.
9. **`equalizer_presets`**:
   - `id` (PK), `name`, `isCustom` (bool), `bandGainsJson`, `bassBoostStrength`, `virtualizerStrength`, `loudnessGainMb`, `updatedAt`.
10. **`recent_searches`**:
    - `query` (PK), `normalizedQuery`, `searchedAt`.

---

## 4. Zero-Network Release Enforcement

| Platform | Mechanism | Verification Command |
| --- | --- | --- |
| **Android** | Remove `INTERNET` from `src/main/AndroidManifest.xml`; keep in `debug`/`profile` only; `src/release/AndroidManifest.xml` uses `tools:node="remove"` for `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`. | `aapt2 dump permissions app-arm64-v8a-release.apk` (must list zero network permissions) |
| **macOS** | `Release.entitlements` enables `app-sandbox`, `files.user-selected.read-write`, `files.bookmarks.app-scope`; omits `network.client` and `network.server`. | `codesign -d --entitlements :- Wetar.app` |
| **iOS** | `Info.plist` has zero `NSAppTransportSecurity` exceptions; `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking = false` and zero collected data. | Inspect built `Runner.app/Info.plist` & `PrivacyInfo.xcprivacy` |

---

## 5. Isolate & Background Threading Boundaries

- **Cold Start (<1s):** Main isolate reads `SharedPreferencesWithCache` synchronously after initialization, paints UI with cached `AppearanceSettings` and cached Drift SQL queries, and restores the audio queue asynchronously. Never waits for folder rescanning at startup.
- **Metadata & File Scanning:** `FileSystemLibrarySource` (iOS/macOS) walks files and calls `audio_metadata_reader` inside `Isolate.run` chunks; Android runs MediaStore cursor projections on a Kotlin background executor (`Dispatchers.IO`).
- **Artwork Color Extraction:** Downscaled `64x64` PNG/JPEG bytes are quantized in `Isolate.run` using `material_color_utilities` (`QuantizerCelebi` + `Score.score`).
- **Custom Fonts & Images:** Imported `.ttf`/`.otf` header verification and custom background/cover resizing (`<= 1080px`) run in background isolates before touching `FontLoader` or `app-support` storage.
- **Diagnostics Log:** `AppLogger` captures `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `runZonedGuarded`, appending rotating lines (`<= 1 MB`) to `<appSupport>/wetar_diagnostics.log`.
