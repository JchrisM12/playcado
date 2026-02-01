import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/video_player/views/video_player.dart';
import 'package:playcado/widgets/widgets.dart';

/// Displays the media details header
class MediaDetailsHeader extends StatelessWidget {
  final MediaItem item;
  final bool isItemPlaying;
  final MediaItem? playingItem;
  final VideoPlayerState playerState;
  final String heroTag;

  const MediaDetailsHeader({
    super.key,
    required this.item,
    required this.isItemPlaying,
    this.playingItem,
    required this.playerState,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final urlGenerator = context.read<MediaUrlService>();
    final backdropUrl = urlGenerator.getItemBackdropUrl(item);

    final double videoHeight = MediaQuery.of(context).size.width * (9 / 16);
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: videoHeight,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          child: BackButton(onPressed: () => context.pop()),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: isItemPlaying && !playerState.isCasting
            ? Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                height: videoHeight,
                child: VideoPlayer(
                  item: playingItem!,
                  localPath: playerState.localPath,
                  isFullscreen: false,
                ),
              )
            : Hero(
                tag: heroTag,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlaycadoNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black54,
                            Colors.black,
                          ],
                          stops: [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
