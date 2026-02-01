part of 'libraries_bloc.dart';

class LibrariesState extends Equatable {
  final StatusWrapper<List<MediaItem>> libraries;

  const LibrariesState({this.libraries = const StatusWrapper()});

  LibrariesState copyWith({StatusWrapper<List<MediaItem>>? libraries}) {
    return LibrariesState(libraries: libraries ?? this.libraries);
  }

  @override
  List<Object> get props => [libraries];
}
