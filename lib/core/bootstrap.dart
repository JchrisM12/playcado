import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/core/app_bloc_observer.dart';
import 'package:playcado/media/data/jellyfin_remote_data_source.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/media/repos/playback_repository.dart';
import 'package:playcado/search/repos/search_repository.dart';
import 'package:playcado/services/jellyfin_client_service.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/services/media_url/jellyfin_url_service.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/services/preferences_service.dart';
import 'package:playcado/services/secure_storage_service.dart';
import 'package:playcado/video_player/services/player_service.dart';

/// Configuration data returned from bootstrap initialization
class BootstrapConfig {
  final JellyfinClientService jellyfinClientService;
  final AuthRepository authRepository;
  final LibraryRepository libraryRepository;
  final PlaybackRepository playbackRepository;
  final SearchRepository searchRepository;
  final MediaUrlService mediaUrlService;
  final CastService castService;
  final PlayerService playerService;
  final PreferencesService preferencesService;
  final SecureStorageService secureStorageService;
  final bool isFirstRun;
  final User? initialUser;
  final Color? initialThemeColor;

  const BootstrapConfig({
    required this.jellyfinClientService,
    required this.authRepository,
    required this.libraryRepository,
    required this.playbackRepository,
    required this.searchRepository,
    required this.mediaUrlService,
    required this.castService,
    required this.playerService,
    required this.preferencesService,
    required this.secureStorageService,
    required this.isFirstRun,
    this.initialUser,
    this.initialThemeColor,
  });
}

/// Bootstrap the application by initializing all required services and dependencies
Future<BootstrapConfig> bootstrap() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit for video playback
  MediaKit.ensureInitialized();

  // Initialize logging service
  LoggerService.initializeLogging();
  LoggerService.system.info('App Starting...');

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Configure system UI
  await _configureSystemUI();

  // Initialize core services and repositories
  final jellyfinClientService = JellyfinClientService();
  final secureStorage = SecureStorageService();
  final authRepository = AuthRepository(
    jellyfinClient: jellyfinClientService,
    secureStorage: secureStorage,
  );
  final remoteDataSource = JellyfinRemoteDataSource(
    clientManager: jellyfinClientService,
  );

  final mediaUrlService = JellyfinUrlService(jellyfinClientService);

  final libraryRepository = LibraryRepository(dataSource: remoteDataSource);
  final playbackRepository = PlaybackRepository(
    dataSource: remoteDataSource,
    urlGenerator: mediaUrlService,
  );
  final searchRepository = SearchRepository(dataSource: remoteDataSource);

  final castService = CastService();
  final playerService = PlayerService();
  final preferencesService = PreferencesService();

  // Initialize Cast service early
  await castService.initialize();

  // Load app preferences
  final isFirstRun = await preferencesService.isFirstRun();
  final savedThemeColor = await preferencesService.getThemeColor();

  // Attempt auto-login if not first run
  final initialUser = await _attemptAutoLogin(
    isFirstRun: isFirstRun,
    authRepository: authRepository,
    jellyfinClientService: jellyfinClientService,
  );

  return BootstrapConfig(
    jellyfinClientService: jellyfinClientService,
    authRepository: authRepository,
    libraryRepository: libraryRepository,
    playbackRepository: playbackRepository,
    searchRepository: searchRepository,
    mediaUrlService: mediaUrlService,
    castService: castService,
    playerService: playerService,
    preferencesService: preferencesService,
    secureStorageService: secureStorage,
    isFirstRun: isFirstRun,
    initialUser: initialUser,
    initialThemeColor: savedThemeColor,
  );
}

/// Configure system UI settings
Future<void> _configureSystemUI() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

/// Attempt to auto-login the user if not first run
/// Returns the initial user if successful, null otherwise
Future<User?> _attemptAutoLogin({
  required bool isFirstRun,
  required AuthRepository authRepository,
  required JellyfinClientService jellyfinClientService,
}) async {
  // Skip auto-login on first run
  if (isFirstRun) {
    return null;
  }

  try {
    final user = await authRepository.tryAutoLogin();
    if (user == null) return null;
    LoggerService.auth.info('Auto-login pre-check successful for ${user.name}');
    return user;
  } catch (e, s) {
    LoggerService.auth.warning('Pre-run auto-login check failed', e, s);
    // Ensure we start clean if auto-login failed partially
    await authRepository.logout();
    return null;
  }
}
