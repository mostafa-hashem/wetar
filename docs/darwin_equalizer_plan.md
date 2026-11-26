# Darwin Native Equalizer & Audio Effects Plan (iOS & macOS)

## 1. Current Capability Behavior
Wetar enforces a strict **Capability Matrix** (`lib/core/capabilities/platform_capabilities.dart`):
- **Android**: `supportsNativeEqualizer = true`, `supportsBassBoost`, `supportsVirtualizer`, and `supportsLoudnessEnhancer = true` via Android's hardware `AudioEffect` session pipeline (`just_audio` `AndroidEqualizer` + `AndroidLoudnessEnhancer` + `WetarPlatformPlugin.kt` `BassBoost`/`Virtualizer`).
- **iOS & macOS (Current)**: `supportsNativeEqualizer = false`, `supportsBassBoost = false`, `supportsVirtualizer = false`, `supportsLoudnessEnhancer = false`. Because `just_audio` on Darwin uses `AVQueuePlayer` without an attached `AVAudioEngine` node graph, Wetar hides the Equalizer entry points cleanly rather than presenting non-functional sliders.

## 2. Planned Native Darwin DSP Architecture
All UI (`EqualizerScreen`), BLoC state (`EqualizerCubit`), and SQLite persistence (`EqualizerPresets` table in `WetarDatabase`) are **already 100% platform-neutral**. Enabling full 10-band parametric EQ, Bass Boost, and Loudness Gain on iOS and macOS requires only a native Darwin DSP bridge behind `NativeAudioEffectsService`:

### Option A (Recommended — Zero Fork of `just_audio`): `MTAudioProcessingTap` on `AVPlayerItem.audioMix`
1. **Tap Attachment**:
   - Observe the active `AVPlayerItem` inside a lightweight Swift companion or forked Darwin `just_audio_darwin` handler.
   - Attach an `AVMutableAudioMix` with an `MTAudioProcessingTap` (`kMTAudioProcessingTapCreationFlag_PreEffects`) on the item's audio track.
2. **Real-Time Biquad Filter Cascade (`Accelerate` / `vDSP_biquadm`)**:
   - Inside `tapProcess`, run Apple's SIMD-vectorized `vDSP_biquadm` (from `Accelerate.framework`, zero heap allocations on the real-time audio render thread):
     - **Bands 1–10**: Peaking EQ biquad filters at `31 Hz, 62 Hz, 125 Hz, 250 Hz, 500 Hz, 1 kHz, 2 kHz, 4 kHz, 8 kHz, 16 kHz` (`Q = 1.41`, gain `-15 dB .. +15 dB`).
     - **Bass Boost**: Low-shelf biquad filter centered at `85 Hz` (`0 .. +12 dB` mapped from `0 .. 1000` strength).
     - **Loudness / Pre-amp**: Linear scalar gain with a soft-knee `tanh` limiter preventing digital clipping above `-0.2 dBFS`.
3. **Gapless Compatibility**:
   - Because `AVQueuePlayer` owns item transitions and each `AVPlayerItem` carries its own `audioMix` referencing shared atomic biquad coefficients, gapless playback, lock-screen `MPNowPlayingInfoCenter` scrubbing, AirPlay 2 routing, and security-scoped file URLs continue working natively.

### Option B (Alternative Custom Engine): `AVAudioEngine` + `AVAudioPlayerNode` + `AVAudioUnitEQ`
1. Replace `AVQueuePlayer` for local files with `AVAudioEngine`:
   - `AVAudioPlayerNode` -> `AVAudioUnitEQ(numberOfBands: 10)` -> `AVAudioUnitTimePitch` (also unlocks independent pitch control on Darwin!) -> `mainMixerNode`.
2. Double-buffer consecutive `AVAudioFile` schedules (`scheduleFile(_:at:completionCallbackType:.dataPlayedBack)`) to preserve sample-accurate gapless playback.
3. Trade-off: Requires re-implementing `NowPlaying` elapsed-time anchor synchronization and sample-rate-change graph resets when switching between `44.1 kHz` and `96 kHz` FLAC tracks.

## 3. Rollout Checklist
1. Implement `DarwinAudioTapProcessor.swift` shared across `ios/Runner` and `macos/Runner`.
2. Expose `getEqualizerBands`, `setBandGain`, `setEqualizerEnabled`, `setBassBoost`, and `setLoudnessGain` on `com.yourname.wetar/platform`.
3. Flip `supportsNativeEqualizer: true`, `supportsBassBoost: true`, and `supportsLoudnessEnhancer: true` in `PlatformCapabilities.detect()` for `Platform.isIOS` and `Platform.isMacOS`.
4. Verify zero audio glitches across `44.1 kHz`, `48 kHz`, and `96 kHz` local FLAC/ALAC/MP3 files with screen locked.
