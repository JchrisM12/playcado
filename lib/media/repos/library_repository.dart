import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/media/data/media_remote_data_source.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/logger_service.dart';

class LibraryRepository {
  final MediaRemoteDataSource _dataSource;

  LibraryRepository({required MediaRemoteDataSource dataSource})
    : _dataSource = dataSource;

  Future<List<MediaItem>> getMovies({
    int startIndex = 0,
    int limit = 20,
    String sortBy = 'SortName',
    String sortOrder = 'Ascending',
  }) async {
    try {
      LoggerService.api.info(
        'Fetching movies: Start=$startIndex, Limit=$limit, Sort=$sortBy/$sortOrder',
      );
      final currentUserId = await _dataSource.getCurrentUserId();

      if (currentUserId == null) throw Exception('Unable to get current user');

      final order = sortOrder == 'Ascending'
          ? SortOrder.ascending
          : SortOrder.descending;

      ItemSortBy itemSortBy;
      switch (sortBy) {
        case 'PremiereDate':
          itemSortBy = ItemSortBy.premiereDate;
          break;
        case 'DateCreated':
          itemSortBy = ItemSortBy.dateCreated;
          break;
        case 'SortName':
        default:
          itemSortBy = ItemSortBy.sortName;
          break;
      }

      final items = await _dataSource.fetchItems(
        userId: currentUserId,
        startIndex: startIndex,
        limit: limit,
        includeItemTypes: [BaseItemKind.movie],
        recursive: true,
        sortBy: [itemSortBy],
        sortOrder: [order],
        fields: [ItemFields.overview, ItemFields.mediaSources],
      );

      LoggerService.api.info('Fetched ${items.length} movies');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching movies', e, s);
      rethrow;
    }
  }

