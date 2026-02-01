import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/cast/widgets/cast_dialog.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/core/formatters.dart';
import 'package:playcado/downloads/bloc/downloads_bloc.dart';
import 'package:playcado/downloads_repository/models/download_item.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/series_details/bloc/series_details_bloc.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/widgets/loading_indicator.dart';
import 'package:playcado/widgets/snackbar_helper.dart';

class MediaDetailsActions extends StatelessWidget {
  final MediaItem item;
  final Function(MediaItem item, String? localPath) onPlay;

  const MediaDetailsActions({
    super.key,
    required this.item,
    required this.onPlay,
  });

  Future<void> _handleStop(BuildContext context, bool isCasting) async {
    if (isCasting) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.stopCastingQuestion),
          content: Text(context.l10n.areYouSureYouWantToStopCasting),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.stop),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        context.read<VideoPlayerBloc>().add(PlayerStopRequested());
        await context.read<CastService>().disconnect();
      }
    } else {
      context.read<VideoPlayerBloc>().add(PlayerStopRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, playerState) {
        final isItemPlaying = playerState.containsItem(item);
        final isCasting = playerState.isCasting;
        final isPaused = playerState.status == VideoPlayerStatus.paused;

        Widget mainButton;
        if (isItemPlaying) {
          mainButton = Row(
            children: [
              Expanded(
                flex: 3,
                child: _MainActionButton(
                  icon: isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  label: isPaused ? context.l10n.resume : context.l10n.pause,
                  isPrimary: true,
                  fontSize: 13,
                  onPressed: () {
                    if (isPaused) {
                      context.read<VideoPlayerBloc>().add(
                        PlayerResumeRequested(),
                      );
                    } else {
                      context.read<VideoPlayerBloc>().add(
                        PlayerPauseRequested(),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _MainActionButton(
                  icon: Icons.stop_rounded,
                  label: context.l10n.stop,
                  isPrimary: false,
                  fontSize: 13,
                  onPressed: () => _handleStop(context, isCasting),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _MainActionButton(
                  icon: Icons.fullscreen_rounded,
                  label: context.l10n.full,
                  isPrimary: false,
                  fontSize: 13,
                  onPressed: () => context.push(AppRouter.videoPlayerPath),
                ),
              ),
            ],
          );
        } else {
          if (item.type == MediaItemType.movie ||
              item.type == MediaItemType.episode ||
              item.type == MediaItemType.video) {
            mainButton = DetailsPlayButton(
              item: item,
              isCasting: isCasting,
              onPlay: (path) => onPlay(item, path),
            );
          } else if (item.type == MediaItemType.series) {
            mainButton = SeriesNextUpButton(
              isCasting: isCasting,
              onPlay: (episode) => onPlay(episode, null),
            );
          } else {
            mainButton = const SizedBox.shrink();
          }
        }

        return Column(
          children: [
            mainButton,
            if (item.type != MediaItemType.season) ...[
              const SizedBox(height: 24),
              _ActionRow(
                item: item,
                isPlaying: isItemPlaying,
                isCasting: isCasting,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MainActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double fontSize;
  final bool isPrimary;

  const _MainActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.fontSize = 16,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 56,
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 26),
              label: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const StadiumBorder(),
                elevation: 4,
                shadowColor: colorScheme.primary.withValues(alpha: 0.4),
              ),
            )
          : FilledButton.tonalIcon(
              onPressed: onPressed,
              icon: Icon(icon, size: 22),
              label: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: const StadiumBorder(),
                backgroundColor: colorScheme.surfaceContainerHigh,
                foregroundColor: colorScheme.onSurface,
              ),
            ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final MediaItem item;
  final bool isPlaying;
  final bool isCasting;

  const _ActionRow({
    required this.item,
    required this.isPlaying,
    required this.isCasting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SeriesDetailsBloc, SeriesDetailsState>(
      builder: (context, detailsState) {
        return BlocBuilder<DownloadsBloc, DownloadsState>(
          builder: (context, downloadsState) {
            final currentMainItem = detailsState.series.value ?? item;
            final isWatched = currentMainItem.isPlayed;

            // Find current download item status for the targeted item (could be an episode)
            final downloadItem = downloadsState.downloads
                .where((d) => d.id == item.id)
                .fold<DownloadItem?>(null, (prev, elem) => elem);

            IconData downloadIcon = Icons.download_for_offline_outlined;
            String downloadLabel = context.l10n.download;
            Color? downloadIconColor;

            if (downloadItem != null) {
              switch (downloadItem.status) {
                case DownloadStatus.queued:
                  downloadIcon = Icons.schedule_rounded;
                  downloadLabel = context.l10n.queued;
                  break;
                case DownloadStatus.downloading:
                  downloadIcon = Icons.downloading_rounded;
                  downloadLabel = '${(downloadItem.progress * 100).toInt()}%';
                  downloadIconColor = theme.colorScheme.primary;
                  break;
                case DownloadStatus.completed:
                  downloadIcon = Icons.download_done_rounded;
                  downloadLabel = context.l10n.downloaded;
                  downloadIconColor = theme.colorScheme.primary;
                  break;
                case DownloadStatus.paused:
                  downloadIcon = Icons.pause_circle_outline_rounded;
                  downloadLabel = context.l10n.paused;
                  break;
                case DownloadStatus.error:
                  downloadIcon = Icons.error_outline_rounded;
                  downloadLabel = context.l10n.failed;
                  downloadIconColor = theme.colorScheme.error;
                  break;
              }
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: isWatched
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    iconColor: isWatched ? theme.colorScheme.primary : null,
                    label: isWatched
                        ? context.l10n.watched
                        : context.l10n.unwatched,
                    onTap: () => context.read<SeriesDetailsBloc>().add(
                      TogglePlayedStatus(),
                    ),
                  ),
                ),
                if (currentMainItem.type == MediaItemType.series) ...[
                  if (detailsState.expandedSeasonId != null)
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.library_add_check_outlined,
                        label: context.l10n.downloadSeason(
                          detailsState.seasons.value
                                  ?.firstWhere(
                                    (s) =>
                                        s.id == detailsState.expandedSeasonId,
                                    orElse: () => currentMainItem,
                                  )
                                  .name ??
                              'Season',
                        ),
                        onTap: () {
                          final episodes = detailsState
                              .episodes
                              .value?[detailsState.expandedSeasonId];
                          if (episodes != null && episodes.isNotEmpty) {
                            for (final ep in episodes) {
                              context.read<DownloadsBloc>().add(
                                DownloadsRequested(item: ep),
                              );
                            }
                            SnackbarHelper.showInfo(
                              context,
                              context.l10n.downloadingSeason,
                            );
                            context.go(AppRouter.downloadsPath);
                          }
                        },
                      ),
                    ),
                  if (item.type == MediaItemType.episode)
                    Expanded(
                      child: _ActionButton(
                        icon: downloadIcon,
                        iconColor: downloadIconColor,
                        label:
                            '${context.l10n.download} S${item.parentIndexNumber} E${item.indexNumber}',
                        onTap: () {
                          if (downloadItem == null ||
                              downloadItem.status == DownloadStatus.error) {
                            context.read<DownloadsBloc>().add(
                              DownloadsRequested(item: item),
                            );
                            SnackbarHelper.showInfo(
                              context,
                              context.l10n.downloadingEpisode,
                            );
                          }
                          context.go(AppRouter.downloadsPath);
                        },
                      ),
                    ),
                ],
                if (currentMainItem.type == MediaItemType.movie ||
                    currentMainItem.type == MediaItemType.video ||
                    (currentMainItem.type == MediaItemType.episode &&
                        item.id == currentMainItem.id))
                  Expanded(
                    child: _ActionButton(
                      icon: downloadIcon,
                      iconColor: downloadIconColor,
                      label: downloadLabel,
                      onTap: () {
                        if (downloadItem == null ||
                            downloadItem.status == DownloadStatus.error) {
                          context.read<DownloadsBloc>().add(
                            DownloadsRequested(item: item),
                          );
                        }
                        context.go(AppRouter.downloadsPath);
                      },
                    ),
                  ),
                Expanded(
                  child: _ActionButton(
                    icon: isCasting ? Icons.cast_connected : Icons.cast_rounded,
                    iconColor: isCasting ? theme.colorScheme.primary : null,
                    label: isCasting
                        ? context.l10n.castingToDevice
                        : context.l10n.cast,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            CastDeviceListDialog(autoPlayItem: item),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor ?? theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A large play button used in media details.
class DetailsPlayButton extends StatelessWidget {
  final MediaItem item;
  final Function(String? localPath) onPlay;

  final bool isCasting;

  const DetailsPlayButton({
    super.key,
    required this.item,
    required this.onPlay,
    this.isCasting = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      builder: (context, state) {
        final downloadItem = state.downloads
            .where((d) => d.id == item.id)
            .fold<DownloadItem?>(null, (prev, elem) => elem);

        final isDownloaded = downloadItem?.status == DownloadStatus.completed;

        String labelText;
        final ticks = item.playbackPositionTicks ?? 0;
        final isResuming = ticks > 0;

        if (isCasting) {
          labelText = context.l10n.castingToDevice;
        } else if (isDownloaded) {
          labelText = isResuming
              ? context.l10n.resume
              : context.l10n.playOffline;
        } else {
          labelText = isResuming ? context.l10n.resume : context.l10n.play;
        }

        if (isResuming && !isCasting) {
          final remaining = Formatters.formatTimeRemaining(
            (item.runTimeTicks ?? 0) - ticks,
          );
          if (remaining.isNotEmpty) {
            labelText = '$labelText • $remaining';
          }
        }

        return SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton.icon(
            onPressed: () =>
                onPlay(isDownloaded ? downloadItem!.localPath : null),
            icon: const Icon(Icons.play_arrow_rounded, size: 32),
            label: Text(
              labelText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              elevation: 4,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        );
      },
    );
  }
}

class SeriesNextUpButton extends StatelessWidget {
  final Function(MediaItem item) onPlay;

  final bool isCasting;

  const SeriesNextUpButton({
    super.key,
    required this.onPlay,
    this.isCasting = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesDetailsBloc, SeriesDetailsState>(
      builder: (context, state) {
        if (state.nextEpisode.isLoading) {
          return const SizedBox(height: 60, child: LoadingIndicator());
        }

        final nextEpisode = state.nextEpisode.value;

        if (nextEpisode == null) {
          return const SizedBox.shrink();
        }

        final resumeTicks = nextEpisode.playbackPositionTicks ?? 0;
        final isResuming = resumeTicks > 0;
        final prefix = isResuming ? context.l10n.resume : context.l10n.next;

        String labelText;
        if (isCasting) {
          labelText = context.l10n.castingToDevice;
        } else {
          labelText =
              '$prefix: S${nextEpisode.parentIndexNumber} E${nextEpisode.indexNumber}';
          if (isResuming) {
            final remaining = Formatters.formatTimeRemaining(
              (nextEpisode.runTimeTicks ?? 0) - resumeTicks,
            );
            if (remaining.isNotEmpty) {
              labelText = '$labelText • $remaining';
            }
          }
        }

        return SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton.icon(
            onPressed: () => onPlay(nextEpisode),
            icon: const Icon(Icons.play_arrow_rounded, size: 32),
            label: Text(
              labelText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              elevation: 4,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        );
      },
    );
  }
}
