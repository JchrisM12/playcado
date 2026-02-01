import 'package:playcado/media/models/media_item.dart';

abstract class MediaUrlService {
  String getImageUrl(String itemId);
  String getBackdropUrl(String itemId);
  String getStreamUrl(String itemId);
  String getDownloadUrl(String itemId, {int? maxHeight});
  String generateTranscodeUrl({
    required String itemId,
    required String mediaSourceId,
  });
}

extension MediaUrlServiceExtensions on MediaUrlService {
  /// Gets the best backdrop URL for an item, falling back to the primary image for photos/videos
  /// and the series backdrop for episodes.
  String getItemBackdropUrl(MediaItem item) {
    if (item.type == MediaItemType.photo || item.type == MediaItemType.video) {
      return getImageUrl(item.id);
    }

    final backdropId =
        (item.type == MediaItemType.episode && item.seriesId != null)
        ? item.seriesId!
        : item.id;
    return getBackdropUrl(backdropId);
  }

  /// Gets the best poster/thumbnail URL for an item.
  /// If [isLandscape] is true, it attempts to get a backdrop-style image or episode grab.
  String getItemImageUrl(MediaItem item, {bool isLandscape = false}) {
    if (isLandscape) {
      final bool usePrimary =
          item.type == MediaItemType.photo || item.type == MediaItemType.video;
      return (item.type == MediaItemType.episode || usePrimary)
          ? getImageUrl(item.id)
          : getBackdropUrl(item.id);
    } else {
      final posterId =
          (item.type == MediaItemType.episode && item.seriesId != null)
          ? item.seriesId!
          : item.id;
      return getImageUrl(posterId);
    }
  }
}
