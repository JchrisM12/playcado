import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_item.g.dart';

enum MediaItemType {
  @JsonValue('Movie')
  movie,
  @JsonValue('Series')
  series,
  @JsonValue('Episode')
  episode,
  @JsonValue('Season')
  season,
  @JsonValue('CollectionFolder')
  collectionFolder,
  @JsonValue('Folder')
  folder,
  @JsonValue('Photo')
  photo,
  @JsonValue('Video')
  video,
  @JsonValue('Other')
  other;

  static MediaItemType fromString(String? value) {
    if (value == null) return MediaItemType.other;
    return MediaItemType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => MediaItemType.other,
    );
  }

  String get label {
    switch (this) {
      case MediaItemType.movie:
        return 'Movie';
      case MediaItemType.series:
        return 'Series';
      case MediaItemType.episode:
        return 'Episode';
      case MediaItemType.season:
        return 'Season';
      case MediaItemType.collectionFolder:
        return 'Collection';
      case MediaItemType.folder:
        return 'Folder';
      case MediaItemType.photo:
        return 'Photo';
      case MediaItemType.video:
        return 'Video';
      case MediaItemType.other:
        return 'Other';
    }
  }
}

@JsonSerializable()
class MediaItem extends Equatable {
  final String id;
  final String name;
  final MediaItemType? type;
  final String? overview;
  final String? productionYear;
  final String? endProductionYear;
  final int? indexNumber;
  final int? parentIndexNumber;
  final String? seriesId;
  final String? seriesName;
  final String? seasonId;
  final int? runTimeTicks; // Added for download estimation
  final String? officialRating;
  final int? childCount;
  final bool isPlayed;
  final String? mediaSourceId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<MediaPerson>? people;
  final int? introStartTicks;
  final int? introEndTicks;
  final int? playbackPositionTicks;
  final String? collectionType;

  const MediaItem({
    required this.id,
    required this.name,
    this.type,
    this.overview,
    this.productionYear,
    this.endProductionYear,
    this.indexNumber,
    this.parentIndexNumber,
    this.seriesId,
    this.seriesName,
    this.seasonId,
    this.runTimeTicks,
    this.officialRating,
    this.childCount,
    this.isPlayed = false,
    this.mediaSourceId,
    this.people,
    this.introStartTicks,
    this.introEndTicks,
    this.playbackPositionTicks,
    this.collectionType,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  Map<String, dynamic> toJson() => _$MediaItemToJson(this);

  MediaItem copyWith({
    String? id,
    String? name,
    MediaItemType? type,
    String? overview,
    String? productionYear,
    String? endProductionYear,
    int? indexNumber,
    int? parentIndexNumber,
    String? seriesId,
    String? seriesName,
    String? seasonId,
    int? runTimeTicks,
    String? officialRating,
    int? childCount,
    bool? isPlayed,
    String? mediaSourceId,
    List<MediaPerson>? people,
    int? introStartTicks,
    int? introEndTicks,
    int? playbackPositionTicks,
    String? collectionType,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      overview: overview ?? this.overview,
      productionYear: productionYear ?? this.productionYear,
      endProductionYear: endProductionYear ?? this.endProductionYear,
      indexNumber: indexNumber ?? this.indexNumber,
      parentIndexNumber: parentIndexNumber ?? this.parentIndexNumber,
      seriesId: seriesId ?? this.seriesId,
      seriesName: seriesName ?? this.seriesName,
      seasonId: seasonId ?? this.seasonId,
      runTimeTicks: runTimeTicks ?? this.runTimeTicks,
      officialRating: officialRating ?? this.officialRating,
      childCount: childCount ?? this.childCount,
      isPlayed: isPlayed ?? this.isPlayed,
      mediaSourceId: mediaSourceId ?? this.mediaSourceId,
      people: people ?? this.people,
      introStartTicks: introStartTicks ?? this.introStartTicks,
      introEndTicks: introEndTicks ?? this.introEndTicks,
      playbackPositionTicks:
          playbackPositionTicks ?? this.playbackPositionTicks,
      collectionType: collectionType ?? this.collectionType,
    );
  }

  @override
  String toString() {
    // Concise logging to avoid flooding console with Overviews
    return 'MediaItem(name: "$name", id: $id, type: $type)';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    overview,
    productionYear,
    endProductionYear,
    indexNumber,
    parentIndexNumber,
    seriesId,
    seriesName,
    seasonId,
    runTimeTicks,
    officialRating,
    childCount,
    isPlayed,
    mediaSourceId,
    people,
    introStartTicks,
    introEndTicks,
    playbackPositionTicks,
    collectionType,
  ];

  /// The movie title for movies
  /// The series title for series
  /// The episode title with season and episode number for episodes
  String get displayTitle {
    if (type == MediaItemType.episode) {
      return '$name - S$parentIndexNumber E$indexNumber';
    }
    return name;
  }

  /// The production year for movies
  /// The series name for series
  /// The season and episode number and series name for episodes
  String? get displaySubtitle {
    if (type == MediaItemType.episode) {
      final s = parentIndexNumber;
      final e = indexNumber;
      if (s != null && e != null) {
        return 'S$s E$e • $name';
      } else if (e != null) {
        return 'E$e • $name';
      }
      return name;
    }

    if (type == MediaItemType.series) {
      if (productionYear != null) {
        if (endProductionYear != null) {
          if (endProductionYear == productionYear) return productionYear;
          return '$productionYear – $endProductionYear';
        }
        return '$productionYear – ';
      }
      return 'Series';
    }

    return productionYear;
  }

  /// Formatted runtime: "1h 42m" or "42m"
  String? get formattedRuntime {
    if (runTimeTicks == null) return null;
    final duration = Duration(microseconds: runTimeTicks! ~/ 10);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Formatted season count: "4 Seasons"
  String? get formattedSeasonCount {
    if (type != MediaItemType.series || childCount == null) return null;
    return childCount == 1 ? '1 Season' : '$childCount Seasons';
  }

  /// Generates a consistent hero tag for the item
  String heroTag([String prefix = 'poster']) {
    return '${prefix}_$id';
  }

  /// Standardized filename for downloads: "Series (S01E01)" or "Movie (Year)"
  String get formattedFileName {
    if (type == MediaItemType.episode) {
      final series = seriesName ?? name;
      final season = parentIndexNumber?.toString().padLeft(2, '0') ?? '00';
      final episode = indexNumber?.toString().padLeft(2, '0') ?? '00';
      return '$series (S${season}E$episode)';
    }

    final yearStr = productionYear != null ? ' ($productionYear)' : '';
    return '$name$yearStr';
  }
}

class MediaPerson extends Equatable {
  final String id;
  final String name;
  final String? role;

  const MediaPerson({required this.id, required this.name, this.role});

  @override
  List<Object?> get props => [id, name, role];
}
