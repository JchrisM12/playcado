import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/l10n/app_localizations.dart';
import 'package:playcado/libraries/bloc/libraries_bloc.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final (isOfflineMode, isDemoMode, isLoggedIn, credentials) = context
        .select<AuthBloc, (bool, bool, bool, ServerCredentials?)>(
          (b) => (
            b.state.isOfflineMode,
            b.state.isDemoMode,
            b.state.isLoggedIn,
            b.state.credentials,
          ),
        );
    final librariesState = context.watch<LibrariesBloc>().state;
    final libraries = librariesState.libraries.value ?? [];

    // Identify if standard libraries exist on the server
    final hasMovies = libraries.any(
      (l) => l.collectionType?.toLowerCase() == 'movies',
    );
    final hasTv = libraries.any(
      (l) => l.collectionType?.toLowerCase() == 'tvshows',
    );

    final username = credentials?.username ?? 'User';
    final server = credentials?.serverName ?? '';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            bottomLeft: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context, username, server, isOfflineMode, isDemoMode),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  if (isLoggedIn && !isOfflineMode) ...[
                    _DrawerItem(
                      icon: Icons.home_rounded,
                      label: context.l10n.home,
                      isSelected: false,
                      onTap: () => _navigate(context, AppRouter.basePath),
                    ),
                    if (hasMovies)
                      _DrawerItem(
                        icon: Icons.movie_rounded,
                        label: context.l10n.movies,
                        isSelected: false,
                        onTap: () => _navigate(context, AppRouter.moviesPath),
                      ),
                    if (hasTv)
                      _DrawerItem(
                        icon: Icons.tv_rounded,
                        label: context.l10n.tvShows,
                        isSelected: false,
                        onTap: () => _navigate(context, AppRouter.tvPath),
                      ),
                    ...libraries
                        .where((lib) {
                          // Exclude items already shown in the primary navigation
                          final type = lib.collectionType?.toLowerCase();
                          return type != 'movies' && type != 'tvshows';
                        })
                        .map((lib) {
                          IconData icon;
                          final type = lib.collectionType?.toLowerCase();
                          if (type == 'homevideos') {
                            icon = Icons.video_library_rounded;
                          } else if (type == 'music') {
                            icon = Icons.music_note_rounded;
                          } else if (type == 'photos') {
                            icon = Icons.photo_library_rounded;
                          } else {
                            icon = Icons.folder_rounded;
                          }

                          return _DrawerItem(
                            icon: icon,
                            label: lib.name,
                            isSelected: false,
                            onTap: () => _navigate(
                              context,
                              AppRouter.libraryPath,
                              extra: lib,
                            ),
                          );
                        }),
                  ],
                  _DrawerItem(
                    icon: Icons.download_rounded,
                    label: context.l10n.downloads,
                    isSelected: false,
                    onTap: () => _navigate(context, AppRouter.downloadsPath),
                  ),
                  if (kDebugMode && isLoggedIn && !isOfflineMode) ...[
                    _DrawerItem(
                      icon: Icons.developer_mode,
                      label: context.l10n.devTools,
                      isSelected: false,
                      onTap: () => _navigate(context, AppRouter.devtoolsPath),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Divider(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegalLink(
                          label: context.l10n.privacyPolicy,
                          url: 'https://JchrisM12.github.io/playcado-privacy/',
                        ),
                        Text(
                          '•',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        _LegalLink(
                          label: context.l10n.termsOfService,
                          url: 'https://JchrisM12.github.io/playcado-terms/',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      label: isDemoMode
                          ? 'Exit Demo Mode'
                          : isOfflineMode
                          ? context.l10n.exitOfflineMode
                          : context.l10n.manageServers,
                      isSelected: false,
                      isDestructive: true,
                      onTap: () {
                        context.pop();
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String username,
    String server,
    bool isOfflineMode,
    bool isDemoMode,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
            ),
            child: isDemoMode
                ? CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.surface,
                    child: Icon(
                      Icons.personal_video_rounded,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  )
                : isOfflineMode
                ? CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.surface,
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 28,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                : CircleLogo(radius: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDemoMode
                      ? 'Demo Mode'
                      : isOfflineMode
                      ? context.l10n.offlineMode
                      : username,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOfflineMode
                          ? Icons.download_rounded
                          : Icons.dns_rounded,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isDemoMode
                            ? 'Creative Commons Content'
                            : isOfflineMode
                            ? AppLocalizations.of(
                                context,
                              )!.downloadedContentOnly
                            : server,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String path, {MediaItem? extra}) {
    Navigator.of(context).pop();

    final corePaths = [
      AppRouter.basePath,
      AppRouter.moviesPath,
      AppRouter.tvPath,
      AppRouter.downloadsPath,
    ];

    if (corePaths.contains(path)) {
      context.go(path);
    } else if (extra != null) {
      context.push(path, extra: extra);
    } else {
      context.push(path);
    }
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;

  const _LegalLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 11,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final baseColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final selectedColor = isDestructive
        ? colorScheme.error
        : colorScheme.primary;

    final color = isSelected ? selectedColor : baseColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
