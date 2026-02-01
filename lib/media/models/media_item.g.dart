// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecodeNullable(_$MediaItemTypeEnumMap, json['type']),
  overview: json['overview'] as String?,
  productionYear: json['productionYear'] as String?,
  endProductionYear: json['endProductionYear'] as String?,
  indexNumber: (json['indexNumber'] as num?)?.toInt(),
  parentIndexNumber: (json['parentIndexNumber'] as num?)?.toInt(),
  seriesId: json['seriesId'] as String?,
  seriesName: json['seriesName'] as String?,
  seasonId: json['seasonId'] as String?,
  runTimeTicks: (json['runTimeTicks'] as num?)?.toInt(),
  officialRating: json['officialRating'] as String?,
  childCount: (json['childCount'] as num?)?.toInt(),
  isPlayed: json['isPlayed'] as bool? ?? false,
  mediaSourceId: json['mediaSourceId'] as String?,
  introStartTicks: (json['introStartTicks'] as num?)?.toInt(),
  introEndTicks: (json['introEndTicks'] as num?)?.toInt(),
  playbackPositionTicks: (json['playbackPositionTicks'] as num?)?.toInt(),
  collectionType: json['collectionType'] as String?,
);

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$MediaItemTypeEnumMap[instance.type],
  'overview': instance.overview,
  'productionYear': instance.productionYear,
  'endProductionYear': instance.endProductionYear,
  'indexNumber': instance.indexNumber,
  'parentIndexNumber': instance.parentIndexNumber,
  'seriesId': instance.seriesId,
  'seriesName': instance.seriesName,
  'seasonId': instance.seasonId,
  'runTimeTicks': instance.runTimeTicks,
  'officialRating': instance.officialRating,
  'childCount': instance.childCount,
  'isPlayed': instance.isPlayed,
  'mediaSourceId': instance.mediaSourceId,
  'introStartTicks': instance.introStartTicks,
  'introEndTicks': instance.introEndTicks,
  'playbackPositionTicks': instance.playbackPositionTicks,
  'collectionType': instance.collectionType,
};

const _$MediaItemTypeEnumMap = {
  MediaItemType.movie: 'Movie',
  MediaItemType.series: 'Series',
  MediaItemType.episode: 'Episode',
  MediaItemType.season: 'Season',
  MediaItemType.collectionFolder: 'CollectionFolder',
  MediaItemType.folder: 'Folder',
  MediaItemType.photo: 'Photo',
  MediaItemType.video: 'Video',
  MediaItemType.other: 'Other',
};
