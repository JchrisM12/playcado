import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/media/data/media_remote_data_source.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/jellyfin_client_service.dart';

class JellyfinRemoteDataSource implements MediaRemoteDataSource {
  final JellyfinClientService _jellyfinClientService;

  JellyfinRemoteDataSource({required JellyfinClientService clientManager})
    : _jellyfinClientService = clientManager;

  JellyfinDart? get _client => _jellyfinClientService.client;

  void _checkClient() {
    if (_client == null || !_jellyfinClientService.hasSession) {
      throw Exception('Not authenticated');
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    _checkClient();
    final userResponse = await _client!.getUserApi().getCurrentUser();
    return userResponse.data?.id;
  }

  @override
  Future<List<MediaItem>> fetchItems({
    required String userId,
    int? startIndex,
    int? limit,
    List<BaseItemKind>? includeItemTypes,
    bool? recursive,
    List<ItemSortBy>? sortBy,
    List<SortOrder>? sortOrder,
    List<ItemFields>? fields,
    List<ItemFilter>? filters,
    String? searchTerm,
    List<String>? ids,
    String? parentId,
  }) async {
    _checkClient();
    final response = await _client!.getItemsApi().getItems(
      userId: userId,
      startIndex: startIndex,
      limit: limit,
      includeItemTypes: includeItemTypes,
      recursive: recursive,
      sortBy: sortBy,
      sortOrder: sortOrder,
      fields: fields,
      filters: filters,
      searchTerm: searchTerm,
      ids: ids,
      parentId: parentId,
    );

    final items = response.data?.items ?? [];
    return _parseMediaItems(items);
  }

  @override
  Future<List<MediaItem>> fetchViews({required String userId}) async {
    _checkClient();
    final response = await _client!.getUserViewsApi().getUserViews(
      userId: userId,
    );

    final items = response.data?.items ?? [];
    return _parseMediaItems(items);
  }

  @override
  Future<List<MediaItem>> fetchLatestMedia({
    required String userId,
    int? limit,
    List<BaseItemKind>? includeItemTypes,
    List<ItemFields>? fields,
  }) async {
    _checkClient();
    final response = await _client!.getUserLibraryApi().getLatestMedia(
      userId: userId,
      limit: limit,
      includeItemTypes: includeItemTypes,
      fields: [...(fields ?? []), ItemFields.mediaSources],
    );

    final items = response.data ?? [];
    return _parseMediaItems(items);
  }

  @override
  Future<List<MediaItem>> fetchNextUp({
    required String userId,
    String? seriesId,
    int? limit,
    List<ItemFields>? fields,
  }) async {
    _checkClient();
    final response = await _client!.getTvShowsApi().getNextUp(
      userId: userId,
      seriesId: seriesId,
      limit: limit,
      fields: [...(fields ?? []), ItemFields.mediaSources],
    );

    final items = response.data?.items ?? [];
    return _parseMediaItems(items);
  }

  @override
  Future<List<MediaItem>> fetchSeasons({
    required String userId,
    required String seriesId,
    List<ItemFields>? fields,
  }) async {
    _checkClient();
    final response = await _client!.getTvShowsApi().getSeasons(
      userId: userId,
      seriesId: seriesId,
      fields: fields,
    );

    final items = response.data?.items ?? [];
    return _parseMediaItems(items, overrideType: MediaItemType.season);
  }

  @override
  Future<List<MediaItem>> fetchEpisodes({
    required String userId,
    required String seriesId,
    required String seasonId,
    List<ItemFields>? fields,
  }) async {
    _checkClient();
    final response = await _client!.getTvShowsApi().getEpisodes(
      userId: userId,
      seriesId: seriesId,
      seasonId: seasonId,
      fields: fields,
    );

    final items = response.data?.items ?? [];
    return _parseMediaItems(items, overrideType: MediaItemType.episode);
  }

  @override
  Future<void> reportPlaybackStart({
    required String itemId,
    required PlayMethod playMethod,
  }) async {
    _checkClient();
    final info = PlaybackStartInfo(itemId: itemId, playMethod: playMethod);
    await _client!.getPlaystateApi().reportPlaybackStart(
      playbackStartInfo: info,
    );
  }

  @override
  Future<void> reportPlaybackProgress({
    required String itemId,
    required int positionTicks,
    bool isPaused = false,
    PlayMethod playMethod = PlayMethod.directPlay,
  }) async {
    _checkClient();
    final info = PlaybackProgressInfo(
      itemId: itemId,
      positionTicks: positionTicks,
      isPaused: isPaused,
      playMethod: playMethod,
    );
    await _client!.getPlaystateApi().reportPlaybackProgress(
      playbackProgressInfo: info,
    );
  }

  @override
  Future<void> reportPlaybackStopped({
    required String itemId,
    required int positionTicks,
  }) async {
    _checkClient();
    final info = PlaybackStopInfo(itemId: itemId, positionTicks: positionTicks);
    await _client!.getPlaystateApi().reportPlaybackStopped(
      playbackStopInfo: info,
    );
  }

  @override
  Future<void> markPlayedItem({
    required String userId,
    required String itemId,
  }) async {
    _checkClient();
    await _client!.getPlaystateApi().markPlayedItem(
      userId: userId,
      itemId: itemId,
    );
  }

  @override
  Future<void> markUnplayedItem({
    required String userId,
    required String itemId,
  }) async {
    _checkClient();
    await _client!.getPlaystateApi().markUnplayedItem(
      userId: userId,
      itemId: itemId,
    );
  }

  List<MediaItem> _parseMediaItems(
    List<BaseItemDto> baseItems, {
    MediaItemType? overrideType,
  }) {
    return baseItems
        .map(
          (baseItem) => _parseMediaItem(baseItem, overrideType: overrideType),
        )
        .toList();
  }

  MediaItem _parseMediaItem(
    BaseItemDto baseItem, {
    MediaItemType? overrideType,
  }) {
    final type = overrideType ?? MediaItemType.fromString(baseItem.type?.name);

    int? introStart;
    int? introEnd;

    final chapters = baseItem.chapters;
    if (chapters != null && chapters.isNotEmpty) {
      for (var i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];
        final name = chapter.name?.toLowerCase() ?? '';
        if (name.contains('intro') || name.contains('opening')) {
          introStart = chapter.startPositionTicks;
          // The next chapter marks the end of the intro
          if (i + 1 < chapters.length) {
            introEnd = chapters[i + 1].startPositionTicks;
          }
          break;
        }
      }
    }

    return MediaItem(
      id: baseItem.id!,
      name: baseItem.name ?? 'Unknown',
      type: type,
      overview: baseItem.overview,
      productionYear: baseItem.productionYear?.toString(),
      endProductionYear: baseItem.endDate?.year.toString(),
      indexNumber: baseItem.indexNumber,
      parentIndexNumber: baseItem.parentIndexNumber,
      seriesId: baseItem.seriesId,
      seriesName: baseItem.seriesName,
      seasonId: baseItem.seasonId,
      runTimeTicks: baseItem.runTimeTicks,
      officialRating: baseItem.officialRating,
      childCount: baseItem.childCount,
      isPlayed: baseItem.userData?.played ?? false,
      mediaSourceId: baseItem.mediaSources?.firstOrNull?.id,
      people: baseItem.people
          ?.map(
            (p) => MediaPerson(
              id: p.id!,
              name: p.name ?? '',
              role: p.role ?? p.type?.name ?? '',
            ),
          )
          .toList(),
      introStartTicks: introStart,
      introEndTicks: introEnd,
      playbackPositionTicks: baseItem.userData?.playbackPositionTicks,
      collectionType: baseItem.collectionType?.value,
    );
  }
}
