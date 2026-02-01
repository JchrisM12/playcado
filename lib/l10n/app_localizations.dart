import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @aToZ.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get aToZ;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @addedToCastQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to cast queue'**
  String get addedToCastQueue;

  /// No description provided for @alphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get alphabetical;

  /// No description provided for @appThemeColor.
  ///
  /// In en, this message translates to:
  /// **'App Theme Color'**
  String get appThemeColor;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @areYouSureYouWantToStopCasting.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop casting this media?'**
  String get areYouSureYouWantToStopCasting;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @audioAndSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Audio & subtitles'**
  String get audioAndSubtitles;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @availableDevices.
  ///
  /// In en, this message translates to:
  /// **'Available devices'**
  String get availableDevices;

  /// No description provided for @avocado.
  ///
  /// In en, this message translates to:
  /// **'Avocado'**
  String get avocado;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @blueGrey.
  ///
  /// In en, this message translates to:
  /// **'Blue grey'**
  String get blueGrey;

  /// No description provided for @browseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Browse Library'**
  String get browseLibrary;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// No description provided for @castManagement.
  ///
  /// In en, this message translates to:
  /// **'Cast management'**
  String get castManagement;

  /// No description provided for @casting.
  ///
  /// In en, this message translates to:
  /// **'Casting...'**
  String get casting;

  /// No description provided for @castingToDevice.
  ///
  /// In en, this message translates to:
  /// **'Casting to device'**
  String get castingToDevice;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @connectToYourServerToDownloadContent.
  ///
  /// In en, this message translates to:
  /// **'Connect to your server to download content for offline viewing.'**
  String get connectToYourServerToDownloadContent;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {deviceName}'**
  String connectedTo(String deviceName);

  /// No description provided for @connectingTo.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {deviceName}...'**
  String connectingTo(String deviceName);

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @continueWatching.
  ///
  /// In en, this message translates to:
  /// **'Continue Watching'**
  String get continueWatching;

  /// No description provided for @creativeCommonsContent.
  ///
  /// In en, this message translates to:
  /// **'Creative Commons Content'**
  String get creativeCommonsContent;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @dateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get dateAdded;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

  /// No description provided for @deepOrange.
  ///
  /// In en, this message translates to:
  /// **'Deep orange'**
  String get deepOrange;

  /// No description provided for @deepPurple.
  ///
  /// In en, this message translates to:
  /// **'Deep purple'**
  String get deepPurple;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteDownload.
  ///
  /// In en, this message translates to:
  /// **'Delete download'**
  String get deleteDownload;

  /// No description provided for @deletedItem.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String deletedItem(String name);

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode'**
  String get demoMode;

  /// No description provided for @devTools.
  ///
  /// In en, this message translates to:
  /// **'Dev Tools'**
  String get devTools;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled'**
  String get downloadCancelled;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @downloadSeason.
  ///
  /// In en, this message translates to:
  /// **'Download {seasonName}'**
  String downloadSeason(String seasonName);

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started'**
  String get downloadStarted;

  /// No description provided for @downloadedContentIsAvailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Downloaded content is available offline.'**
  String get downloadedContentIsAvailableOffline;

  /// No description provided for @downloadedContentOnly.
  ///
  /// In en, this message translates to:
  /// **'Downloaded content only'**
  String get downloadedContentOnly;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @downloadingEpisode.
  ///
  /// In en, this message translates to:
  /// **'Downloading episode...'**
  String get downloadingEpisode;

  /// No description provided for @downloadingSeason.
  ///
  /// In en, this message translates to:
  /// **'Downloading season...'**
  String get downloadingSeason;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @errorLoadingSeasons.
  ///
  /// In en, this message translates to:
  /// **'Error loading seasons'**
  String get errorLoadingSeasons;

  /// No description provided for @exitDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Demo Mode'**
  String get exitDemoMode;

  /// No description provided for @exitOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Offline Mode'**
  String get exitOfflineMode;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @failedToCastMedia.
  ///
  /// In en, this message translates to:
  /// **'Failed to cast media'**
  String get failedToCastMedia;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @indigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get indigo;

  /// No description provided for @lightBlue.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get lightBlue;

  /// No description provided for @localNetworkAccess.
  ///
  /// In en, this message translates to:
  /// **'Local Network Access'**
  String get localNetworkAccess;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailedPleaseCheckYourCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials and network connection.'**
  String get loginFailedPleaseCheckYourCredentials;

  /// No description provided for @manageServers.
  ///
  /// In en, this message translates to:
  /// **'Manage Servers'**
  String get manageServers;

  /// No description provided for @mediaType.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaType;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// No description provided for @moviesAndEpisodesYouDownloadWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Movies and episodes you download will appear here.'**
  String get moviesAndEpisodesYouDownloadWillAppearHere;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noActiveDownloads.
  ///
  /// In en, this message translates to:
  /// **'No active downloads'**
  String get noActiveDownloads;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @noEpisodesFound.
  ///
  /// In en, this message translates to:
  /// **'No episodes found'**
  String get noEpisodesFound;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No {items} found.'**
  String noItemsFound(String items);

  /// No description provided for @noOfflineContent.
  ///
  /// In en, this message translates to:
  /// **'No offline content'**
  String get noOfflineContent;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noTracksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tracks available'**
  String get noTracksAvailable;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @offlineDownloads.
  ///
  /// In en, this message translates to:
  /// **'Offline Downloads'**
  String get offlineDownloads;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @orAddNewServer.
  ///
  /// In en, this message translates to:
  /// **'Or add new server'**
  String get orAddNewServer;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playOffline.
  ///
  /// In en, this message translates to:
  /// **'Play Offline'**
  String get playOffline;

  /// No description provided for @playcado.
  ///
  /// In en, this message translates to:
  /// **'Playcado'**
  String get playcado;

  /// No description provided for @pleaseCheckYourConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get pleaseCheckYourConnectionAndTryAgain;

  /// No description provided for @premiereDate.
  ///
  /// In en, this message translates to:
  /// **'Premiere Date'**
  String get premiereDate;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Queued...'**
  String get queued;

  /// No description provided for @recentlyAddedMovies.
  ///
  /// In en, this message translates to:
  /// **'Recently Added Movies'**
  String get recentlyAddedMovies;

  /// No description provided for @recentlyAddedTv.
  ///
  /// In en, this message translates to:
  /// **'Recently Added TV'**
  String get recentlyAddedTv;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @releaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// No description provided for @rememberCredentials.
  ///
  /// In en, this message translates to:
  /// **'Remember credentials'**
  String get rememberCredentials;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @savedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Saved Accounts'**
  String get savedAccounts;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search movies, tv, episodes...'**
  String get searchPlaceholder;

  /// No description provided for @searchingForDevices.
  ///
  /// In en, this message translates to:
  /// **'Searching for devices...'**
  String get searchingForDevices;

  /// No description provided for @selectAColorToCustomizeTheAppsLookAndFeel.
  ///
  /// In en, this message translates to:
  /// **'Select a color to customize the app\'s look and feel.'**
  String get selectAColorToCustomizeTheAppsLookAndFeel;

  /// No description provided for @selectADevice.
  ///
  /// In en, this message translates to:
  /// **'Select a Device'**
  String get selectADevice;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL (http://...)'**
  String get serverUrlLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @skipIntro.
  ///
  /// In en, this message translates to:
  /// **'Skip Intro'**
  String get skipIntro;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort {title}'**
  String sortTitle(String title);

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopCasting.
  ///
  /// In en, this message translates to:
  /// **'Stop casting'**
  String get stopCasting;

  /// No description provided for @stopCastingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Stop Casting?'**
  String get stopCastingQuestion;

  /// No description provided for @subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// No description provided for @teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @toCastMoviesAndShowsToYourTv.
  ///
  /// In en, this message translates to:
  /// **'To cast movies and shows to your TV (Chromecast/Google Cast), Playcado needs permission to discover devices on your local network.'**
  String get toCastMoviesAndShowsToYourTv;

  /// No description provided for @tv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get tv;

  /// No description provided for @tvShows.
  ///
  /// In en, this message translates to:
  /// **'TV Shows'**
  String get tvShows;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search your library'**
  String get typeToSearch;

  /// No description provided for @unableToLoadContent.
  ///
  /// In en, this message translates to:
  /// **'Unable to load content'**
  String get unableToLoadContent;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unwatched.
  ///
  /// In en, this message translates to:
  /// **'Unwatched'**
  String get unwatched;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNext;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @viewOfflineDownloads.
  ///
  /// In en, this message translates to:
  /// **'View offline downloads'**
  String get viewOfflineDownloads;

  /// No description provided for @watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// No description provided for @weDoNotAccessYourPersonalData.
  ///
  /// In en, this message translates to:
  /// **'We do not access your personal data or track your browsing history.'**
  String get weDoNotAccessYourPersonalData;

  /// No description provided for @welcomeToPlaycado.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Playcado'**
  String get welcomeToPlaycado;

  /// No description provided for @yourModernLightweightClient.
  ///
  /// In en, this message translates to:
  /// **'Your modern, lightweight client for Jellyfin media servers.'**
  String get yourModernLightweightClient;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
