# Wetar (وتر) — Cross-Platform Capability Matrix

Every platform-dependent feature flows through `PlatformCapabilities`. Unsupported features are **hidden cleanly** in the UI — never crashed, never mocked with fake controls.

| Feature / Capability | Android (`minSdk 24`, `targetSdk 36`) | macOS (`10.15+` / `13.0+`) | iOS (`15.0+`) | Notes & Graceful Handling |
| --- | --- | --- | --- | --- |
| **Offline Playback & Gapless Queue** | Supported (`just_audio` + Media3) | Supported (`just_audio` + `AVQueuePlayer`) | Supported (`just_audio` + `AVQueuePlayer`) | Single `WetarAudioHandler` owns queue & state restoration everywhere. |
| **Background Audio & System Media Controls** | Supported (`mediaPlayback` foreground service + notification) | Supported (Now Playing + hardware media keys) | Supported (`UIBackgroundModes: audio` + Lock Screen / Control Center) | Survives UI destruction & backgrounding across all 3 platforms. |
| **Audio Interruptions & Headphone Unplug** | Supported (`audio_session` + `becomingNoisy`) | Supported (`audio_session` route/device changes) | Supported (`AVAudioSession` interruptions & route changes) | Auto-pauses on call/unplug; optional auto-play on BT connect (default off). |
| **User-Selected Music Folders** | Supported (In-App MediaStore Folder Picker + optional SAF tree URI) | Supported (`NSOpenPanel` + App-Scope Security Bookmarks) | Supported (`UIDocumentPicker` + Security Bookmarks + App `Documents/`) | Core whitelist invariant enforced identically via Drift `SelectedFolders`. |
| **Live Folder File Watching** | Supported (Incremental scan + MediaStore observer) | Supported (`FSEventStreamCreate` watcher) | Supported (Foreground reconcile + iCloud status check) | macOS watches Finder edits live; iOS surfaces undownloaded iCloud files clearly. |
| **Playback Speed (`0.5x–2.5x`)** | Supported | Supported | Supported | Exposed everywhere. |
| **Pitch Control (`0.5x–2.0x`)** | Supported (`ExoPlayer`) | Hidden (unsupported in `just_audio` Darwin) | Hidden (unsupported in `just_audio` Darwin) | Gated via `supportsPitchControl`. |
| **Skip Silence** | Supported (`ExoPlayer`) | Hidden | Hidden | Gated via `supportsSkipSilence`. |
| **Multi-Band Equalizer & Loudness Boost** | Supported (`AndroidEqualizer` + `AndroidLoudnessEnhancer`) | Hidden (planned Phase 6+ `MTAudioProcessingTap` + `AVAudioUnitEQ` doc) | Hidden (planned `MTAudioProcessingTap` + `AVAudioUnitEQ` doc) | Gated via `supportsNativeEqualizer` and `supportsLoudnessEnhancer`. |
| **Bass Boost & Virtualizer** | Supported (Android `android.media.audiofx.BassBoost` / `Virtualizer`) | Hidden | Hidden | Gated via `supportsBassBoost` / `supportsVirtualizer`. |
| **ReplayGain Normalization** | Supported (Pure-Dart tag parse + player volume scaling) | Supported | Supported | Works identically on all platforms! |
| **Sleep Timer & A–B Loop** | Supported (Pure-Dart timer/position observer in `WetarAudioHandler`) | Supported | Supported | Works identically on all platforms! |
| **Synced `.lrc` & Embedded Lyrics** | Supported (`audio_metadata_reader` + `.lrc` parser + SAF/doc picker) | Supported (`NSOpenPanel`) | Supported (`UIDocumentPicker`) | Automatic Arabic RTL / English LTR per-line alignment everywhere. |
| **Personalization Engine, Fonts, Backgrounds & `.wetarlook`** | Supported | Supported | Supported | Identical live `WetarTokens` engine across all 3 platforms. |
| **System Dynamic Color** | Supported (Android 12+ Material You) | Supported (macOS Accent Color) | Hidden (fallback to artwork/custom accent) | Gated via `supportsSystemDynamicColor`. |
| **Home Screen Widget & Launcher Shortcuts** | Supported (`WetarMusicWidgetProvider` + `shortcuts.xml`) | Hidden (Menu Bar covers quick actions) | Hidden (WidgetKit planned later) | Gated via `supportsHomeWidgets`. |
| **Desktop Shell, Shortcuts, Menu Bar, Drag-and-Drop, Compact Mini Window** | Hidden (Tablet wide layout adapts without macOS-specific menu bar) | Supported | Hidden (iPad adaptive split layout if needed) | Gated via `supportsDesktopShell`. |
| **OEM Battery Optimization Guide** | Supported (Android OEM settings intent) | Hidden | Hidden | Gated via `supportsBatteryOptimizationGuide`. |
