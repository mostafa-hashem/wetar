# Wetar (وتر) — Design Specification

## 1. Product Concept & Visual Soul
Wetar (*وتر*, an Oud string) is an offline, lightweight, deeply customizable local music player across Android, iOS, and macOS. Rather than borrowing generic streaming-app templates or material boilerplate, Wetar draws its motif from acoustic string tension and warm wood resonance:
- **Resonant Hairlines:** Subtle hairline dividers and string wave paths that respond softly while audio plays (and sit completely still when paused, backgrounded, or in Lite Mode).
- **Layered Artwork Depth:** Album art sits inside `WetarArtworkFrame` with ambient palette bleed and soft elevation rather than flat square thumbnails.
- **Tactile & Effortless:** Common actions sit in the phone thumb zone (1–2 taps), while personalization options resolve through a single live `WetarTokens` extension with instant preview.

---

## 2. Design Tokens (`WetarTokens`)

Every color, typography metric, spacing unit, corner radius, shadow, glass blur, and motion duration is computed inside `WetarTokenResolver` from `AppearanceSettings` + optional artwork HCT palette (`material_color_utilities`) and attached to `ThemeData.extensions`. Feature widgets read `context.wetarTokens` exclusively.

### 2.1 Default Theme Palettes

| Token | Warm Parchment (Light) | Oud Nocturne (Dark Default) | Pure Resonance (AMOLED) |
| --- | --- | --- | --- |
| `canvas` | `#F7F3EC` | `#120F0D` | `#000000` |
| `surface` | `#FFFDF9` | `#1C1714` | `#0D0B0A` |
| `surfaceElevated` | `#F1E9DC` | `#261F1B` | `#161210` |
| `accentPrimary` | `#B45309` | `#E69B3A` | `#F0A94D` |
| `accentSecondary` | `#0F766E` | `#38B2AC` | `#4FD1C5` |
| `inkPrimary` | `#1F1915` | `#F6EFE6` | `#FAF5EE` |
| `inkMuted` | `#6B5E53` | `#A69788` | `#9E9082` |
| `borderSubtle` | `#E2D6C4` | `#322923` | `#241E1A` |
| `danger` | `#C2410C` | `#F87171` | `#FB7185` |
| `success` | `#15803D` | `#4ADE80` | `#4ADE80` |

### 2.2 Spacing, Density & Radii Tokens

| Token | Compact | Comfortable (Default) | Spacious |
| --- | --- | --- | --- |
| `listRowExtent` | `58.0` dp | `68.0` dp | `78.0` dp |
| `spacingXs / Sm / Md / Lg / Xl` | `4 / 8 / 12 / 16 / 24` | `4 / 8 / 16 / 24 / 32` | `6 / 12 / 18 / 28 / 36` |
| `radiusCard` (at 1.0x scale) | `12.0` dp | `16.0` dp | `20.0` dp |
| `radiusSheet` | `20.0` dp | `24.0` dp | `28.0` dp |
| `radiusPill` | `999.0` dp | `999.0` dp | `999.0` dp |

*(Fixed `itemExtent` per density guarantees O(1) sliver scroll offset calculation across 20,000+ tracks at 60/120fps.)*

---

## 3. Typography & Font Budget

- **Bundled Arabic Fonts (OFL):**
  - `Cairo` (Regular, SemiBold, Bold — 276 KB) — default Arabic
  - `Almarai` (Regular, Bold — 294 KB)
  - `Alexandria` (Regular, Medium, Bold — 505 KB)
- **Bundled Latin Fonts (OFL):**
  - `PlusJakartaSans` (Variable 200–800 — 172 KB) — default Latin
  - `Jost` (Regular, Medium, Bold — 180 KB)
- **Total Asset Footprint:** `1,427 KB` (`1.39 MB`, strictly within `<= 1.5 MB`).
- **Additional Options:** System font + user-imported `.ttf`/`.otf` validated in an isolate and registered dynamically via `FontLoader`.
- **Scale & Fallbacks:** User font scale `0.85x–1.35x` composes cleanly with `MediaQuery.textScalerOf(context)` up to 200% accessibility scaling. Automatic `fontFamilyFallback` binds the active Arabic & Latin pair so bilingual titles never fall back to mismatched glyphs.

---

## 4. Motion & Haptics Principles

- **Curves:** `easeOutQuart` (`Cubic(0.22, 1.0, 0.36, 1.0)`) for sheet/player expansion; `easeInOutCubic` for palette transitions (300ms).
- **Motion Intensity (`MotionIntensity`):**
  - `off` / `systemReduceMotion` / `liteMode`: `Duration.zero`, zero decorative animation tickers, static artwork gradients.
  - `reduced`: `120ms` micro-transitions only.
  - `balanced` (default): `220ms` state transitions, calm string seekbar vibration while actively playing.
  - `expressive`: `320ms` shared-element transitions & subtle Oud resonance wave motion.
