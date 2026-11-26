# Wetar Release, Store Privacy & Cross-Platform CI Guide

## 1. Replacing the Placeholder Application / Bundle Identifier
Wetar ships with the placeholder ID `com.yourname.wetar`. Before publishing, replace it in these 4 locations:
1. **Android**:
   - `android/app/build.gradle.kts` -> `namespace` and `applicationId`
   - `android/app/src/main/AndroidManifest.xml` -> `FileProvider` `android:authorities` (`<your.id>.fileprovider`) and Kotlin package declaration if desired.
2. **macOS**:
   - `macos/Runner/Configs/AppInfo.xcconfig` -> `PRODUCT_BUNDLE_IDENTIFIER`
3. **iOS**:
   - `ios/Runner.xcodeproj/project.pbxproj` -> `PRODUCT_BUNDLE_IDENTIFIER` (`Runner` and `RunnerTests`)
4. *(Optional)* MethodChannel namespace in `WetarPlatformChannel`, `WetarPlatformPlugin.kt`, `MainFlutterWindow.swift`, and `AppDelegate.swift` (internal to the app process; safe to keep or rename together).

---

## 2. Android Release Signing, Shrinking & Google Play Data Safety

### Keystore Setup
1. Generate an upload keystore (keep outside git):
   ```bash
   keytool -genkey -v -keystore ~/wetar-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (ignored by git) and reference it in `signingConfigs.create("release")` in `android/app/build.gradle.kts`.
3. Build obfuscated App Bundle & split APKs with symbol maps:
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
   flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols/android
   ```
4. Verify **zero network permissions** before every Play Store upload:
   ```bash
   aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
   ```
   Expected: **no** `android.permission.INTERNET`, `ACCESS_NETWORK_STATE`, or `ACCESS_WIFI_STATE`.

### Google Play Console — Data Safety Answers
- **Does your app collect or share any of the required user data types?** -> **No**
- **Permissions justification**: `READ_MEDIA_AUDIO` (API 33+) / `READ_EXTERNAL_STORAGE` (API <= 32) is used solely on-device to index and play audio files inside folders explicitly chosen by the user; `FOREGROUND_SERVICE_MEDIA_PLAYBACK` keeps local audio playing when the screen is off.

---

## 3. Apple Developer Setup (iOS App Store, TestFlight & Mac App Store)

### Provisioning & Capabilities
1. Enroll in the **Apple Developer Program** and register the App ID (`com.yourname.wetar`) for **iOS** and **macOS**.
2. **iOS Capabilities**:
   - Background Modes -> **Audio, AirPlay, and Picture in Picture** (`UIBackgroundModes = [audio]` in `ios/Runner/Info.plist`).
   - Supports Document Browser / Files app sharing (`UIFileSharingEnabled = true`, `LSSupportsOpeningDocumentsInPlace = true`).
3. **macOS Capabilities (`macos/Runner/Release.entitlements`)**:
   - `com.apple.security.app-sandbox = true`
   - `com.apple.security.files.user-selected.read-write = true`
   - `com.apple.security.files.bookmarks.app-scope = true`
   - **No** `com.apple.security.network.client` or `com.apple.security.network.server`!
   - *Mac App Store Review Note*: Explain that `bookmarks.app-scope` persists read access to the user's chosen music folders across app restarts so their offline music library does not need re-picking on every launch.
4. **App Store Connect — Privacy Nutrition Labels & `PrivacyInfo.xcprivacy`**:
   - **Data Collection**: Select **"No, we do not collect data from this app"** (`Data Not Collected`).
   - `ios/Runner/PrivacyInfo.xcprivacy` is bundled in `Runner.app` declaring `NSPrivacyTracking = false`, zero collected data types, and Required Reason APIs (`CA92.1` UserDefaults, `C617.1` FileTimestamp for incremental folder scan mtimes, `E174.1` DiskSpace, `35F9.1` SystemBootTime).

---

## 4. Cloud CI Workflows (Build Android, macOS & iOS from Windows/Linux/Mac)

### Option A: GitHub Actions (`.github/workflows/release.yml` on `macos-15` runner)
```yaml
name: Wetar Cross-Platform Release

on:
  workflow_dispatch:
  push:
    tags:
      - 'v*'

jobs:
  verify-and-build:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies & verify static analysis
        run: |
          flutter pub get
          dart format --output=none --set-exit-if-changed lib test
          flutter analyze
          flutter test

      - name: Build Android Split APKs & verify zero network permission
        run: |
          flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols/android
          ! $ANDROID_HOME/build-tools/$(ls $ANDROID_HOME/build-tools | tail -n 1)/aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-release.apk | grep -q "android.permission.INTERNET"

      - name: Build macOS Release App & verify zero network entitlements
        run: |
          flutter build macos --release
          ! codesign -d --entitlements - build/macos/Build/Products/Release/wetar.app | grep -q "com.apple.security.network"
          ditto -c -k --keepParent build/macos/Build/Products/Release/wetar.app build/Wetar-macOS.zip

      - name: Build iOS Release Bundle (unsigned; add Apple certificates for TestFlight IPA)
        run: |
          flutter build ios --release --no-codesign

      - uses: actions/upload-artifact@v4
        with:
          name: wetar-release-artifacts
          path: |
            build/app/outputs/flutter-apk/*-release.apk
            build/Wetar-macOS.zip
```

### Option B: Codemagic (`codemagic.yaml` for TestFlight & Mac App Store Signing from Windows)
```yaml
workflows:
  wetar-apple-release:
    name: Wetar iOS & macOS Release
    instance_type: mac_mini_m2
    max_build_duration: 45
    integrations:
      app_store_connect: WetarAppStoreKey
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Verify quality gates
        script: |
          flutter pub get
          flutter analyze
          flutter test
      - name: Build iOS IPA
        script: |
          flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
      - name: Build macOS App
        script: |
          flutter build macos --release
    artifacts:
      - build/ios/ipa/*.ipa
      - build/macos/Build/Products/Release/wetar.app
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true
```
