import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/media/data/demo_data.dart';
import 'package:playcado/media/data/media_remote_data_source.dart';
import 'package:playcado/media/models/media_item.dart';

class DemoRemoteDataSource implements MediaRemoteDataSource {
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
    List<MediaItem> result = [];

    // Filter by type if specified
    if (includeItemTypes != null) {
      if (includeItemTypes.contains(BaseItemKind.movie)) {
        result.addAll(DemoData.movies);
      }
      if (includeItemTypes.contains(BaseItemKind.series)) {
        result.addAll(DemoData.series);
      }
    } else {
      // Default to both for demo
      result.addAll(DemoData.movies);
      result.addAll(DemoData.series);
    }

    // Filter by ID if specified
    if (ids != null) {
      result = result.where((item) => ids.contains(item.id)).toList();
    }

    // Search term
    if (searchTerm != null && searchTerm.isNotEmpty) {
      final query = searchTerm.toLowerCase();
      result = result
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }

    // Apply pagination
    final start = startIndex ?? 0;
    if (start >= result.length) return [];

    final end = (limit != null) ? (start + limit) : result.length;
    final finalEnd = (end > result.length) ? result.length : end;

    return result.sublist(start, finalEnd);
  }

  @override
  Future<List<MediaItem>> fetchViews({required String userId}) async {
    return [
      const MediaItem(
        id: 'movies_library',
        name: 'Movies',
        type: MediaItemType.collectionFolder,
        collectionType: 'movies',
      ),
      const MediaItem(
        id: 'tv_library',
        name: 'TV Shows',
        type: MediaItemType.collectionFolder,
        collectionType: 'tvshows',
      ),
      const MediaItem(
        id: 'home_videos_library',
        name: 'Home Videos',
        type: MediaItemType.collectionFolder,
        collectionType: 'homevideos',
      ),
    ];
  }

  @override
  Future<List<MediaItem>> fetchLatestMedia({
    required String userId,
    int? limit,
    List<BaseItemKind>? includeItemTypes,
    List<ItemFields>? fields,
  }) async {
    // Just return some movies for "Latest"
    final count = limit ?? 10;
    return DemoData.movies.take(count).toList();
  }

  @override
  Future<List<MediaItem>> fetchNextUp({
    required String userId,
    String? seriesId,
    int? limit,
    List<ItemFields>? fields,
  }) async {
    // Return the first episode of our demo series as "Next Up"
    return [DemoData.episodes.first];
  }

  @override
  Future<List<MediaItem>> fetchSeasons({
    required String userId,
    required String seriesId,
    List<ItemFields>? fields,
  }) async {
    return DemoData.seasons.where((s) => s.seriesId == seriesId).toList();
  }

  @override
  Future<List<MediaItem>> fetchEpisodes({
    required String userId,
    required String seriesId,
    required String seasonId,
    List<ItemFields>? fields,
  }) async {
    return DemoData.episodes.where((e) => e.seasonId == seasonId).toList();
  }

  @override
  Future<void> reportPlaybackStart({
    required String itemId,
    required PlayMethod playMethod,
  }) async {
    // No-op for demo
  }

  @override
  Future<void> reportPlaybackProgress({
    required String itemId,
    required int positionTicks,
    bool isPaused = false,
    PlayMethod playMethod = PlayMethod.directPlay,
  }) async {
    // No-op for demo
  }

  @override
  Future<void> reportPlaybackStopped({
    required String itemId,
    required int positionTicks,
  }) async {
    // No-op for demo
  }

  @override
  Future<void> markPlayedItem({
    required String userId,
    required String itemId,
  }) async {
    // No-op for demo
  }

  @override
  Future<void> markUnplayedItem({
    required String userId,
    required String itemId,
  }) async {
    // No-op for demo
  }

  @override
  Future<String?> getCurrentUserId() async {
    return 'demo_user';
  }
}
