import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/core/formatters.dart';
import 'package:playcado/downloads/widgets/media_download_button.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/series_details/bloc/series_details_bloc.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/widgets/widgets.dart';

class SeriesEpisodeList extends StatelessWidget {
  final String seriesId;
  final Function(MediaItem item) onPlay;

  const SeriesEpisodeList({
    super.key,
    required this.seriesId,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesDetailsBloc, SeriesDetailsState>(
      builder: (context, state) {
        if (state.seasons.isLoading) {
          return const LoadingIndicator();
        } else if (state.seasons.isError) {
          return const Text('Error loading seasons');
        }

        final seasons = state.seasons.value ?? [];
        if (seasons.isEmpty) {
          return const SizedBox.shrink();
        }

        // Use the expandedSeasonId from state, falling back to the first season ID
        final selectedSeasonId = state.expandedSeasonId ?? seasons.first.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSeasonId,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null &&
                          newValue != state.expandedSeasonId) {
                        context.read<SeriesDetailsBloc>().add(
                          FetchEpisodes(seriesId: seriesId, seasonId: newValue),
                        );
                      }
                    },
                    items: seasons.map<DropdownMenuItem<String>>((
                      MediaItem season,
                    ) {
                      return DropdownMenuItem<String>(
                        value: season.id,
                        child: Text(season.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _EpisodeList(seasonId: selectedSeasonId, onPlay: onPlay),
          ],
        );
      },
    );
  }
}

class _EpisodeList extends StatelessWidget {
  final String seasonId;
  final Function(MediaItem item) onPlay;

  const _EpisodeList({required this.seasonId, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesDetailsBloc, SeriesDetailsState>(
      builder: (context, state) {
        final episodes = state.episodes.value?[seasonId] ?? [];

        if (state.episodes.isLoading && episodes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: LoadingIndicator(),
          );
        }

        if (episodes.isEmpty && !state.episodes.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(context.l10n.noEpisodesFound),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final episode = episodes[index];
            return _EpisodeTile(episode: episode, onPlay: onPlay);
          },
        );
      },
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final MediaItem episode;
  final Function(MediaItem item) onPlay;

  const _EpisodeTile({required this.episode, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imgUrl = context.read<MediaUrlService>().getItemImageUrl(
      episode,
      isLandscape: true,
    );

    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, playerState) {
        final isPlaying =
            playerState.mediaItem?.id == episode.id && playerState.isActive;

        return InkWell(
          onTap: () {
            context.read<SeriesDetailsBloc>().add(
              SelectEpisode(episode: episode),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<SeriesDetailsBloc>().add(
                        SelectEpisode(episode: episode),
                      );
                      onPlay(episode);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: PlaycadoNetworkImage(
                            imageUrl: imgUrl,
                            width: 140,
                            height: 80,
                            fit: BoxFit.cover,
                            memCacheWidth: 350,
                            placeholder: (context, url) => Container(
                              width: 140,
                              height: 80,
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 140,
                              height: 80,
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.movie_outlined),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isPlaying
                                ? Icons.graphic_eq_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${episode.indexNumber}. ${episode.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPlaying ? colorScheme.primary : null,
                          ),
                        ),
                        if (episode.runTimeTicks != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatDuration(episode.runTimeTicks),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MediaDownloadButton(item: episode),
                ],
              ),
              if (episode.overview != null && episode.overview!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    episode.overview!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
