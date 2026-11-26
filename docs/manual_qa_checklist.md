# Wetar (وتر) — Manual Device QA Checklist

Run on physical Android (including a low-end/OEM device such as Xiaomi/Samsung), macOS, and iOS devices prior to release.

## 1. Strict Folder-Whitelist Isolation
- [ ] On fresh install, skip onboarding -> Library & Home show friendly empty state; 0 audio files appear anywhere on the app.
- [ ] Open Folder Picker -> verify folders grouped by volume, shortened LTR paths inside Arabic RTL, search filter, Select All / Clear, and live track totals.
- [ ] Select one folder with nested subfolders -> verify only tracks inside that folder appear in Songs, Albums, Artists, Genres, Search, Stats, Queue, and Widget.
- [ ] Exclude a subfolder -> verify tracks in that subfolder disappear immediately without rescanning unrelated folders.
- [ ] Rename or remove SD card / USB folder -> folder card marks `Unavailable` while retaining selection & playlists; reconnect storage -> folder recovers automatically and tracks/playlists reappear.
- [ ] Open an audio file from Android Files / macOS Finder / iOS Files (`Open With`) -> plays temporarily without appearing in the Library; dismissible "Add folder" banner works.

## 2. Background Playback, Interruptions & Process Death
- [ ] Play track -> lock screen -> confirm notification / Control Center / macOS Now Playing controls work and CPU/battery stay idle (zero UI ticker updates).
- [ ] Trigger incoming phone call -> playback pauses cleanly and resumes after call ends.
- [ ] Play navigation prompt / transient notification -> playback ducks briefly and restores full volume.
- [ ] Unplug wired headphones or disconnect Bluetooth earbuds -> playback pauses immediately (`becomingNoisy`).
- [ ] Kill app process from recents while paused -> reopen -> verify queue, active index, shuffle/repeat, and exact millisecond position restore smoothly.
- [ ] Corrupt / 0-byte audio file in queue -> non-blocking error toast shown, track flagged, playback skips cleanly to next track.

## 3. Personalization, Localization, RTL & Accessibility
- [ ] Toggle Arabic (RTL) <-> English (LTR) live -> zero restart, Play/Pause never mirrored, file paths remain LTR, Arabic-Indic numerals switch cleanly.
- [ ] Test all 5 Now Playing layouts (`oudStrings`, `classicCard`, `immersiveBleed`, `minimal`, `vinylDisc`) and all 9 background modes in Light, Dark, and AMOLED.
- [ ] Import a `.ttf`/`.otf` font and export/import a `.wetarlook` file (plus verify malformed `.wetarlook` files fail cleanly).
- [ ] Enable Lite Mode & system Reduce Motion -> blur/animated tickers stop; scrolling 20,000 tracks stays smooth.
- [ ] Increase OS font scaling to `200%` and enable TalkBack/VoiceOver -> zero text overflow, 48dp+ touch targets everywhere.

## 4. Platform-Specific Checks
- [ ] **Android:** Home screen widget updates on play/pause/skip; launcher shortcuts (`Shuffle All`, `Favorites`, `Car Mode`) open directly; release APK passes `aapt2 dump permissions` with zero `INTERNET` permission.
- [ ] **macOS:** Resize window down to `840x560`; toggle Compact Mini-Player window; drop folders/files from Finder; test `Space`/Arrow/`Cmd+F` shortcuts; verify `Release.entitlements` has zero network keys.
- [ ] **iOS:** Select folder via `UIDocumentPicker`; test playback across relaunches (security-scoped bookmark resolution); test undownloaded iCloud Drive `.mp3` shows cloud badge and triggers download without freezing.
