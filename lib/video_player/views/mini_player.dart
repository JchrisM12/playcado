import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/widgets/widgets.dart';

class MiniPlayer extends StatelessWidget {
  final String? currentRoutePath;
  final Object? currentRouteExtra;

  const MiniPlayer({super.key, this.currentRoutePath, this.currentRouteExtra});

  @override
  Widget build(BuildContext context) {
    final (isActive, item, status, isCasting) = context
        .select<VideoPlayerBloc, (bool, MediaItem?, VideoPlayerStatus, bool)>(
          (bloc) => (
            bloc.state.isActive,
            bloc.state.mediaItem,
            bloc.state.status,
            bloc.state.isCasting,
          ),
        );

    if (!isActive || item == null) {
      return const SizedBox.shrink();
    }

    // Hide MiniPlayer if we are viewing the details of the currently playing item
    if (currentRoutePath == AppRouter.detailsPath &&
        currentRouteExtra is Map<String, dynamic>) {
      final extra = currentRouteExtra as Map<String, dynamic>;
      final displayedItem = extra['item'] as MediaItem;

      // We use item.id comparison here directly for efficiency
      if (item.id == displayedItem.id ||
          (displayedItem.type == MediaItemType.series &&
              item.seriesId == displayedItem.id)) {
        return const SizedBox.shrink();
      }
    }

    final isPlaying =
        status == VideoPlayerStatus.playing ||
        status == VideoPlayerStatus.loading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageUrl = context.read<MediaUrlService>().getImageUrl(item.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final heroTag = item.heroTag('mini_player');
        if (item.type == MediaItemType.episode && item.seriesId != null) {
          final seriesItem = MediaItem(
            id: item.seriesId!,
            name: item.seriesName ?? item.name,
            type: MediaItemType.series,
          );
          context.push(
            AppRouter.detailsPath,
            extra: {'item': seriesItem, 'heroTag': heroTag},
          );
        } else {
          context.push(
            AppRouter.detailsPath,
            extra: {'item': item, 'heroTag': heroTag},
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: PlaycadoNetworkImage(
                    imageUrl: imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    memCacheWidth: 150,
                    placeholder: (context, url) =>
                        Container(color: colorScheme.secondaryContainer),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.movie),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final sub = item.displaySubtitle;
                          if (sub != null) {
                            return Text(
                              sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          } else if (isCasting) {
                            return Text(
                              'Casting...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),

                // Controls
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      context.read<VideoPlayerBloc>().add(
                        PlayerPauseRequested(),
                      );
                    } else {
                      context.read<VideoPlayerBloc>().add(
                        PlayerResumeRequested(),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    context.read<VideoPlayerBloc>().add(PlayerStopRequested());
                  },
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}
