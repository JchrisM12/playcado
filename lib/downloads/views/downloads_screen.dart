import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/core/formatters.dart';
import 'package:playcado/downloads/bloc/downloads_bloc.dart';
import 'package:playcado/downloads_repository/downloads_repository.dart';
import 'package:playcado/l10n/app_localizations.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/widgets/snackbar_helper.dart';
import 'package:playcado/widgets/widgets.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isOfflineMode = context.select<AuthBloc, bool>(
      (b) => b.state.isOfflineMode,
    );

    if (isOfflineMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.offlineDownloads),
          centerTitle: false,
        ),
        body: const _CompletedDownloadsList(isOfflineMode: true),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: IconTitle(title: context.l10n.downloads),
          centerTitle: false,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            tabs: [
              Tab(text: context.l10n.active),
              Tab(text: context.l10n.completed),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveDownloadsList(),
            _CompletedDownloadsList(isOfflineMode: false),
          ],
        ),
      ),
    );
  }
}

class _ActiveDownloadsList extends StatelessWidget {
  const _ActiveDownloadsList();

  @override
  Widget build(BuildContext context) {
    final items = context.select<DownloadsBloc, List<DownloadItem>>(
      (b) => b.state.activeDownloads,
    );
    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.download_done_rounded,
        message: context.l10n.noActiveDownloads,
        subMessage: AppLocalizations.of(
          context,
        )!.moviesAndEpisodesYouDownloadWillAppearHere,
      );
    }

    final playerActive = context.select<VideoPlayerBloc, bool>(
      (b) => b.state.isActive,
    );
    final bottomPadding =
        MediaQuery.paddingOf(context).bottom + 10 + (playerActive ? 70 : 0);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ActiveDownloadCard(item: items[index]);
      },
    );
  }
}

class _ActiveDownloadCard extends StatelessWidget {
  final DownloadItem item;

  const _ActiveDownloadCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaused = item.status == DownloadStatus.paused;
    final isError = item.status == DownloadStatus.error;
    final isDownloading = item.status == DownloadStatus.downloading;

    // Indeterminate if downloading but total size is unknown/0
    final isIndeterminate = isDownloading && item.totalBytes <= 0;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 90,
                    child: item.imageUrl != null
                        ? PlaycadoNetworkImage(
                            imageUrl: item.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.movie_outlined),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.movie_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (item.progress > 0 && !isIndeterminate)
                              ? item.progress
                              : (isDownloading ? null : 0),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: isError
                              ? colorScheme.error
                              : (isPaused
                                    ? colorScheme.secondary
                                    : colorScheme.primary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Meta Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getProgressText(context),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isError
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDownloading && (item.networkSpeed ?? 0) > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                Formatters.formatSpeed(item.networkSpeed ?? 0),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (item.status == DownloadStatus.downloading ||
                    item.status == DownloadStatus.queued)
                  TextButton.icon(
                    onPressed: () {
                      context.read<DownloadsBloc>().add(
                        DownloadsPauseRequested(item.id),
                      );
                    },
                    icon: const Icon(Icons.pause_rounded, size: 20),
                    label: Text(context.l10n.pause),
                  )
                else if (isPaused || isError)
                  TextButton.icon(
                    onPressed: () {
                      context.read<DownloadsBloc>().add(
                        DownloadsResumeRequested(item.id),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(context.l10n.resume),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    context.read<DownloadsBloc>().add(
                      DownloadsDeleteRequested(item.id),
                    );
                    SnackbarHelper.showInfo(
                      context,
                      context.l10n.downloadCancelled,
                    );
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                  label: Text(context.l10n.cancel),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressText(BuildContext context) {
    switch (item.status) {
      case DownloadStatus.queued:
        return context.l10n.queued;
      case DownloadStatus.downloading:
        final percent = (item.progress * 100).toStringAsFixed(1);
        if (item.totalBytes > 0) {
          final current = Formatters.formatBytes(item.receivedBytes);
          final total = Formatters.formatBytes(item.totalBytes);
          return '$percent% • $current of $total';
        }
        return '$percent%';
      case DownloadStatus.paused:
        return context.l10n.paused;
      case DownloadStatus.error:
        return context.l10n.failed;
      case DownloadStatus.completed:
        return context.l10n.completed;
    }
  }
}

class _CompletedDownloadsList extends StatelessWidget {
  final bool isOfflineMode;

  const _CompletedDownloadsList({required this.isOfflineMode});

  @override
  Widget build(BuildContext context) {
    final items = context.select<DownloadsBloc, List<DownloadItem>>(
      (b) => b.state.completedDownloads,
    );
    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.file_download_off_outlined,
        message: isOfflineMode
            ? context.l10n.noOfflineContent
            : context.l10n.noDownloadsYet,
        subMessage: isOfflineMode
            ? context.l10n.connectToYourServerToDownloadContent
            : context.l10n.downloadedContentIsAvailableOffline,
        showBrowseButton: !isOfflineMode,
      );
    }

    final playerActive = context.select<VideoPlayerBloc, bool>(
      (b) => b.state.isActive,
    );
    final bottomPadding =
        MediaQuery.paddingOf(context).bottom + 10 + (playerActive ? 70 : 0);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CompletedDownloadCard(
          item: items[index],
          isOfflineMode: isOfflineMode,
        );
      },
    );
  }
}

class _CompletedDownloadCard extends StatelessWidget {
  final DownloadItem item;
  final bool isOfflineMode;

  const _CompletedDownloadCard({
    required this.item,
    required this.isOfflineMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          final mediaItem = MediaItem(
            id: item.id,
            name: item.name,
            overview: item.overview,
            type: item.type ?? MediaItemType.movie,
          );
          final heroTag = mediaItem.heroTag('download');
          context.push(
            AppRouter.detailsPath,
            extra: {'item': mediaItem, 'heroTag': heroTag},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 50,
                      child: item.imageUrl != null
                          ? PlaycadoNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.movie_outlined),
                              ),
                            )
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.movie_outlined),
                            ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.totalBytes > 0)
                      Text(
                        Formatters.formatBytes(item.totalBytes),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isOfflineMode)
                IconButton(
                  onPressed: () {
                    context.read<DownloadsBloc>().add(
                      DownloadsDeleteRequested(item.id),
                    );
                    SnackbarHelper.showInfo(
                      context,
                      context.l10n.deletedItem(item.name),
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: colorScheme.error,
                  tooltip: context.l10n.delete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final bool showBrowseButton;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subMessage,
    this.showBrowseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (showBrowseButton) ...[
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () => context.go(AppRouter.basePath),
              icon: const Icon(Icons.home_rounded),
              label: Text(context.l10n.browseLibrary),
            ),
          ],
        ],
      ),
    );
  }
}
