import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/downloads/bloc/downloads_bloc.dart';
import 'package:playcado/video_player/views/mini_player.dart';
import 'package:playcado/widgets/app_drawer.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == 4) {
      Scaffold.of(context).openEndDrawer();
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      endDrawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // MiniPlayer sits directly as the top "extension" of the bar
                  const MiniPlayer(),
                  NavigationBarTheme(
                    data: NavigationBarThemeData(
                      height: 64,
                      backgroundColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysHide,
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        final isSelected = states.contains(
                          WidgetState.selected,
                        );
                        return IconThemeData(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          size: isSelected ? 28 : 24,
                        );
                      }),
                    ),
                    child: Builder(
                      builder: (context) => NavigationBar(
                        elevation: 0,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: (index) =>
                            _onTap(context, index),
                        destinations: [
                          NavigationDestination(
                            icon: const Icon(Icons.movie_outlined),
                            selectedIcon: const Icon(Icons.movie_rounded),
                            label: context.l10n.movies,
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.tv_outlined),
                            selectedIcon: const Icon(Icons.tv_rounded),
                            label: context.l10n.tv,
                          ),
                          NavigationDestination(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: navigationShell.currentIndex == 2
                                    ? colorScheme.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.home_outlined, size: 30),
                            ),
                            selectedIcon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.home_rounded,
                                size: 34,
                                color: colorScheme.primary,
                              ),
                            ),
                            label: context.l10n.home,
                          ),
                          NavigationDestination(
                            icon: BlocBuilder<DownloadsBloc, DownloadsState>(
                              builder: (context, state) {
                                final active = state.activeDownloads;
                                if (active.isEmpty) {
                                  return const Icon(Icons.download_outlined);
                                }
                                final progress =
                                    active
                                        .map((e) => e.progress)
                                        .reduce((a, b) => a + b) /
                                    active.length;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 2,
                                        backgroundColor: colorScheme
                                            .outlineVariant
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.download_outlined,
                                      size: 16,
                                    ),
                                  ],
                                );
                              },
                            ),
                            selectedIcon:
                                BlocBuilder<DownloadsBloc, DownloadsState>(
                                  builder: (context, state) {
                                    final active = state.activeDownloads;
                                    if (active.isEmpty) {
                                      return const Icon(Icons.download_rounded);
                                    }
                                    final progress =
                                        active
                                            .map((e) => e.progress)
                                            .reduce((a, b) => a + b) /
                                        active.length;
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 2.5,
                                            backgroundColor: colorScheme.primary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.download_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            label: context.l10n.downloads,
                          ),
                          NavigationDestination(
                            icon: const Icon(Icons.menu_rounded),
                            label: context.l10n.menu,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