- **Screen-Off Idle Enforcement:** All animated painters and the Oud string ticker sit inside `TickerMode(enabled: isForegroundVisible && !isLiteMode)`.
- **Haptics:** Routed through `HapticService` supporting `off`, `light`, `medium`, `strong`.

---

## 5. Signature Components

1. **`WetarAdaptiveShell`:** Phone (<760dp) shows bottom navigation (`<= 5` customizable tabs) + persistent mini player; Tablet/macOS (>=760dp) shows collapsible sidebar navigation + main content + optional right Queue/Lyrics inspector + bottom desktop transport bar.
2. **`WetarMiniPlayer`:** Floating translucent pill or docked bottom bar with `Hero` artwork transition, track title/artist, play/pause, next, and optional seek progress hairline.
3. **`NowPlayingScreen` (5 Layout Variants):**
   - `oudStrings` (signature): Layered glowing artwork + harmonic string lines flanking controls + Oud-string waveform seekbar.
   - `classicCard`: Balanced spacious card layout with crisp metadata hierarchy.
   - `immersiveBleed`: Edge-to-edge blended artwork backdrop with floating transport dock.
   - `minimal`: Distraction-free centered typography & clean transport controls.
   - `vinylDisc`: Rotating turntable disc visual (paused automatically when paused or in Lite Mode).
4. **`WetarSeekBar`:** Deterministic 48-bar pseudo-waveform seeded from `track.stableKey`, vibrating Oud string line, thin bar, or thick capsule style.
5. **`WetarBackgroundRenderer`:** Supports Blurred Artwork, Artwork Gradient, Solid, Animated Gradient, Procedural Presets (`aurora`, `waves`, `grain`, `strings`), and Custom Downscaled Image across `playerOnly`, `homeAndPlayer`, or `wholeApp`.
6. **`WetarFastScrollbar`:** Touch-drag letter/Arabic-initial index overlay for jumping smoothly inside 20,000+ track lists.
7. **`WetarArtworkImage`:** Memory-sized (`ResizeImage`) LRU thumbnail + disk cache + geometric Oud placeholder.

---

## 6. Arabic / English RTL & Bidi Rules

- **Language Switch:** Instant toggle between Arabic (`ar`, Egyptian-friendly copy) and English (`en`) without app restart, plus Western (`0123`) vs Arabic-Indic (`٠١٢٣`) numerals setting.
- **Transport & Seek Bar Direction:**
  - Play/Pause icon is **never mirrored**.
  - Transport bar (`Shuffle - Previous - Play/Pause - Next - Repeat`) and Seek Bar (`elapsed` -> `duration`) remain **LTR by default** in RTL locales (matching familiar MENA audio ergonomics), with an Advanced Personalization toggle `mirrorTimelineInRtl` for users who prefer RTL scrubbing.
- **UI Mirroring:** Bottom nav, desktop sidebar, leading/trailing list icons, chevrons, swipe gestures, and drawer direction mirror automatically via Flutter directional APIs.
- **File Paths:** Every path string is wrapped in `Directionality(textDirection: TextDirection.ltr)` so slashes and folder segments stay readable inside RTL screens.
- **Lyrics Direction:** Automatic per-line Arabic script detection sets RTL/LTR alignment per line.

---

## 7. Five Core User Flows

1. **First Launch -> Folder Selection -> First Play:**
   - Launch (<1s) -> Brief Welcome & Offline privacy assurance -> Permission request with plain explanation -> In-App Folder Picker (grouped by volume, 1-tap "Select all folders with music" or granular checkboxes + subfolder toggles) -> Pick a Look (optional, skippable) -> Immediate Home/Library populated strictly from chosen folders -> Tap any track -> Starts gapless playback + persistent mini player + notification controls.
2. **Incremental Folder Management:**
   - Settings > Music Folders -> Toggle `Include subfolders`, exclude a subfolder, add folder (in-app or SAF/native bookmark picker), or remove folder -> Library reflects change immediately without rescanning untouched folders; unavailable storage retains selection & hidden playlist/favorite metadata until reconnected.
3. **Now Playing & Power Tools:**
   - Tap Mini Player -> Hero expands into chosen Now Playing layout -> Tap Lyrics icon for synced/RTL lyrics (`+/- 100ms` offset, `.lrc` attach) -> Tap Queue for drag-reorder/Save as Playlist -> Tap Timer / Speed / A-B Loop / Equalizer (capability-gated) in secondary action strip.
4. **Live Personalization & Look Sharing:**
   - Settings > Appearance -> Preview Looks, Colors (artwork adaptive or HSV/Hex), Fonts (bundled or `.ttf`/`.otf` import), Player Layout, Backgrounds, or Lite Mode live -> Apply instantly -> Export/Import `.wetarlook` via native picker & share sheet.
5. **External File Playback (Open-With / Drag-and-Drop):**
   - Open audio file from Android Files / macOS Finder / iOS Files -> Plays immediately as temporary queue entry without polluting Drift `Tracks` -> Optional dismissible banner offers "Add this folder to library".
