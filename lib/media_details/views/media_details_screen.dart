import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/media/repos/playback_repository.dart';
import 'package:playcado/media_details/widgets/media_details_actions.dart';
import 'package:playcado/media_details/widgets/media_details_header.dart';
import 'package:playcado/media_details/widgets/media_details_overview.dart';
import 'package:playcado/media_details/widgets/media_details_title.dart';
import 'package:playcado/series_details/bloc/series_details_bloc.dart';
import 'package:playcado/series_details/widgets/series_episode_list.dart';
import 'package:playcado/services/media_url/media_url_service.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';

class MediaDetailsScreen extends StatefulWidget {
  final MediaItem item;
  final String heroTag;

  const MediaDetailsScreen({
    super.key,
    required this.item,
    required this.heroTag,
  });

  @override
  State<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends State<MediaDetailsScreen> {
  late final SeriesDetailsBloc _detailsBloc;

  @override
  void initState() {
    super.initState();
    _detailsBloc = SeriesDetailsBloc(
      libraryRepository: context.read<LibraryRepository>(),
      playbackRepository: context.read<PlaybackRepository>(),
    );

    if (widget.item.type == MediaItemType.episode &&
        widget.item.seriesId != null) {
      final seriesId = widget.item.seriesId!;
      final seasonId = widget.item.seasonId;

      _detailsBloc
        ..add(FetchItemDetails(itemId: seriesId))
        ..add(FetchSeasons(seriesId: seriesId))
        ..add(SelectEpisode(episode: widget.item))
        ..add(FetchSelectedEpisodeDetails(episodeId: widget.item.id));

      if (seasonId != null) {
        _detailsBloc.add(FetchEpisodes(seriesId: seriesId, seasonId: seasonId));
      }
    } else {
      _detailsBloc.add(FetchItemDetails(itemId: widget.item.id));

      if (widget.item.type == MediaItemType.series) {
        _detailsBloc
          ..add(FetchSeasons(seriesId: widget.item.id))
          ..add(FetchNextEpisode(seriesId: widget.item.id));
      }
    }
  }

  @override
  void dispose() {
    _detailsBloc.close();
    super.dispose();
  }

  void _onPlay(BuildContext context, MediaItem item, String? localPath) {
    context.read<VideoPlayerBloc>().add(
      PlayerPlayRequested(item: item, localPath: localPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _detailsBloc,
      child: _MediaDetailsView(
        displayItem: widget.item,
        heroTag: widget.heroTag,
        onPlay: (item, path) => _onPlay(context, item, path),
      ),
    );
  }
}

class _MediaDetailsView extends StatefulWidget {
  final MediaItem displayItem;
  final String heroTag;
  final Function(MediaItem item, String? localPath) onPlay;

  const _MediaDetailsView({
    required this.displayItem,
    required this.heroTag,
    required this.onPlay,
  });

  @override
  State<_MediaDetailsView> createState() => _MediaDetailsViewState();
}

class _MediaDetailsViewState extends State<_MediaDetailsView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        builder: (context, playerState) {
          return BlocBuilder<SeriesDetailsBloc, SeriesDetailsState>(
            builder: (context, detailsState) {
              final seriesItem =
                  detailsState.series.value ?? widget.displayItem;
              final isItemPlaying = playerState.containsItem(seriesItem);
              final playingItem = playerState.mediaItem;
              final nextEpisode = detailsState.nextEpisode.value;
              final selectedEpisode = detailsState.selectedEpisode;

              // Priority: 1. User selected episode, 2. Playing item, 3. Next Up, 4. Series info
              final MediaItem effectiveItem;
              if (selectedEpisode != null) {
                effectiveItem = selectedEpisode;
              } else if (isItemPlaying && playingItem != null) {
                effectiveItem = playingItem;
              } else if (seriesItem.type == MediaItemType.series &&
                  nextEpisode != null) {
                effectiveItem = nextEpisode;
              } else {
                effectiveItem = seriesItem;
              }

              return MultiBlocListener(
                listeners: [
                  BlocListener<VideoPlayerBloc, VideoPlayerState>(
                    listenWhen: (previous, current) {
                      final startedLoading =
                          previous.status != VideoPlayerStatus.loading &&
                          current.status == VideoPlayerStatus.loading;
                      final startedPlaying =
                          previous.status != VideoPlayerStatus.loading &&
                          previous.status != VideoPlayerStatus.playing &&
                          current.status == VideoPlayerStatus.playing;
                      final itemChanged =
                          previous.mediaItem?.id != current.mediaItem?.id;

                      return (startedLoading ||
                              startedPlaying ||
                              itemChanged) &&
                          current.mediaItem != null &&
                          current.containsItem(seriesItem);
                    },
                    listener: (context, state) {
                      _scrollToTop();
                    },
                  ),
                  BlocListener<VideoPlayerBloc, VideoPlayerState>(
                    listenWhen: (prev, curr) =>
                        prev.status != VideoPlayerStatus.stopped &&
                        curr.status == VideoPlayerStatus.stopped,
                    listener: (context, state) {
                      final lastItem = state.mediaItem;
                      if (lastItem != null) {
                        context.read<SeriesDetailsBloc>().add(
                          UpdateLocalPlaybackProgress(
                            itemId: lastItem.id,
                            positionTicks: state.position.inMicroseconds * 10,
                          ),
                        );
                      }
                    },
                  ),
                  BlocListener<SeriesDetailsBloc, SeriesDetailsState>(
                    listenWhen: (previous, current) =>
                        previous.selectedEpisode?.id !=
                        current.selectedEpisode?.id,
                    listener: (context, state) {
                      _scrollToTop();
                    },
                  ),
                ],
                child: Material(
                  type: MaterialType.transparency,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      MediaDetailsHeader(
                        item: effectiveItem,
                        isItemPlaying: isItemPlaying,
                        playingItem: playingItem,
                        playerState: playerState,
                        heroTag: widget.heroTag,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MediaDetailsTitle(item: seriesItem),
                              const SizedBox(height: 24),
                              MediaDetailsActions(
                                item: effectiveItem,
                                onPlay: (item, path) =>
                                    widget.onPlay(item, path),
                              ),
                              const SizedBox(height: 24),
                              MediaDetailsOverview(
                                item: effectiveItem,
                                nextEpisode: nextEpisode,
                              ),
                              if ((seriesItem.type == MediaItemType.movie ||
                                      seriesItem.type == MediaItemType.video) &&
                                  effectiveItem.people != null &&
                                  effectiveItem.people!.isNotEmpty)
                                _MediaDetailsCast(
                                  people: effectiveItem.people!,
                                ),
                              if (seriesItem.type == MediaItemType.series)
                                SeriesEpisodeList(
                                  seriesId: seriesItem.id,
                                  onPlay: (episode) =>
                                      widget.onPlay(episode, null),
                                ),
                              if (seriesItem.type == MediaItemType.series &&
                                  effectiveItem.people != null &&
                                  effectiveItem.people!.isNotEmpty)
                                _MediaDetailsCast(
                                  people: effectiveItem.people!,
                                ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MediaDetailsCast extends StatelessWidget {
  final List<MediaPerson> people;

  const _MediaDetailsCast({required this.people});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urlGenerator = context.read<MediaUrlService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            context.l10n.cast,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              final imageUrl = urlGenerator.getImageUrl(person.id);

              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      person.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (person.role != null && person.role!.isNotEmpty)
                      Text(
                        person.role!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
