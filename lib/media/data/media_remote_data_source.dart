import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/media/models/media_item.dart';

abstract class MediaRemoteDataSource {
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
  });

  Future<List<MediaItem>> fetchViews({required String userId});

  Future<List<MediaItem>> fetchLatestMedia({
    required String userId,
    int? limit,
    List<BaseItemKind>? includeItemTypes,
    List<ItemFields>? fields,
  });

  Future<List<MediaItem>> fetchNextUp({
    required String userId,
    String? seriesId,
    int? limit,
    List<ItemFields>? fields,
  });

  Future<List<MediaItem>> fetchSeasons({
    required String userId,
    required String seriesId,
    List<ItemFields>? fields,
  });

  Future<List<MediaItem>> fetchEpisodes({
    required String userId,
    required String seriesId,
    required String seasonId,
    List<ItemFields>? fields,
  });

  Future<void> reportPlaybackStart({
    required String itemId,
    required PlayMethod playMethod,
  });

  Future<void> reportPlaybackProgress({
    required String itemId,
    required int positionTicks,
    bool isPaused = false,
    PlayMethod playMethod = PlayMethod.directPlay,
  });

  Future<void> reportPlaybackStopped({
    required String itemId,
    required int positionTicks,
  });

  Future<void> markPlayedItem({required String userId, required String itemId});

  Future<void> markUnplayedItem({
    required String userId,
    required String itemId,
  });

  Future<String?> getCurrentUserId();
}
