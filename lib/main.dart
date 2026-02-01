import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/core/app_flavor.dart';
import 'package:playcado/core/bootstrap.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/core/secrets.dart';
import 'package:playcado/downloads/bloc/downloads_bloc.dart';
import 'package:playcado/downloads_repository/downloads_repository.dart';
import 'package:playcado/l10n/app_localizations.dart';
import 'package:playcado/libraries/bloc/libraries_bloc.dart';
import 'package:playcado/media/data/demo_remote_data_source.dart';
import 'package:playcado/media/data/jellyfin_remote_data_source.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/media/repos/playback_repository.dart';
import 'package:playcado/onboarding/bloc/onboarding_cubit.dart';
import 'package:playcado/search/repos/search_repository.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/services/media_url/demo_url_service.dart';
import 'package:playcado/services/media_url/jellyfin_url_service.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/services/preferences_service.dart';
import 'package:playcado/services/secure_storage_service.dart';
import 'package:playcado/theme/app_theme.dart';
import 'package:playcado/theme/bloc/theme_bloc.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/video_player/services/player_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  // Initialize all services and dependencies
  final config = await bootstrap();
  final myApp = MyApp(config: config);

  final shouldInitializeSentry = !AppFlavor.isDev && Secrets.isSentryEnabled;

  if (shouldInitializeSentry) {
    LoggerService.system.info('Starting app with Sentry');
    await SentryFlutter.init((options) {
      options.dsn = Secrets.sentryDsn;
      options.sendDefaultPii = true;
      options.enableLogs = true;
      options.tracesSampleRate = 1.0;
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    }, appRunner: () => runApp(SentryWidget(child: myApp)));
  } else {
    if (AppFlavor.isDev) {
      LoggerService.system.info('Sentry disabled: Running in development mode');
    } else if (!Secrets.isSentryEnabled) {
      LoggerService.system.warning(
        'Sentry disabled: SENTRY_DSN not provided in environment',
      );
    }
    runApp(myApp);
  }
}

class MyApp extends StatelessWidget {
  final BootstrapConfig config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PreferencesService>.value(
          value: config.preferencesService,
        ),
        RepositoryProvider<AuthRepository>.value(value: config.authRepository),
        RepositoryProvider<CastService>.value(value: config.castService),
        RepositoryProvider<PlayerService>.value(value: config.playerService),
        RepositoryProvider<SecureStorageService>.value(
          value: config.secureStorageService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => OnboardingCubit(
              preferencesService: config.preferencesService,
              isFirstRun: config.isFirstRun,
            ),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(
              preferencesService: config.preferencesService,
              initialColor: config.initialThemeColor,
            ),
          ),
          BlocProvider(
            create: (context) {
              // AuthBloc is initialized with the pre-fetched user.
              // This ensures the Router sees state.user.isSuccess immediately.
              return AuthBloc(
                authRepository: context.read<AuthRepository>(),
                initialUser: config.initialUser,
              );
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) =>
              previous.isDemoMode != current.isDemoMode ||
              previous.user.value?.id != current.user.value?.id,
          builder: (context, state) {
            final mediaUrlService = state.isDemoMode
                ? DemoUrlService()
                : JellyfinUrlService(config.jellyfinClientService);

            final remoteDataSource = state.isDemoMode
                ? DemoRemoteDataSource()
                : JellyfinRemoteDataSource(
                    clientManager: config.jellyfinClientService,
                  );

            return MultiRepositoryProvider(
              // The key includes the user ID to ensure all media blocs/repos are
              // reset and re-fetched when a new user logs in.
              key: ValueKey('${state.isDemoMode}_${state.user.value?.id}'),
              providers: [
                RepositoryProvider<LibraryRepository>(
                  create: (context) =>
                      LibraryRepository(dataSource: remoteDataSource),
                ),
                RepositoryProvider<PlaybackRepository>(
                  create: (context) => PlaybackRepository(
                    dataSource: remoteDataSource,
                    urlGenerator: mediaUrlService,
                  ),
                ),
                RepositoryProvider<SearchRepository>(
                  create: (context) =>
                      SearchRepository(dataSource: remoteDataSource),
                ),
                RepositoryProvider<DownloadsRepository>(
                  create: (context) =>
                      DownloadsRepository(urlGenerator: mediaUrlService),
                  dispose: (repo) => repo.dispose(),
                ),
                RepositoryProvider<MediaUrlService>.value(
                  value: mediaUrlService,
                ),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => DownloadsBloc(
                      repository: context.read<DownloadsRepository>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => VideoPlayerBloc(
                      playbackRepository: context.read<PlaybackRepository>(),
                      urlGenerator: context.read<MediaUrlService>(),
                      playerService: context.read<PlayerService>(),
                      castService: context.read<CastService>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => LibrariesBloc(
                      libraryRepository: context.read<LibraryRepository>(),
                    )..add(LibrariesLibariesFetched()),
                  ),
                ],
                child: PlaycadoApp(
                  preferencesService: config.preferencesService,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PlaycadoApp extends StatefulWidget {
  final PreferencesService preferencesService;

  const PlaycadoApp({super.key, required this.preferencesService});

  @override
  State<PlaycadoApp> createState() => _PlaycadoAppState();
}

class _PlaycadoAppState extends State<PlaycadoApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      authBloc: context.read<AuthBloc>(),
      onboardingCubit: context.read<OnboardingCubit>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.playcado,
          theme: AppTheme.light(seedColor: state.themeColor),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          darkTheme: AppTheme.dark(seedColor: state.themeColor),
          themeMode: ThemeMode.dark,
          routerConfig: _appRouter.router,
        );
      },
    );
  }
}
