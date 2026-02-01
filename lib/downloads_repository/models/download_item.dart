import 'package:equatable/equatable.dart';
import 'package:playcado/media/models/media_item.dart';

enum DownloadStatus { queued, downloading, paused, completed, error }

class DownloadItem extends Equatable {
  final String id;
  final String name;
  final String? overview;
  final String? imageUrl;
  final MediaItemType? type;
  final String downloadUrl;
  final String localPath;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final int receivedBytes;
  final int totalBytes;
  final double? networkSpeed; // bytes per second
  final int? lastUpdateTimeMs; // For calculating time deltas

  const DownloadItem({
    required this.id,
    required this.name,
    this.overview,
    this.imageUrl,
    this.type,
    required this.downloadUrl,
    required this.localPath,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.networkSpeed,
    this.lastUpdateTimeMs,
  });

  DownloadItem copyWith({
    String? name,
    String? overview,
    String? imageUrl,
    MediaItemType? type,
    String? downloadUrl,
    String? localPath,
    DownloadStatus? status,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    double? networkSpeed,
    int? lastUpdateTimeMs,
  }) {
    return DownloadItem(
      id: id,
      name: name ?? this.name,
      overview: overview ?? this.overview,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      networkSpeed: networkSpeed ?? this.networkSpeed,
      lastUpdateTimeMs: lastUpdateTimeMs ?? this.lastUpdateTimeMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'imageUrl': imageUrl,
      'type': type?.name,
      'downloadUrl': downloadUrl,
      'localPath': localPath,
      'status': status.index,
      'progress': progress,
      'receivedBytes': receivedBytes,
      'totalBytes': totalBytes,
      'networkSpeed': networkSpeed,
      'lastUpdateTimeMs': lastUpdateTimeMs,
    };
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      imageUrl: json['imageUrl'],
      type: json['type'] != null
          ? MediaItemType.fromString(json['type'])
          : null,
      downloadUrl: json['downloadUrl'],
      localPath: json['localPath'],
      status: DownloadStatus.values[json['status'] ?? 0],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      receivedBytes: json['receivedBytes'] ?? 0,
      totalBytes: json['totalBytes'] ?? 0,
      networkSpeed: (json['networkSpeed'] as num?)?.toDouble(),
      lastUpdateTimeMs: json['lastUpdateTimeMs'],
    );
  }

  @override
  String toString() {
    final pct = (progress * 100).toStringAsFixed(1);
    return 'DownloadItem(name: "$name", status: $status, progress: $pct%)';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    imageUrl,
    type,
    downloadUrl,
    localPath,
    status,
    progress,
    receivedBytes,
    totalBytes,
    networkSpeed,
    lastUpdateTimeMs,
  ];
}
