import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/main_navigation_shell.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';

import 'package:playcado/devtools/views/dev_tools_screen.dart';
import 'package:playcado/downloads/views/downloads_screen.dart';
import 'package:playcado/home/views/home_screen.dart';
import 'package:playcado/libraries/views/library_browse_screen.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/media_details/views/media_details_screen.dart';
import 'package:playcado/movies/views/movies_screen.dart';
import 'package:playcado/onboarding/bloc/onboarding_cubit.dart';
import 'package:playcado/onboarding/views/onboarding_screen.dart';
import 'package:playcado/search/views/search_screen.dart';
import 'package:playcado/server_management/views/server_management_screen.dart';
import 'package:playcado/settings/views/settings_screen.dart';
import 'package:playcado/tv/views/tv_shows_screen.dart';
import 'package:playcado/video_player/views/fullscreen_player_screen.dart';

class AppRouter {
  final AuthBloc authBloc;
  final OnboardingCubit onboardingCubit;

  static const basePath = '/';
  static const serverManagementPath = '/server_management';
  static const onboardingPath = '/onboarding';
  static const moviesPath = '/movies';
  static const tvPath = '/tv';
  static const downloadsPath = '/downloads';
  static const devtoolsPath = '/devtools';
  static const detailsPath = '/details';
  static const settingsPath = '/settings';
  static const videoPlayerPath = '/player';
  static const searchPath = '/search';
  static const libraryPath = '/library';

  AppRouter({required this.authBloc, required this.onboardingCubit});

  late final GoRouter router = GoRouter(
    initialLocation: basePath,
    refreshListenable: Listenable.merge([
      _GoRouterRefreshStream(authBloc.stream),
      _GoRouterRefreshStream(onboardingCubit.stream),
    ]),
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: moviesPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MoviesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: tvPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TvShowsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: basePath,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: downloadsPath,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DownloadsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: searchPath,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SearchScreen()),
      ),
      GoRoute(
        path: detailsPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final item = extra['item'] as MediaItem;
          final heroTag = extra['heroTag'] as String;
          return MediaDetailsScreen(item: item, heroTag: heroTag);
        },
      ),
      GoRoute(
        path: serverManagementPath,
        builder: (context, state) => const ServerManagementScreen(),
      ),
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: settingsPath,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SettingsScreen()),
      ),
      GoRoute(
        path: devtoolsPath,
        builder: (context, state) => const DevToolsScreen(),
      ),
      GoRoute(
        path: videoPlayerPath,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const FullscreenPlayerScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: libraryPath,
        builder: (context, state) {
          final item = state.extra as MediaItem;
          return LibraryBrowseScreen(library: item);
        },
      ),
    ],
    redirect: (context, state) {
      final isFirstRun = onboardingCubit.state;
      final authState = authBloc.state;
      final isLoggedIn = authState.user.isSuccess;
      final isOfflineMode = authState.isOfflineMode;

      final isGoingToOnboarding = state.matchedLocation == onboardingPath;
      final isGoingToLogin = state.matchedLocation == serverManagementPath;

      // 1. Priority: Onboarding
      if (isFirstRun) {
        return isGoingToOnboarding ? null : onboardingPath;
      }

      // 2. Priority: Auth
      if (!isLoggedIn && !isOfflineMode && !authState.isDemoMode) {
        // If coming from Onboarding (just finished), let it fall through to Login
        if (isGoingToLogin) return null;
        return serverManagementPath;
      }

      // 3. Priority: Offline Mode - restrict to downloads and settings
      if (isOfflineMode && !isLoggedIn) {
        // Allow access to downloads, settings, and video player
        if (state.matchedLocation == downloadsPath ||
            state.matchedLocation == settingsPath ||
            state.matchedLocation == videoPlayerPath ||
            state.matchedLocation == detailsPath) {
          return null;
        }
        // Default to downloads for any other route
        return downloadsPath;
      }

      // 4. Priority: Authenticated User Navigation
      if (isLoggedIn && (isGoingToLogin || isGoingToOnboarding)) {
        return basePath;
      }

      return null;
    },
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
