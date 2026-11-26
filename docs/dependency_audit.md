# Wetar (وتر) — Dependency Audit & Justification

Every runtime and build dependency in `pubspec.yaml` is audited below against Wetar's size (`<= 15 MB` per Android ABI), offline privacy, cross-platform support (Android, iOS, macOS), and maintenance requirements.

| Package | Version Pin | License | Platforms | Maintenance | Size Impact | One-Line Justification & Rejected Alternative |
| --- | --- | --- | --- | --- | --- | --- |
| `flutter_localizations` + `intl` | SDK | BSD-3 | Android, iOS, macOS | Official Flutter SDK | Minimal (ARB tables only) | Standard `gen-l10n` Arabic/English plural & bidi support; rejected manual Map l10n which lacks ICU plural/RTL tooling. |
| `flutter_bloc` + `bloc` | `^9.1.1` | MIT | All | Active (Felix Angelov) | ~45 KB Dart | Enforces rule-mandated BLoC/Cubit separation and `BlocSelector` rebuild scoping; rejected Riverpod/Provider per spec. |
| `equatable` | `^2.0.7`+ | MIT | All | Active | ~12 KB Dart | Concise immutable state equality without `freezed`/`json_serializable` codegen bloat. |
| `get_it` | `^9.3.0` | MIT | All | Active | ~18 KB Dart | Lightweight zero-codegen service locator for singletons (`WetarAudioHandler`, `WetarDatabase`); rejected `injectable`. |
| `go_router` | `^18.1.3` | BSD-3 | All | Official Flutter team | ~60 KB Dart | Declarative deep-linking (Open-With, shortcuts) & adaptive mobile/desktop `StatefulShellRoute`; rejected manual Navigator 2.0. |
| `just_audio` | `^0.10.5` | MIT | Android, iOS, macOS | Active (ryanheise) | ~1.8 MB native (Media3 on Android; AVQueuePlayer on Apple) | Gapless playback, speed, pitch, Android skip-silence, `AndroidEqualizer` & `AndroidLoudnessEnhancer`; rejected `audioplayers` (lacks gapless & native EQ pipeline). |
| `audio_service` | `^0.18.19` | MIT | Android, iOS, macOS | Active (ryanheise) | ~120 KB | Required background foreground-service `AudioHandler`, Android notification controls, and Apple `MPNowPlayingInfoCenter`; rejected custom MediaSession plugin. |
| `audio_session` | `^0.2.4` | MIT | Android, iOS, macOS | Active (ryanheise) | ~40 KB | Reliable call interruptions, transient ducking, Bluetooth/headset route change events across all 3 OSes. |
| `drift` + `drift_flutter` | `^2.35.4` / `^0.3.1` | MIT | Android, iOS, macOS | Active (simolus3) | ~1.6 MB native SQLite arm64 (via `sqlite3` 3.x native assets) | Typed indexed SQLite queries, migrations, and reactive streams for 20k+ tracks & hidden out-of-scope joins; rejected `hive`/`isar` & EOL `sqlite3_flutter_libs`. |
| `shared_preferences` | `^2.5.3` | BSD-3 | All | Official Flutter team | ~25 KB | `SharedPreferencesWithCache` for instant synchronous cold-start load of versioned `AppearanceSettings` JSON; rejected heavy key-value DBs. |
| `path_provider` + `path` | `^2.1.5` / `^1.9.1` | BSD-3 | All | Official Flutter team | ~20 KB | Cross-platform app-private cache/support directory resolution & safe POSIX/URI path math. |
| `audio_metadata_reader` | `^1.8.1` | MIT | Pure Dart (All) | Active | ~80 KB Dart | Pure-Dart isolate tag, embedded lyrics, ReplayGain, and cover art extraction (MP3/FLAC/M4A/OGG/WAV) for macOS/iOS & Android enrichment; rejected C++/TagLib FFI bloat. |
| `material_color_utilities` | SDK-compat | Apache-2.0 | Pure Dart (All) | Official Material team | ~55 KB Dart | Exact HCT quantization & contrast-safe palette extraction from album thumbnails in background isolates. |
| `dynamic_color` | `^2.1.0` | Apache-2.0 | Android 12+, macOS | Official Material team | ~25 KB | Optional OS wallpaper/accent dynamic color integration requested in 4B; small native footprint. |
| `rxdart` | `^0.28.0` | Apache-2.0 | Pure Dart (All) | Active | ~0 KB extra (already transitive via `just_audio`/`audio_service`) | Reuses already-bundled `BehaviorSubject`/`PublishSubject` in `WetarAudioHandler`; zero incremental binary impact. |

## Explicitly Rejected Heavy / Unmaintained Packages (Replaced by Lean Native Channels)

| Rejected Package | Reason Rejected | Wetar Replacement |
| --- | --- | --- |
| `on_audio_query` (`2.9.0`) | Unmaintained since mid-2023, broken AGP namespaces, pulls full-device query assumptions incompatible with folder-only invariant | ~150-line Kotlin MediaStore folder aggregator & folder-scoped scanner in `WetarPlatformPlugin.kt` |
| `permission_handler` | Unnecessary multi-permission manifest/binary bloat for only 2 audio/notification permissions | ~45 lines of Kotlin `ActivityCompat` permission checks in `MainActivity.kt` |
| `file_picker` & `share_plus` | Multiple transitive plugins across 3 OSes; lacks security-scoped folder bookmark return & iCloud status APIs | ~120 lines per platform in `WetarPlatformPlugin.kt`, `WetarMacPlugin.swift`, `WetarIosPlugin.swift` |
| `home_widget` | Adds Kotlin/Swift boilerplate wrapper around standard `AppWidgetProvider` | Direct `WetarMusicWidgetProvider.kt` bound straight to `WetarAudioHandler` |
| `google_fonts` | Uses runtime HTTP font fetching (violates strict offline rule) | 5 subset-friendly local OFL fonts (`1.39 MB`) + runtime `FontLoader` for local user `.ttf`/`.otf` |
| `flutter_screenutil` | Prohibited by rule; causes fixed-pixel layout regressions & font scaling overflow | Responsive `LayoutBuilder` constraints + `WetarTokens` + `MediaQuery` textScaler |
| `bloc_test` / `drift_dev` / `build_runner` | Dev-only | Dev-only | Zero release APK/app binary impact; testing & compile-time SQL generation only |
