part of 'libraries_bloc.dart';

abstract class LibrariesEvent extends Equatable {
  const LibrariesEvent();

  @override
  List<Object> get props => [];
}

class LibrariesLibariesFetched extends LibrariesEvent {}