  Future<MediaItem> getItem(String id) async {
    try {
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchItems(
        userId: currentUserId,
        ids: [id],
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.people,
          ItemFields.chapters,
          ItemFields.childCount,
        ],
      );

      final item = items.firstOrNull;
      if (item == null) throw Exception('Item not found');

      return item;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching item $id', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getTvShows({
    int startIndex = 0,
    int limit = 20,
    String sortBy = 'SortName',
    String sortOrder = 'Ascending',
  }) async {
    try {
      LoggerService.api.info(
        'Fetching TV Shows: Start=$startIndex, Limit=$limit, Sort=$sortBy/$sortOrder',
      );
      final currentUserId = await _dataSource.getCurrentUserId();

      if (currentUserId == null) throw Exception('Unable to get current user');

      final order = sortOrder == 'Ascending'
          ? SortOrder.ascending
          : SortOrder.descending;

      ItemSortBy itemSortBy;
      switch (sortBy) {
        case 'PremiereDate':
          itemSortBy = ItemSortBy.premiereDate;
          break;
        case 'DateCreated':
          itemSortBy = ItemSortBy.dateCreated;
          break;
        case 'SortName':
        default:
          itemSortBy = ItemSortBy.sortName;
          break;
      }

      final items = await _dataSource.fetchItems(
        userId: currentUserId,
        startIndex: startIndex,
        limit: limit,
        includeItemTypes: [BaseItemKind.series],
        recursive: true,
        sortBy: [itemSortBy],
        sortOrder: [order],
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.childCount,
        ],
      );

      LoggerService.api.info('Fetched ${items.length} TV shows');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching TV shows', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getLatestTvShows() async {
    try {
      LoggerService.api.info('Fetching latest TV shows');
      final currentUserId = await _dataSource.getCurrentUserId();

      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchLatestMedia(
        userId: currentUserId,
        limit: 20,
        includeItemTypes: [BaseItemKind.series],
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.childCount,
        ],
      );

      LoggerService.api.info('Fetched ${items.length} latest TV shows');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching latest TV shows', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getLatestMovies() async {
    try {
      LoggerService.api.info('Fetching latest Movies');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchLatestMedia(
        userId: currentUserId,
        limit: 20,
        includeItemTypes: [BaseItemKind.movie],
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.childCount,
        ],
      );

      LoggerService.api.info('Fetched ${items.length} latest movies');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching latest movies', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getResumeItems() async {
    try {
      LoggerService.api.info('Fetching Resume items');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchItems(
        userId: currentUserId,
        limit: 20,
        recursive: true,
        filters: [ItemFilter.isResumable],
        sortBy: [ItemSortBy.datePlayed],
        sortOrder: [SortOrder.descending],
        includeItemTypes: [BaseItemKind.movie, BaseItemKind.episode],
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.people,
          ItemFields.chapters,
        ],
      );

      LoggerService.api.info('Fetched ${items.length} resume items');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching resume items', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getNextUpItems() async {
    try {
      LoggerService.api.info('Fetching Next Up items');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchNextUp(
        userId: currentUserId,
        limit: 20,
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.people,
          ItemFields.chapters,
          ItemFields.childCount,
        ],
      );

      LoggerService.api.info('Fetched ${items.length} next up items');

      final Map<String, MediaItem> uniqueSeriesMap = {};

      for (final item in items) {
        if (item.seriesId != null && item.seriesName != null) {
          final seriesId = item.seriesId!;
          if (!uniqueSeriesMap.containsKey(seriesId)) {
            uniqueSeriesMap[seriesId] = item;
          }
        } else {
          final id = item.id;
          if (!uniqueSeriesMap.containsKey(id)) {
            uniqueSeriesMap[id] = item;
          }
        }
      }

      return uniqueSeriesMap.values.toList();
    } catch (e, s) {
      LoggerService.api.severe('Error fetching next up items', e, s);
      rethrow;
    }
  }

  Future<MediaItem?> getNextEpisode(String seriesId) async {
    try {
      LoggerService.api.info('Fetching Next Episode for Series: $seriesId');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchNextUp(
        userId: currentUserId,
        seriesId: seriesId,
        limit: 1,
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.people,
          ItemFields.chapters,
        ],
      );

      if (items.isEmpty) return null;

      return items.first;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching next episode', e, s);
      return null;
    }
  }

  Future<MediaItem?> getFirstEpisode(String seriesId) async {
    try {
      LoggerService.api.info('Fetching First Episode for Series: $seriesId');

      final seasons = await getSeasons(seriesId);
      if (seasons.isEmpty) return null;

      // Try to find the first season (excluding Specials/Season 0 if others exist)
      final regularSeasons = seasons
          .where((s) => (s.indexNumber ?? 0) > 0)
          .toList();
      final seasonToUse = regularSeasons.isNotEmpty
          ? regularSeasons.first
          : seasons.first;

      final episodes = await getEpisodes(
        seriesId: seriesId,
        seasonId: seasonToUse.id,
      );
      if (episodes.isEmpty) return null;

      return episodes.first;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching first episode', e, s);
      return null;
    }
  }

  Future<List<MediaItem>> getSeasons(String seriesId) async {
    try {
      LoggerService.api.info('Fetching seasons for series: $seriesId');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchSeasons(
        userId: currentUserId,
        seriesId: seriesId,
        fields: [ItemFields.overview],
      );

      LoggerService.api.info('Fetched ${items.length} seasons');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching seasons', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getEpisodes({
    required String seriesId,
    required String seasonId,
  }) async {
    try {
      LoggerService.api.info(
        'Fetching episodes for Season: $seasonId (Series: $seriesId)',
      );
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchEpisodes(
        userId: currentUserId,
        seriesId: seriesId,
        seasonId: seasonId,
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.people,
          ItemFields.chapters,
        ],
      );

      LoggerService.api.info('Fetched ${items.length} episodes');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching episodes', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getLibraries() async {
    try {
      LoggerService.api.info('Fetching user libraries');
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final items = await _dataSource.fetchViews(userId: currentUserId);

      LoggerService.api.info('Fetched ${items.length} libraries');
      return items;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching libraries', e, s);
      rethrow;
    }
  }

  Future<List<MediaItem>> getLibraryItems({
    required String parentId,
    String? collectionType,
    int startIndex = 0,
    int limit = 20,
    String sortBy = 'SortName',
    String sortOrder = 'Ascending',
  }) async {
    try {
      LoggerService.api.info(
        'Fetching items for library $parentId: Start=$startIndex, Limit=$limit, Sort=$sortBy/$sortOrder',
      );
      final currentUserId = await _dataSource.getCurrentUserId();
      if (currentUserId == null) throw Exception('Unable to get current user');

      final order = sortOrder == 'Ascending'
          ? SortOrder.ascending
          : SortOrder.descending;

      ItemSortBy itemSortBy;
      switch (sortBy) {
        case 'PremiereDate':
          itemSortBy = ItemSortBy.premiereDate;
          break;
        case 'DateCreated':
          itemSortBy = ItemSortBy.dateCreated;
          break;
        case 'SortName':
        default:
          itemSortBy = ItemSortBy.sortName;
          break;
      }

      final items = await _dataSource.fetchItems(
        userId: currentUserId,
        parentId: parentId,
        startIndex: startIndex,
        limit: limit,
        recursive: true,
        sortBy: [itemSortBy],
        sortOrder: [order],
        fields: [
          ItemFields.overview,
          ItemFields.mediaSources,
          ItemFields.childCount,
        ],
      );

      // Filter out redundant folders when browsing a library recursively
      final filteredItems = items
          .where(
            (item) =>
                item.type != MediaItemType.folder &&
                item.type != MediaItemType.collectionFolder,
          )
          .toList();

      LoggerService.api.info(
        'Fetched ${items.length} items from library $parentId (filtered to ${filteredItems.length})',
      );
      return filteredItems;
    } catch (e, s) {
      LoggerService.api.severe('Error fetching library items', e, s);
      rethrow;
    }
  }
}
