import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Wetar'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Pure offline sound, tuned to you'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get navFolders;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @tabSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get tabSongs;

  /// No description provided for @tabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get tabAlbums;

  /// No description provided for @tabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get tabArtists;

  /// No description provided for @tabAlbumArtists.
  ///
  /// In en, this message translates to:
  /// **'Album Artists'**
  String get tabAlbumArtists;

  /// No description provided for @tabGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get tabGenres;

  /// No description provided for @tabYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get tabYears;

  /// No description provided for @tabFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get tabFolders;

  /// No description provided for @tabPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get tabPlaylists;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @tabRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get tabRecentlyAdded;

  /// No description provided for @tabRecentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get tabRecentlyPlayed;

  /// No description provided for @tabMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get tabMostPlayed;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get actionPrevious;

  /// No description provided for @actionShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get actionShuffle;

  /// No description provided for @actionShuffleAll.
  ///
  /// In en, this message translates to:
  /// **'Shuffle All'**
  String get actionShuffleAll;

  /// No description provided for @actionRepeatOff.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get actionRepeatOff;

  /// No description provided for @actionRepeatAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat all'**
  String get actionRepeatAll;

  /// No description provided for @actionRepeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get actionRepeatOne;

  /// No description provided for @actionPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get actionPlayNext;

  /// No description provided for @actionAddToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get actionAddToQueue;

  /// No description provided for @actionAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get actionAddToPlaylist;

  /// No description provided for @actionFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get actionFavorite;

  /// No description provided for @actionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get actionUnfavorite;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get actionResetAll;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get actionSelectAll;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get actionRescan;

  /// No description provided for @actionClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get actionClearFilters;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet Wetar'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A fast, completely offline music player built around only the folders you choose.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingOfflinePill.
  ///
  /// In en, this message translates to:
  /// **'100% Offline • Zero Network • No Ads'**
  String get onboardingOfflinePill;

  /// No description provided for @onboardingPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio access, strictly scoped'**
  String get onboardingPermissionTitle;

  /// No description provided for @onboardingPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Wetar asks for audio permission only to scan the music folders you pick. Nothing outside your chosen folders ever appears, and Wetar never modifies or deletes your audio files.'**
  String get onboardingPermissionBody;

  /// No description provided for @onboardingGrantPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow audio access'**
  String get onboardingGrantPermission;

  /// No description provided for @onboardingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep playback controls visible'**
  String get onboardingNotificationTitle;

  /// No description provided for @onboardingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notification access on Android so media controls appear on your lock screen and notification shade.'**
  String get onboardingNotificationBody;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notification controls'**
  String get onboardingAllowNotifications;

  /// No description provided for @onboardingFoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your music folders'**
  String get onboardingFoldersTitle;

  /// No description provided for @onboardingFoldersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only tracks inside folders you select here will appear in your library.'**
  String get onboardingFoldersSubtitle;

  /// No description provided for @onboardingSelectAllMusicFolders.
  ///
  /// In en, this message translates to:
  /// **'Select all folders containing music'**
  String get onboardingSelectAllMusicFolders;

  /// No description provided for @onboardingLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your starting look'**
  String get onboardingLookTitle;

  /// No description provided for @onboardingLookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can customize colors, fonts, backgrounds, and player layouts anytime.'**
  String get onboardingLookSubtitle;

  /// No description provided for @onboardingLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get onboardingLanguageLabel;

  /// No description provided for @onboardingThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get onboardingThemeLabel;

  /// No description provided for @foldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Music Folders'**
  String get foldersTitle;

  /// No description provided for @foldersPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Music Folders'**
  String get foldersPickerTitle;

  /// No description provided for @foldersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No music folders selected yet'**
  String get foldersEmptyTitle;

  /// No description provided for @foldersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the folders that hold your music. Wetar stays completely out of everything else.'**
  String get foldersEmptySubtitle;

  /// No description provided for @foldersChooseCta.
  ///
  /// In en, this message translates to:
  /// **'Choose music folders'**
  String get foldersChooseCta;

  /// No description provided for @foldersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter folders or paths...'**
  String get foldersSearchHint;

  /// No description provided for @foldersAddManualSaf.
  ///
  /// In en, this message translates to:
  /// **'Add folder manually (system picker)'**
  String get foldersAddManualSaf;

  /// No description provided for @foldersAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get foldersAddButton;

  /// No description provided for @foldersIncludeSubfolders.
  ///
  /// In en, this message translates to:
  /// **'Include subfolders'**
  String get foldersIncludeSubfolders;

  /// No description provided for @foldersExcludeSubfolder.
  ///
  /// In en, this message translates to:
  /// **'Exclude a subfolder'**
  String get foldersExcludeSubfolder;

  /// No description provided for @foldersExcludedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No excluded subfolders} =1{1 excluded subfolder} other{{count} excluded subfolders}}'**
  String foldersExcludedCount(int count);

  /// No description provided for @foldersTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 tracks} =1{1 track} other{{count} tracks}}'**
  String foldersTrackCount(int count);

  /// No description provided for @foldersSelectedSummary.
  ///
  /// In en, this message translates to:
  /// **'{folders} folders • {tracks} tracks'**
  String foldersSelectedSummary(int folders, int tracks);

  /// No description provided for @foldersUnavailableBadge.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get foldersUnavailableBadge;

  /// No description provided for @foldersUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Storage was removed or renamed. Selection and playlists remain safe until it returns.'**
  String get foldersUnavailableHint;

  /// No description provided for @foldersCloudPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'In iCloud'**
  String get foldersCloudPendingBadge;

  /// No description provided for @foldersCloudDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading from iCloud...'**
  String get foldersCloudDownloading;

  /// No description provided for @foldersScanProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning {folder}: {processed}/{total}'**
  String foldersScanProgress(String folder, int processed, int total);

  /// No description provided for @foldersScanCancelled.
  ///
  /// In en, this message translates to:
  /// **'Scan cancelled'**
  String get foldersScanCancelled;

  /// No description provided for @foldersRemovedUndo.
  ///
  /// In en, this message translates to:
  /// **'Removed {name} from library'**
  String foldersRemovedUndo(String name);

  /// No description provided for @foldersAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to library'**
  String foldersAddedSuccess(String name);

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio permission needed'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Without permission, Wetar cannot list or play files from your music folders.'**
  String get permissionDeniedBody;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get permissionOpenSettings;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is waiting'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Select at least one music folder to populate your songs, albums, and artists.'**
  String get libraryEmptyBody;

  /// No description provided for @libraryFilteredEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tracks match this filter'**
  String get libraryFilteredEmpty;

  /// No description provided for @librarySortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get librarySortBy;

  /// No description provided for @librarySortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get librarySortTitle;

  /// No description provided for @librarySortArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get librarySortArtist;

  /// No description provided for @librarySortAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get librarySortAlbum;

  /// No description provided for @librarySortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get librarySortDateAdded;

  /// No description provided for @librarySortDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get librarySortDuration;

  /// No description provided for @librarySortPlayCount.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get librarySortPlayCount;

  /// No description provided for @libraryViewMode.
  ///
  /// In en, this message translates to:
  /// **'View mode'**
  String get libraryViewMode;

  /// No description provided for @libraryViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get libraryViewList;

  /// No description provided for @libraryViewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get libraryViewGrid;

  /// No description provided for @librarySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String librarySelectedCount(int count);

  /// No description provided for @libraryUnknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get libraryUnknownArtist;

  /// No description provided for @libraryUnknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get libraryUnknownAlbum;

  /// No description provided for @libraryUnknownGenre.
  ///
  /// In en, this message translates to:
  /// **'Unknown Genre'**
  String get libraryUnknownGenre;

  /// No description provided for @libraryDecadeLabel.
  ///
  /// In en, this message translates to:
  /// **'{year}s'**
  String libraryDecadeLabel(int year);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs, albums, artists, playlists...'**
  String get searchHint;

  /// No description provided for @searchFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchFilterAll;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @homeContinueListening.
  ///
  /// In en, this message translates to:
  /// **'Continue listening'**
  String get homeContinueListening;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeRecentlyAdded;

  /// No description provided for @homeMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get homeMostPlayed;

  /// No description provided for @homeYourFolders.
  ///
  /// In en, this message translates to:
  /// **'Your folders'**
  String get homeYourFolders;

  /// No description provided for @homeYourPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get homeYourPlaylists;

  /// No description provided for @homeCustomizeBlocks.
  ///
  /// In en, this message translates to:
  /// **'Customize Home'**
  String get homeCustomizeBlocks;

  /// No description provided for @playerNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get playerNowPlaying;

  /// No description provided for @playerQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get playerQueue;

  /// No description provided for @playerLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get playerLyrics;

  /// No description provided for @playerEqualizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get playerEqualizer;

  /// No description provided for @playerSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get playerSleepTimer;

  /// No description provided for @playerSpeedPitch.
  ///
  /// In en, this message translates to:
  /// **'Speed & Pitch'**
  String get playerSpeedPitch;

  /// No description provided for @playerSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playerSpeedLabel;

  /// No description provided for @playerPitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get playerPitchLabel;

  /// No description provided for @playerAbLoop.
  ///
  /// In en, this message translates to:
  /// **'A–B Loop'**
  String get playerAbLoop;

  /// No description provided for @playerAbSetA.
  ///
  /// In en, this message translates to:
  /// **'Set A'**
  String get playerAbSetA;

  /// No description provided for @playerAbSetB.
  ///
  /// In en, this message translates to:
  /// **'Set B'**
  String get playerAbSetB;

  /// No description provided for @playerAbClear.
  ///
  /// In en, this message translates to:
  /// **'Clear loop'**
  String get playerAbClear;

  /// No description provided for @playerCarMode.
  ///
  /// In en, this message translates to:
  /// **'Car Mode'**
  String get playerCarMode;

  /// No description provided for @playerCarModeHint.
  ///
  /// In en, this message translates to:
  /// **'Large distraction-free controls'**
  String get playerCarModeHint;

  /// No description provided for @playerShareCard.
  ///
  /// In en, this message translates to:
  /// **'Share Track Card'**
  String get playerShareCard;

  /// No description provided for @playerShareFile.
  ///
  /// In en, this message translates to:
  /// **'Share Audio File'**
  String get playerShareFile;

  /// No description provided for @playerTrackDetails.
  ///
  /// In en, this message translates to:
  /// **'Track Details'**
  String get playerTrackDetails;

  /// No description provided for @playerChooseCustomArt.
  ///
  /// In en, this message translates to:
  /// **'Choose custom album art'**
  String get playerChooseCustomArt;

  /// No description provided for @playerExternalTempBanner.
  ///
  /// In en, this message translates to:
  /// **'Playing outside your library • Add its folder?'**
  String get playerExternalTempBanner;

  /// No description provided for @playerExternalAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get playerExternalAddFolder;

  /// No description provided for @playerGestureHintOnce.
  ///
  /// In en, this message translates to:
  /// **'Tip: swipe cover to skip, double-tap to play/pause. Editable in Settings > Gestures.'**
  String get playerGestureHintOnce;

  /// No description provided for @playerCorruptSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped unreadable or missing track: {title}'**
  String playerCorruptSkipped(String title);

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @queueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 tracks in queue} =1{1 track in queue} other{{count} tracks in queue}}'**
  String queueCount(int count);

  /// No description provided for @queueSaveAsPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Save queue as playlist'**
  String get queueSaveAsPlaylist;

  /// No description provided for @queueClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear queue?'**
  String get queueClearConfirmTitle;

  /// No description provided for @queueClearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This stops current playback and empties the active queue.'**
  String get queueClearConfirmBody;

  /// No description provided for @queueRemovedUndo.
  ///
  /// In en, this message translates to:
  /// **'Removed from queue'**
  String get queueRemovedUndo;

  /// No description provided for @sleepTimerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepTimerOff;

  /// No description provided for @sleepTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepTimerMinutes(int minutes);

  /// No description provided for @sleepTimerEndOfTrack.
  ///
  /// In en, this message translates to:
  /// **'End of current track'**
  String get sleepTimerEndOfTrack;

  /// No description provided for @sleepTimerAfterTracks.
  ///
  /// In en, this message translates to:
  /// **'After {count} tracks'**
  String sleepTimerAfterTracks(int count);

  /// No description provided for @sleepTimerActiveRemaining.
  ///
  /// In en, this message translates to:
  /// **'Stops in {time}'**
  String sleepTimerActiveRemaining(String time);

  /// No description provided for @playlistsCreate.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get playlistsCreate;

  /// No description provided for @playlistsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistsNameHint;

  /// No description provided for @playlistsSmartTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart playlists'**
  String get playlistsSmartTitle;

  /// No description provided for @playlistsUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Your playlists'**
  String get playlistsUserTitle;

  /// No description provided for @playlistsSmartMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get playlistsSmartMostPlayed;

  /// No description provided for @playlistsSmartRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get playlistsSmartRecentlyAdded;

  /// No description provided for @playlistsSmartNeverPlayed.
  ///
  /// In en, this message translates to:
  /// **'Never Played'**
  String get playlistsSmartNeverPlayed;

  /// No description provided for @playlistsSmartLongTracks.
  ///
  /// In en, this message translates to:
  /// **'Long Tracks & Lectures'**
  String get playlistsSmartLongTracks;

  /// No description provided for @playlistsImportM3u.
  ///
  /// In en, this message translates to:
  /// **'Import M3U'**
  String get playlistsImportM3u;

  /// No description provided for @playlistsExportM3u.
  ///
  /// In en, this message translates to:
  /// **'Export M3U'**
  String get playlistsExportM3u;

  /// No description provided for @playlistsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get playlistsDeleteTitle;

  /// No description provided for @playlistsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Your audio files on disk are never touched.'**
  String playlistsDeleteBody(String name);

  /// No description provided for @playlistsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get playlistsEmpty;

  /// No description provided for @playlistsImportedCount.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} tracks into playlist'**
  String playlistsImportedCount(int count);

  /// No description provided for @equalizerEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Equalizer'**
  String get equalizerEnable;

  /// No description provided for @equalizerPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get equalizerPresets;

  /// No description provided for @equalizerSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save custom preset'**
  String get equalizerSavePreset;

  /// No description provided for @equalizerPresetNameHint.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get equalizerPresetNameHint;

  /// No description provided for @equalizerBassBoost.
  ///
  /// In en, this message translates to:
  /// **'Bass Boost'**
  String get equalizerBassBoost;

  /// No description provided for @equalizerVirtualizer.
  ///
  /// In en, this message translates to:
  /// **'Virtualizer'**
  String get equalizerVirtualizer;

  /// No description provided for @equalizerLoudness.
  ///
  /// In en, this message translates to:
  /// **'Volume Boost'**
  String get equalizerLoudness;

  /// No description provided for @equalizerLoudnessWarning.
  ///
  /// In en, this message translates to:
  /// **'High volume boost may cause speaker distortion'**
  String get equalizerLoudnessWarning;

  /// No description provided for @equalizerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Equalizer is not available on this platform yet.'**
  String get equalizerUnavailable;

  /// No description provided for @lyricsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No lyrics found'**
  String get lyricsEmptyTitle;

  /// No description provided for @lyricsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add embedded lyrics or attach an .lrc file from your device.'**
  String get lyricsEmptyBody;

  /// No description provided for @lyricsAttachLrc.
  ///
  /// In en, this message translates to:
  /// **'Attach .lrc file'**
  String get lyricsAttachLrc;

  /// No description provided for @lyricsOffsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync offset ({ms} ms)'**
  String lyricsOffsetLabel(int ms);

  /// No description provided for @lyricsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Lyrics text size'**
  String get lyricsFontSize;

  /// No description provided for @detailsFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get detailsFormat;

  /// No description provided for @detailsBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get detailsBitrate;

  /// No description provided for @detailsSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get detailsSampleRate;

  /// No description provided for @detailsChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get detailsChannels;

  /// No description provided for @detailsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detailsDuration;

  /// No description provided for @detailsFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get detailsFileSize;

  /// No description provided for @detailsFilePath.
  ///
  /// In en, this message translates to:
  /// **'File path'**
  String get detailsFilePath;

  /// No description provided for @detailsCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get detailsCopyPath;

  /// No description provided for @detailsPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Path copied'**
  String get detailsPathCopied;

  /// No description provided for @detailsReplayGain.
  ///
  /// In en, this message translates to:
  /// **'ReplayGain'**
  String get detailsReplayGain;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get settingsSearchHint;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looks, colors, fonts, backgrounds, player style'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlayback;

  /// No description provided for @settingsPlaybackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ReplayGain, skip silence, resume, headphones'**
  String get settingsPlaybackSubtitle;

  /// No description provided for @settingsLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get settingsLibrary;

  /// No description provided for @settingsLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum duration, multi-artist separators'**
  String get settingsLibrarySubtitle;

  /// No description provided for @settingsMusicFolders.
  ///
  /// In en, this message translates to:
  /// **'Music Folders'**
  String get settingsMusicFolders;

  /// No description provided for @settingsMusicFoldersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose folders, exclusions, rescan'**
  String get settingsMusicFoldersSubtitle;

  /// No description provided for @settingsAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio & Effects'**
  String get settingsAudio;

  /// No description provided for @settingsAudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Equalizer, fades, volume normalization'**
  String get settingsAudioSubtitle;

  /// No description provided for @settingsGestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures & Haptics'**
  String get settingsGestures;

  /// No description provided for @settingsGesturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipes, double-tap, long-press, vibration'**
  String get settingsGesturesSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language & Numerals'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic / English, RTL, numeral style'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup, Cache & Stats'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'JSON backup, Wetar Wrapped, cache, logs'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Wetar'**
  String get settingsAbout;

  /// No description provided for @settingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// No description provided for @personalizationLooks.
  ///
  /// In en, this message translates to:
  /// **'Looks'**
  String get personalizationLooks;

  /// No description provided for @personalizationColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get personalizationColors;

  /// No description provided for @personalizationFonts.
  ///
  /// In en, this message translates to:
  /// **'Typography & Fonts'**
  String get personalizationFonts;

  /// No description provided for @personalizationPlayer.
  ///
  /// In en, this message translates to:
  /// **'Now Playing & Mini Player'**
  String get personalizationPlayer;

  /// No description provided for @personalizationBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get personalizationBackgrounds;

  /// No description provided for @personalizationLayout.
  ///
  /// In en, this message translates to:
  /// **'Home & Library Layout'**
  String get personalizationLayout;

  /// No description provided for @personalizationMotion.
  ///
  /// In en, this message translates to:
  /// **'Shape, Depth & Motion'**
  String get personalizationMotion;

  /// No description provided for @personalizationLiteMode.
  ///
  /// In en, this message translates to:
  /// **'Lite Mode'**
  String get personalizationLiteMode;

  /// No description provided for @personalizationLiteModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic (Battery Saver / Reduce Motion)'**
  String get personalizationLiteModeAuto;

  /// No description provided for @personalizationLiteModeOn.
  ///
  /// In en, this message translates to:
  /// **'Always On'**
  String get personalizationLiteModeOn;

  /// No description provided for @personalizationLiteModeOff.
  ///
  /// In en, this message translates to:
  /// **'Always Off'**
  String get personalizationLiteModeOff;

  /// No description provided for @personalizationThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get personalizationThemeMode;

  /// No description provided for @personalizationThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get personalizationThemeSystem;

  /// No description provided for @personalizationThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get personalizationThemeLight;

  /// No description provided for @personalizationThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get personalizationThemeDark;

  /// No description provided for @personalizationThemeAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED Black'**
  String get personalizationThemeAmoled;

  /// No description provided for @personalizationScheduledDark.
  ///
  /// In en, this message translates to:
  /// **'Scheduled dark mode'**
  String get personalizationScheduledDark;

  /// No description provided for @personalizationAdaptArtwork.
  ///
  /// In en, this message translates to:
  /// **'Adapt colors to current artwork'**
  String get personalizationAdaptArtwork;

  /// No description provided for @personalizationSystemDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Use system dynamic colors'**
  String get personalizationSystemDynamicColor;

  /// No description provided for @personalizationCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Custom accent color'**
  String get personalizationCustomColor;

  /// No description provided for @personalizationContrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast level'**
  String get personalizationContrast;

  /// No description provided for @personalizationContrastStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get personalizationContrastStandard;

  /// No description provided for @personalizationContrastMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get personalizationContrastMedium;

  /// No description provided for @personalizationContrastHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get personalizationContrastHigh;

  /// No description provided for @personalizationSurfaceTint.
  ///
  /// In en, this message translates to:
  /// **'Surface tint'**
  String get personalizationSurfaceTint;

  /// No description provided for @personalizationTextEmphasis.
  ///
  /// In en, this message translates to:
  /// **'Text emphasis'**
  String get personalizationTextEmphasis;

  /// No description provided for @personalizationFontArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic font'**
  String get personalizationFontArabic;

  /// No description provided for @personalizationFontLatin.
  ///
  /// In en, this message translates to:
  /// **'Latin font'**
  String get personalizationFontLatin;

  /// No description provided for @personalizationFontSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get personalizationFontSystem;

  /// No description provided for @personalizationFontScale.
  ///
  /// In en, this message translates to:
  /// **'Font size scale'**
  String get personalizationFontScale;

  /// No description provided for @personalizationFontWeight.
  ///
  /// In en, this message translates to:
  /// **'Font weight'**
  String get personalizationFontWeight;

  /// No description provided for @personalizationImportFont.
  ///
  /// In en, this message translates to:
  /// **'Import .ttf / .otf font'**
  String get personalizationImportFont;

  /// No description provided for @personalizationFontImported.
  ///
  /// In en, this message translates to:
  /// **'Imported font: {name}'**
  String personalizationFontImported(String name);

  /// No description provided for @personalizationFontInvalid.
  ///
  /// In en, this message translates to:
  /// **'Unsupported or invalid font file'**
  String get personalizationFontInvalid;

  /// No description provided for @personalizationPlayerLayout.
  ///
  /// In en, this message translates to:
  /// **'Player layout'**
  String get personalizationPlayerLayout;

  /// No description provided for @personalizationLayoutOudStrings.
  ///
  /// In en, this message translates to:
  /// **'Oud Strings (Signature)'**
  String get personalizationLayoutOudStrings;

  /// No description provided for @personalizationLayoutClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Card'**
  String get personalizationLayoutClassic;

  /// No description provided for @personalizationLayoutImmersive.
  ///
  /// In en, this message translates to:
  /// **'Immersive Bleed'**
  String get personalizationLayoutImmersive;

  /// No description provided for @personalizationLayoutMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get personalizationLayoutMinimal;

  /// No description provided for @personalizationLayoutVinyl.
  ///
  /// In en, this message translates to:
  /// **'Vinyl Disc'**
  String get personalizationLayoutVinyl;

  /// No description provided for @personalizationArtShape.
  ///
  /// In en, this message translates to:
  /// **'Artwork shape'**
  String get personalizationArtShape;

  /// No description provided for @personalizationArtRoundedSquare.
  ///
  /// In en, this message translates to:
  /// **'Rounded Square'**
  String get personalizationArtRoundedSquare;

  /// No description provided for @personalizationArtSquircle.
  ///
  /// In en, this message translates to:
  /// **'Squircle'**
  String get personalizationArtSquircle;

  /// No description provided for @personalizationArtCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get personalizationArtCircle;

  /// No description provided for @personalizationSeekBarStyle.
  ///
  /// In en, this message translates to:
  /// **'Seek bar style'**
  String get personalizationSeekBarStyle;

  /// No description provided for @personalizationSeekStringWaveform.
  ///
  /// In en, this message translates to:
  /// **'Oud String Waveform'**
  String get personalizationSeekStringWaveform;

  /// No description provided for @personalizationSeekStylizedBars.
  ///
  /// In en, this message translates to:
  /// **'Stylized Bars'**
  String get personalizationSeekStylizedBars;

  /// No description provided for @personalizationSeekThinLine.
  ///
  /// In en, this message translates to:
  /// **'Thin Line'**
  String get personalizationSeekThinLine;

  /// No description provided for @personalizationSeekThickPill.
  ///
  /// In en, this message translates to:
  /// **'Thick Pill'**
  String get personalizationSeekThickPill;

  /// No description provided for @personalizationMiniPlayerStyle.
  ///
  /// In en, this message translates to:
  /// **'Mini player style'**
  String get personalizationMiniPlayerStyle;

  /// No description provided for @personalizationMiniPlayerFloating.
  ///
  /// In en, this message translates to:
  /// **'Floating pill'**
  String get personalizationMiniPlayerFloating;

  /// No description provided for @personalizationMiniPlayerDocked.
  ///
  /// In en, this message translates to:
  /// **'Docked bar'**
  String get personalizationMiniPlayerDocked;

  /// No description provided for @personalizationBackgroundMode.
  ///
  /// In en, this message translates to:
  /// **'Background style'**
  String get personalizationBackgroundMode;

  /// No description provided for @personalizationBgBlurredArt.
  ///
  /// In en, this message translates to:
  /// **'Blurred artwork'**
  String get personalizationBgBlurredArt;

  /// No description provided for @personalizationBgArtGradient.
  ///
  /// In en, this message translates to:
  /// **'Artwork gradient'**
  String get personalizationBgArtGradient;

  /// No description provided for @personalizationBgSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid color'**
  String get personalizationBgSolid;

  /// No description provided for @personalizationBgAnimatedGradient.
  ///
  /// In en, this message translates to:
  /// **'Animated gradient'**
  String get personalizationBgAnimatedGradient;

  /// No description provided for @personalizationBgProceduralAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora (procedural)'**
  String get personalizationBgProceduralAurora;

  /// No description provided for @personalizationBgProceduralWaves.
  ///
  /// In en, this message translates to:
  /// **'Waves (procedural)'**
  String get personalizationBgProceduralWaves;

  /// No description provided for @personalizationBgProceduralGrain.
  ///
  /// In en, this message translates to:
  /// **'Warm grain (procedural)'**
  String get personalizationBgProceduralGrain;

  /// No description provided for @personalizationBgProceduralStrings.
  ///
  /// In en, this message translates to:
  /// **'Oud strings (procedural)'**
  String get personalizationBgProceduralStrings;

  /// No description provided for @personalizationBgCustomImage.
  ///
  /// In en, this message translates to:
  /// **'Custom image'**
  String get personalizationBgCustomImage;

  /// No description provided for @personalizationBgBlur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get personalizationBgBlur;

  /// No description provided for @personalizationBgDim.
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get personalizationBgDim;

  /// No description provided for @personalizationBgSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get personalizationBgSaturation;

  /// No description provided for @personalizationBgScope.
  ///
  /// In en, this message translates to:
  /// **'Apply background to'**
  String get personalizationBgScope;

  /// No description provided for @personalizationBgScopePlayer.
  ///
  /// In en, this message translates to:
  /// **'Player only'**
  String get personalizationBgScopePlayer;

  /// No description provided for @personalizationBgScopeHomePlayer.
  ///
  /// In en, this message translates to:
  /// **'Home & Player'**
  String get personalizationBgScopeHomePlayer;

  /// No description provided for @personalizationBgScopeWholeApp.
  ///
  /// In en, this message translates to:
  /// **'Whole app'**
  String get personalizationBgScopeWholeApp;

  /// No description provided for @personalizationCornerRadius.
  ///
  /// In en, this message translates to:
  /// **'Corner radius'**
  String get personalizationCornerRadius;

  /// No description provided for @personalizationShadowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Shadow depth'**
  String get personalizationShadowIntensity;

  /// No description provided for @personalizationBlurIntensity.
  ///
  /// In en, this message translates to:
  /// **'Glass blur'**
  String get personalizationBlurIntensity;

  /// No description provided for @personalizationMotionIntensity.
  ///
  /// In en, this message translates to:
  /// **'Animation intensity'**
  String get personalizationMotionIntensity;

  /// No description provided for @personalizationMotionOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get personalizationMotionOff;

  /// No description provided for @personalizationMotionReduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get personalizationMotionReduced;

  /// No description provided for @personalizationMotionBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get personalizationMotionBalanced;

  /// No description provided for @personalizationMotionExpressive.
  ///
  /// In en, this message translates to:
  /// **'Expressive'**
  String get personalizationMotionExpressive;

  /// No description provided for @personalizationHapticsIntensity.
  ///
  /// In en, this message translates to:
  /// **'Haptic intensity'**
  String get personalizationHapticsIntensity;

  /// No description provided for @personalizationHapticsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get personalizationHapticsOff;

  /// No description provided for @personalizationHapticsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get personalizationHapticsLight;

  /// No description provided for @personalizationHapticsMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get personalizationHapticsMedium;

  /// No description provided for @personalizationHapticsStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get personalizationHapticsStrong;

  /// No description provided for @personalizationListDensity.
  ///
  /// In en, this message translates to:
  /// **'List density'**
  String get personalizationListDensity;

  /// No description provided for @personalizationDensityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get personalizationDensityCompact;

  /// No description provided for @personalizationDensityComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get personalizationDensityComfortable;

  /// No description provided for @personalizationDensitySpacious.
  ///
  /// In en, this message translates to:
  /// **'Spacious'**
  String get personalizationDensitySpacious;

  /// No description provided for @personalizationGridColumns.
  ///
  /// In en, this message translates to:
  /// **'Grid columns'**
  String get personalizationGridColumns;

  /// No description provided for @personalizationShowArtInLists.
  ///
  /// In en, this message translates to:
  /// **'Show artwork in lists'**
  String get personalizationShowArtInLists;

  /// No description provided for @personalizationMirrorTimelineRtl.
  ///
  /// In en, this message translates to:
  /// **'Mirror seek bar in Arabic RTL'**
  String get personalizationMirrorTimelineRtl;

  /// No description provided for @personalizationSaveLook.
  ///
  /// In en, this message translates to:
  /// **'Save current look'**
  String get personalizationSaveLook;

  /// No description provided for @personalizationImportLook.
  ///
  /// In en, this message translates to:
  /// **'Import .wetarlook'**
  String get personalizationImportLook;

  /// No description provided for @personalizationExportLook.
  ///
  /// In en, this message translates to:
  /// **'Export .wetarlook'**
  String get personalizationExportLook;

  /// No description provided for @personalizationLookInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or corrupted .wetarlook file'**
  String get personalizationLookInvalid;

  /// No description provided for @personalizationResetSection.
  ///
  /// In en, this message translates to:
  /// **'Reset this section'**
  String get personalizationResetSection;

  /// No description provided for @personalizationResetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all appearance settings?'**
  String get personalizationResetAllTitle;

  /// No description provided for @personalizationResetAllBody.
  ///
  /// In en, this message translates to:
  /// **'This restores Wetar\'s default colors, fonts, layout, and gestures.'**
  String get personalizationResetAllBody;

  /// No description provided for @playbackMinDuration.
  ///
  /// In en, this message translates to:
  /// **'Hide tracks shorter than ({seconds}s)'**
  String playbackMinDuration(int seconds);

  /// No description provided for @playbackArtistSeparators.
  ///
  /// In en, this message translates to:
  /// **'Multi-artist separators'**
  String get playbackArtistSeparators;

  /// No description provided for @playbackFadePlayPause.
  ///
  /// In en, this message translates to:
  /// **'Smooth volume fade on play/pause'**
  String get playbackFadePlayPause;

  /// No description provided for @playbackSkipSilence.
  ///
  /// In en, this message translates to:
  /// **'Skip silence'**
  String get playbackSkipSilence;

  /// No description provided for @playbackReplayGainMode.
  ///
  /// In en, this message translates to:
  /// **'ReplayGain normalization'**
  String get playbackReplayGainMode;

  /// No description provided for @playbackReplayGainOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get playbackReplayGainOff;

  /// No description provided for @playbackReplayGainTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get playbackReplayGainTrack;

  /// No description provided for @playbackReplayGainAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get playbackReplayGainAlbum;

  /// No description provided for @playbackReplayGainPreamp.
  ///
  /// In en, this message translates to:
  /// **'Pre-amp gain'**
  String get playbackReplayGainPreamp;

  /// No description provided for @playbackRememberLongPos.
  ///
  /// In en, this message translates to:
  /// **'Remember position for long tracks (>=15 min)'**
  String get playbackRememberLongPos;

  /// No description provided for @playbackAutoPlayBt.
  ///
  /// In en, this message translates to:
  /// **'Auto-play when headphones/Bluetooth connect'**
  String get playbackAutoPlayBt;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageNumerals.
  ///
  /// In en, this message translates to:
  /// **'Numerals style'**
  String get languageNumerals;

  /// No description provided for @languageNumeralsWestern.
  ///
  /// In en, this message translates to:
  /// **'Western (0123)'**
  String get languageNumeralsWestern;

  /// No description provided for @languageNumeralsArabicIndic.
  ///
  /// In en, this message translates to:
  /// **'Arabic-Indic (٠١٢٣)'**
  String get languageNumeralsArabicIndic;

  /// No description provided for @backupExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export full local backup (.json)'**
  String get backupExportJson;

  /// No description provided for @backupImportJson.
  ///
  /// In en, this message translates to:
  /// **'Restore local backup (.json)'**
  String get backupImportJson;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved successfully'**
  String get backupSuccess;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored cleanly'**
  String get backupRestored;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'Could not validate backup file'**
  String get backupInvalid;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening Recap (Wetar Wrapped)'**
  String get statsTitle;

  /// No description provided for @statsTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total listening time'**
  String get statsTotalTime;

  /// No description provided for @statsTotalPlays.
  ///
  /// In en, this message translates to:
  /// **'Total plays'**
  String get statsTotalPlays;

  /// No description provided for @statsTopTracks.
  ///
  /// In en, this message translates to:
  /// **'Top tracks'**
  String get statsTopTracks;

  /// No description provided for @statsTopArtists.
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get statsTopArtists;

  /// No description provided for @statsSharePoster.
  ///
  /// In en, this message translates to:
  /// **'Share Wrapped card'**
  String get statsSharePoster;

  /// No description provided for @cacheClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear app caches'**
  String get cacheClearButton;

  /// No description provided for @cacheSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cache usage: {size}'**
  String cacheSizeLabel(String size);

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Diagnostics & Logs'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsShare.
  ///
  /// In en, this message translates to:
  /// **'Share local log file'**
  String get diagnosticsShare;

  /// No description provided for @diagnosticsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear log file'**
  String get diagnosticsClear;

  /// No description provided for @batteryGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep background music uninterrupted'**
  String get batteryGuideTitle;

  /// No description provided for @batteryGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Some Android brands aggressively stop background audio. Set Wetar to Unrestricted battery usage if playback pauses when the screen turns off.'**
  String get batteryGuideBody;

  /// No description provided for @batteryGuideAction.
  ///
  /// In en, this message translates to:
  /// **'Open battery exemption settings'**
  String get batteryGuideAction;

  /// No description provided for @batteryGuideOptimizedOk.
  ///
  /// In en, this message translates to:
  /// **'Battery exemption is already active'**
  String get batteryGuideOptimizedOk;

  /// No description provided for @desktopCompactMiniMode.
  ///
  /// In en, this message translates to:
  /// **'Compact mini player'**
  String get desktopCompactMiniMode;

  /// No description provided for @desktopMenuLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get desktopMenuLibrary;

  /// No description provided for @desktopMenuPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get desktopMenuPlayback;

  /// No description provided for @desktopMenuView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get desktopMenuView;

  /// No description provided for @desktopShortcutsHint.
  ///
  /// In en, this message translates to:
  /// **'Space: Play/Pause • Arrows: Seek • Cmd+F: Search'**
  String get desktopShortcutsHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
