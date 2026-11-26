// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Wetar';

  @override
  String get appTagline => 'Pure offline sound, tuned to you';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navFolders => 'Folders';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSettings => 'Settings';

  @override
  String get tabSongs => 'Songs';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabArtists => 'Artists';

  @override
  String get tabAlbumArtists => 'Album Artists';

  @override
  String get tabGenres => 'Genres';

  @override
  String get tabYears => 'Years';

  @override
  String get tabFolders => 'Folders';

  @override
  String get tabPlaylists => 'Playlists';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabRecentlyAdded => 'Recently Added';

  @override
  String get tabRecentlyPlayed => 'Recently Played';

  @override
  String get tabMostPlayed => 'Most Played';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionNext => 'Next';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionShuffle => 'Shuffle';

  @override
  String get actionShuffleAll => 'Shuffle All';

  @override
  String get actionRepeatOff => 'Repeat off';

  @override
  String get actionRepeatAll => 'Repeat all';

  @override
  String get actionRepeatOne => 'Repeat one';

  @override
  String get actionPlayNext => 'Play next';

  @override
  String get actionAddToQueue => 'Add to queue';

  @override
  String get actionAddToPlaylist => 'Add to playlist';

  @override
  String get actionFavorite => 'Favorite';

  @override
  String get actionUnfavorite => 'Remove favorite';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionSave => 'Save';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionResetAll => 'Reset all';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSelectAll => 'Select all';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionShare => 'Share';

  @override
  String get actionExport => 'Export';

  @override
  String get actionImport => 'Import';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRescan => 'Rescan';

  @override
  String get actionClearFilters => 'Clear filters';

  @override
  String get onboardingWelcomeTitle => 'Meet Wetar';

  @override
  String get onboardingWelcomeSubtitle =>
      'A fast, completely offline music player built around only the folders you choose.';

  @override
  String get onboardingOfflinePill => '100% Offline • Zero Network • No Ads';

  @override
  String get onboardingPermissionTitle => 'Audio access, strictly scoped';

  @override
  String get onboardingPermissionBody =>
      'Wetar asks for audio permission only to scan the music folders you pick. Nothing outside your chosen folders ever appears, and Wetar never modifies or deletes your audio files.';

  @override
  String get onboardingGrantPermission => 'Allow audio access';

  @override
  String get onboardingNotificationTitle => 'Keep playback controls visible';

  @override
  String get onboardingNotificationBody =>
      'Allow notification access on Android so media controls appear on your lock screen and notification shade.';

  @override
  String get onboardingAllowNotifications => 'Allow notification controls';

  @override
  String get onboardingFoldersTitle => 'Choose your music folders';

  @override
  String get onboardingFoldersSubtitle =>
      'Only tracks inside folders you select here will appear in your library.';

  @override
  String get onboardingSelectAllMusicFolders =>
      'Select all folders containing music';

  @override
  String get onboardingLookTitle => 'Pick your starting look';

  @override
  String get onboardingLookSubtitle =>
      'You can customize colors, fonts, backgrounds, and player layouts anytime.';

  @override
  String get onboardingLanguageLabel => 'App language';

  @override
  String get onboardingThemeLabel => 'App theme';

  @override
  String get foldersTitle => 'Music Folders';

  @override
  String get foldersPickerTitle => 'Choose Music Folders';

  @override
  String get foldersEmptyTitle => 'No music folders selected yet';

  @override
  String get foldersEmptySubtitle =>
      'Pick the folders that hold your music. Wetar stays completely out of everything else.';

  @override
  String get foldersChooseCta => 'Choose music folders';

  @override
  String get foldersSearchHint => 'Filter folders or paths...';

  @override
  String get foldersAddManualSaf => 'Add folder manually (system picker)';

  @override
  String get foldersAddButton => 'Add folder';

  @override
  String get foldersIncludeSubfolders => 'Include subfolders';

  @override
  String get foldersExcludeSubfolder => 'Exclude a subfolder';

  @override
  String foldersExcludedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count excluded subfolders',
      one: '1 excluded subfolder',
      zero: 'No excluded subfolders',
    );
    return '$_temp0';
  }

  @override
  String foldersTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: '0 tracks',
    );
    return '$_temp0';
  }

  @override
  String foldersSelectedSummary(int folders, int tracks) {
    return '$folders folders • $tracks tracks';
  }

  @override
  String get foldersUnavailableBadge => 'Unavailable';

  @override
  String get foldersUnavailableHint =>
      'Storage was removed or renamed. Selection and playlists remain safe until it returns.';

  @override
  String get foldersCloudPendingBadge => 'In iCloud';

  @override
  String get foldersCloudDownloading => 'Downloading from iCloud...';

  @override
  String foldersScanProgress(String folder, int processed, int total) {
    return 'Scanning $folder: $processed/$total';
  }

  @override
  String get foldersScanCancelled => 'Scan cancelled';

  @override
  String foldersRemovedUndo(String name) {
    return 'Removed $name from library';
  }

  @override
  String foldersAddedSuccess(String name) {
    return 'Added $name to library';
  }

  @override
  String get permissionDeniedTitle => 'Audio permission needed';

  @override
  String get permissionDeniedBody =>
      'Without permission, Wetar cannot list or play files from your music folders.';

  @override
  String get permissionOpenSettings => 'Open system settings';

  @override
  String get libraryEmptyTitle => 'Your library is waiting';

  @override
  String get libraryEmptyBody =>
      'Select at least one music folder to populate your songs, albums, and artists.';

  @override
  String get libraryFilteredEmpty => 'No tracks match this filter';

  @override
  String get librarySortBy => 'Sort by';

  @override
  String get librarySortTitle => 'Title';

  @override
  String get librarySortArtist => 'Artist';

  @override
  String get librarySortAlbum => 'Album';

  @override
  String get librarySortDateAdded => 'Date added';

  @override
  String get librarySortDuration => 'Duration';

  @override
  String get librarySortPlayCount => 'Most played';

  @override
  String get libraryViewMode => 'View mode';

  @override
  String get libraryViewList => 'List';

  @override
  String get libraryViewGrid => 'Grid';

  @override
  String librarySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get libraryUnknownArtist => 'Unknown Artist';

  @override
  String get libraryUnknownAlbum => 'Unknown Album';

  @override
  String get libraryUnknownGenre => 'Unknown Genre';

  @override
  String libraryDecadeLabel(int year) {
    return '${year}s';
  }

  @override
  String get searchHint => 'Search songs, albums, artists, playlists...';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String searchNoResults(String query) {
    return 'Nothing matched \"$query\"';
  }

  @override
  String get homeContinueListening => 'Continue listening';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeRecentlyAdded => 'Recently added';

  @override
  String get homeMostPlayed => 'Most played';

  @override
  String get homeYourFolders => 'Your folders';

  @override
  String get homeYourPlaylists => 'Playlists';

  @override
  String get homeCustomizeBlocks => 'Customize Home';

  @override
  String get playerNowPlaying => 'Now Playing';

  @override
  String get playerQueue => 'Queue';

  @override
  String get playerLyrics => 'Lyrics';

  @override
  String get playerEqualizer => 'Equalizer';

  @override
  String get playerSleepTimer => 'Sleep Timer';

  @override
  String get playerSpeedPitch => 'Speed & Pitch';

  @override
  String get playerSpeedLabel => 'Speed';

  @override
  String get playerPitchLabel => 'Pitch';

  @override
  String get playerAbLoop => 'A–B Loop';

  @override
  String get playerAbSetA => 'Set A';

  @override
  String get playerAbSetB => 'Set B';

  @override
  String get playerAbClear => 'Clear loop';

  @override
  String get playerCarMode => 'Car Mode';

  @override
  String get playerCarModeHint => 'Large distraction-free controls';

  @override
  String get playerShareCard => 'Share Track Card';

  @override
  String get playerShareFile => 'Share Audio File';

  @override
  String get playerTrackDetails => 'Track Details';

  @override
  String get playerChooseCustomArt => 'Choose custom album art';

  @override
  String get playerExternalTempBanner =>
      'Playing outside your library • Add its folder?';

  @override
  String get playerExternalAddFolder => 'Add folder';

  @override
  String get playerGestureHintOnce =>
      'Tip: swipe cover to skip, double-tap to play/pause. Editable in Settings > Gestures.';

  @override
  String playerCorruptSkipped(String title) {
    return 'Skipped unreadable or missing track: $title';
  }

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String queueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks in queue',
      one: '1 track in queue',
      zero: '0 tracks in queue',
    );
    return '$_temp0';
  }

  @override
  String get queueSaveAsPlaylist => 'Save queue as playlist';

  @override
  String get queueClearConfirmTitle => 'Clear queue?';

  @override
  String get queueClearConfirmBody =>
      'This stops current playback and empties the active queue.';

  @override
  String get queueRemovedUndo => 'Removed from queue';

  @override
  String get sleepTimerOff => 'Off';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepTimerEndOfTrack => 'End of current track';

  @override
  String sleepTimerAfterTracks(int count) {
    return 'After $count tracks';
  }

  @override
  String sleepTimerActiveRemaining(String time) {
    return 'Stops in $time';
  }

  @override
  String get playlistsCreate => 'New playlist';

  @override
  String get playlistsNameHint => 'Playlist name';

  @override
  String get playlistsSmartTitle => 'Smart playlists';

  @override
  String get playlistsUserTitle => 'Your playlists';

  @override
  String get playlistsSmartMostPlayed => 'Most Played';

  @override
  String get playlistsSmartRecentlyAdded => 'Recently Added';

  @override
  String get playlistsSmartNeverPlayed => 'Never Played';

  @override
  String get playlistsSmartLongTracks => 'Long Tracks & Lectures';

  @override
  String get playlistsImportM3u => 'Import M3U';

  @override
  String get playlistsExportM3u => 'Export M3U';

  @override
  String get playlistsDeleteTitle => 'Delete playlist?';

  @override
  String playlistsDeleteBody(String name) {
    return 'Delete \"$name\"? Your audio files on disk are never touched.';
  }

  @override
  String get playlistsEmpty => 'No playlists yet';

  @override
  String playlistsImportedCount(int count) {
    return 'Imported $count tracks into playlist';
  }

  @override
  String get equalizerEnable => 'Enable Equalizer';

  @override
  String get equalizerPresets => 'Presets';

  @override
  String get equalizerSavePreset => 'Save custom preset';

  @override
  String get equalizerPresetNameHint => 'Preset name';

  @override
  String get equalizerBassBoost => 'Bass Boost';

  @override
  String get equalizerVirtualizer => 'Virtualizer';

  @override
  String get equalizerLoudness => 'Volume Boost';

  @override
  String get equalizerLoudnessWarning =>
      'High volume boost may cause speaker distortion';

  @override
  String get equalizerUnavailable =>
      'Equalizer is not available on this platform yet.';

  @override
  String get lyricsEmptyTitle => 'No lyrics found';

  @override
  String get lyricsEmptyBody =>
      'Add embedded lyrics or attach an .lrc file from your device.';

  @override
  String get lyricsAttachLrc => 'Attach .lrc file';

  @override
  String lyricsOffsetLabel(int ms) {
    return 'Sync offset ($ms ms)';
  }

  @override
  String get lyricsFontSize => 'Lyrics text size';

  @override
  String get detailsFormat => 'Format';

  @override
  String get detailsBitrate => 'Bitrate';

  @override
  String get detailsSampleRate => 'Sample rate';

  @override
  String get detailsChannels => 'Channels';

  @override
  String get detailsDuration => 'Duration';

  @override
  String get detailsFileSize => 'File size';

  @override
  String get detailsFilePath => 'File path';

  @override
  String get detailsCopyPath => 'Copy path';

  @override
  String get detailsPathCopied => 'Path copied';

  @override
  String get detailsReplayGain => 'ReplayGain';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSearchHint => 'Search settings...';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle =>
      'Looks, colors, fonts, backgrounds, player style';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsPlaybackSubtitle =>
      'ReplayGain, skip silence, resume, headphones';

  @override
  String get settingsLibrary => 'Library';

  @override
  String get settingsLibrarySubtitle =>
      'Minimum duration, multi-artist separators';

  @override
  String get settingsMusicFolders => 'Music Folders';

  @override
  String get settingsMusicFoldersSubtitle =>
      'Choose folders, exclusions, rescan';

  @override
  String get settingsAudio => 'Audio & Effects';

  @override
  String get settingsAudioSubtitle => 'Equalizer, fades, volume normalization';

  @override
  String get settingsGestures => 'Gestures & Haptics';

  @override
  String get settingsGesturesSubtitle =>
      'Swipes, double-tap, long-press, vibration';

  @override
  String get settingsLanguage => 'Language & Numerals';

  @override
  String get settingsLanguageSubtitle => 'Arabic / English, RTL, numeral style';

  @override
  String get settingsBackup => 'Backup, Cache & Stats';

  @override
  String get settingsBackupSubtitle =>
      'JSON backup, Wetar Wrapped, cache, logs';

  @override
  String get settingsAbout => 'About Wetar';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get personalizationLooks => 'Looks';

  @override
  String get personalizationColors => 'Colors';

  @override
  String get personalizationFonts => 'Typography & Fonts';

  @override
  String get personalizationPlayer => 'Now Playing & Mini Player';

  @override
  String get personalizationBackgrounds => 'Backgrounds';

  @override
  String get personalizationLayout => 'Home & Library Layout';

  @override
  String get personalizationMotion => 'Shape, Depth & Motion';

  @override
  String get personalizationLiteMode => 'Lite Mode';

  @override
  String get personalizationLiteModeAuto =>
      'Automatic (Battery Saver / Reduce Motion)';

  @override
  String get personalizationLiteModeOn => 'Always On';

  @override
  String get personalizationLiteModeOff => 'Always Off';

  @override
  String get personalizationThemeMode => 'Theme mode';

  @override
  String get personalizationThemeSystem => 'System';

  @override
  String get personalizationThemeLight => 'Light';

  @override
  String get personalizationThemeDark => 'Dark';

  @override
  String get personalizationThemeAmoled => 'AMOLED Black';

  @override
  String get personalizationScheduledDark => 'Scheduled dark mode';

  @override
  String get personalizationAdaptArtwork => 'Adapt colors to current artwork';

  @override
  String get personalizationSystemDynamicColor => 'Use system dynamic colors';

  @override
  String get personalizationCustomColor => 'Custom accent color';

  @override
  String get personalizationContrast => 'Contrast level';

  @override
  String get personalizationContrastStandard => 'Standard';

  @override
  String get personalizationContrastMedium => 'Medium';

  @override
  String get personalizationContrastHigh => 'High';

  @override
  String get personalizationSurfaceTint => 'Surface tint';

  @override
  String get personalizationTextEmphasis => 'Text emphasis';

  @override
  String get personalizationFontArabic => 'Arabic font';

  @override
  String get personalizationFontLatin => 'Latin font';

  @override
  String get personalizationFontSystem => 'System default';

  @override
  String get personalizationFontScale => 'Font size scale';

  @override
  String get personalizationFontWeight => 'Font weight';

  @override
  String get personalizationImportFont => 'Import .ttf / .otf font';

  @override
  String personalizationFontImported(String name) {
    return 'Imported font: $name';
  }

  @override
  String get personalizationFontInvalid => 'Unsupported or invalid font file';

  @override
  String get personalizationPlayerLayout => 'Player layout';

  @override
  String get personalizationLayoutOudStrings => 'Oud Strings (Signature)';

  @override
  String get personalizationLayoutClassic => 'Classic Card';

  @override
  String get personalizationLayoutImmersive => 'Immersive Bleed';

  @override
  String get personalizationLayoutMinimal => 'Minimal';

  @override
  String get personalizationLayoutVinyl => 'Vinyl Disc';

  @override
  String get personalizationArtShape => 'Artwork shape';

  @override
  String get personalizationArtRoundedSquare => 'Rounded Square';

  @override
  String get personalizationArtSquircle => 'Squircle';

  @override
  String get personalizationArtCircle => 'Circle';

  @override
  String get personalizationSeekBarStyle => 'Seek bar style';

  @override
  String get personalizationSeekStringWaveform => 'Oud String Waveform';

  @override
  String get personalizationSeekStylizedBars => 'Stylized Bars';

  @override
  String get personalizationSeekThinLine => 'Thin Line';

  @override
  String get personalizationSeekThickPill => 'Thick Pill';

  @override
  String get personalizationMiniPlayerStyle => 'Mini player style';

  @override
  String get personalizationMiniPlayerFloating => 'Floating pill';

  @override
  String get personalizationMiniPlayerDocked => 'Docked bar';

  @override
  String get personalizationBackgroundMode => 'Background style';

  @override
  String get personalizationBgBlurredArt => 'Blurred artwork';

  @override
  String get personalizationBgArtGradient => 'Artwork gradient';

  @override
  String get personalizationBgSolid => 'Solid color';

  @override
  String get personalizationBgAnimatedGradient => 'Animated gradient';

  @override
  String get personalizationBgProceduralAurora => 'Aurora (procedural)';

  @override
  String get personalizationBgProceduralWaves => 'Waves (procedural)';

  @override
  String get personalizationBgProceduralGrain => 'Warm grain (procedural)';

  @override
  String get personalizationBgProceduralStrings => 'Oud strings (procedural)';

  @override
  String get personalizationBgCustomImage => 'Custom image';

  @override
  String get personalizationBgBlur => 'Blur';

  @override
  String get personalizationBgDim => 'Dim';

  @override
  String get personalizationBgSaturation => 'Saturation';

  @override
  String get personalizationBgScope => 'Apply background to';

  @override
  String get personalizationBgScopePlayer => 'Player only';

  @override
  String get personalizationBgScopeHomePlayer => 'Home & Player';

  @override
  String get personalizationBgScopeWholeApp => 'Whole app';

  @override
  String get personalizationCornerRadius => 'Corner radius';

  @override
  String get personalizationShadowIntensity => 'Shadow depth';

  @override
  String get personalizationBlurIntensity => 'Glass blur';

  @override
  String get personalizationMotionIntensity => 'Animation intensity';

  @override
  String get personalizationMotionOff => 'Off';

  @override
  String get personalizationMotionReduced => 'Reduced';

  @override
  String get personalizationMotionBalanced => 'Balanced';

  @override
  String get personalizationMotionExpressive => 'Expressive';

  @override
  String get personalizationHapticsIntensity => 'Haptic intensity';

  @override
  String get personalizationHapticsOff => 'Off';

  @override
  String get personalizationHapticsLight => 'Light';

  @override
  String get personalizationHapticsMedium => 'Medium';

  @override
  String get personalizationHapticsStrong => 'Strong';

  @override
  String get personalizationListDensity => 'List density';

  @override
  String get personalizationDensityCompact => 'Compact';

  @override
  String get personalizationDensityComfortable => 'Comfortable';

  @override
  String get personalizationDensitySpacious => 'Spacious';

  @override
  String get personalizationGridColumns => 'Grid columns';

  @override
  String get personalizationShowArtInLists => 'Show artwork in lists';

  @override
  String get personalizationMirrorTimelineRtl =>
      'Mirror seek bar in Arabic RTL';

  @override
  String get personalizationSaveLook => 'Save current look';

  @override
  String get personalizationImportLook => 'Import .wetarlook';

  @override
  String get personalizationExportLook => 'Export .wetarlook';

  @override
  String get personalizationLookInvalid =>
      'Invalid or corrupted .wetarlook file';

  @override
  String get personalizationResetSection => 'Reset this section';

  @override
  String get personalizationResetAllTitle => 'Reset all appearance settings?';

  @override
  String get personalizationResetAllBody =>
      'This restores Wetar\'s default colors, fonts, layout, and gestures.';

  @override
  String playbackMinDuration(int seconds) {
    return 'Hide tracks shorter than (${seconds}s)';
  }

  @override
  String get playbackArtistSeparators => 'Multi-artist separators';

  @override
  String get playbackFadePlayPause => 'Smooth volume fade on play/pause';

  @override
  String get playbackSkipSilence => 'Skip silence';

  @override
  String get playbackReplayGainMode => 'ReplayGain normalization';

  @override
  String get playbackReplayGainOff => 'Off';

  @override
  String get playbackReplayGainTrack => 'Track';

  @override
  String get playbackReplayGainAlbum => 'Album';

  @override
  String get playbackReplayGainPreamp => 'Pre-amp gain';

  @override
  String get playbackRememberLongPos =>
      'Remember position for long tracks (>=15 min)';

  @override
  String get playbackAutoPlayBt =>
      'Auto-play when headphones/Bluetooth connect';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageNumerals => 'Numerals style';

  @override
  String get languageNumeralsWestern => 'Western (0123)';

  @override
  String get languageNumeralsArabicIndic => 'Arabic-Indic (٠١٢٣)';

  @override
  String get backupExportJson => 'Export full local backup (.json)';

  @override
  String get backupImportJson => 'Restore local backup (.json)';

  @override
  String get backupSuccess => 'Backup saved successfully';

  @override
  String get backupRestored => 'Backup restored cleanly';

  @override
  String get backupInvalid => 'Could not validate backup file';

  @override
  String get statsTitle => 'Listening Recap (Wetar Wrapped)';

  @override
  String get statsTotalTime => 'Total listening time';

  @override
  String get statsTotalPlays => 'Total plays';

  @override
  String get statsTopTracks => 'Top tracks';

  @override
  String get statsTopArtists => 'Top artists';

  @override
  String get statsSharePoster => 'Share Wrapped card';

  @override
  String get cacheClearButton => 'Clear app caches';

  @override
  String cacheSizeLabel(String size) {
    return 'Cache usage: $size';
  }

  @override
  String get diagnosticsTitle => 'Local Diagnostics & Logs';

  @override
  String get diagnosticsShare => 'Share local log file';

  @override
  String get diagnosticsClear => 'Clear log file';

  @override
  String get batteryGuideTitle => 'Keep background music uninterrupted';

  @override
  String get batteryGuideBody =>
      'Some Android brands aggressively stop background audio. Set Wetar to Unrestricted battery usage if playback pauses when the screen turns off.';

  @override
  String get batteryGuideAction => 'Open battery exemption settings';

  @override
  String get batteryGuideOptimizedOk => 'Battery exemption is already active';

  @override
  String get desktopCompactMiniMode => 'Compact mini player';

  @override
  String get desktopMenuLibrary => 'Library';

  @override
  String get desktopMenuPlayback => 'Playback';

  @override
  String get desktopMenuView => 'View';

  @override
  String get desktopShortcutsHint =>
      'Space: Play/Pause • Arrows: Seek • Cmd+F: Search';
}
