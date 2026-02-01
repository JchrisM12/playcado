import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/status_wrapper.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/services/logger_service.dart';

part 'libraries_event.dart';
part 'libraries_state.dart';

class LibrariesBloc extends Bloc<LibrariesEvent, LibrariesState> {
  final LibraryRepository _libraryRepository;

  LibrariesBloc({required LibraryRepository libraryRepository})
    : _libraryRepository = libraryRepository,
      super(const LibrariesState()) {
    on<LibrariesLibariesFetched>(_onLoadLibraries);
  }

  Future<void> _onLoadLibraries(
    LibrariesLibariesFetched event,
    Emitter<LibrariesState> emit,
  ) async {
    emit(state.copyWith(libraries: state.libraries.toLoading()));

    try {
      final libraries = await _libraryRepository.getLibraries();

      // Filter libraries to only show supported collection types
      // Standard types in Jellyfin: 'movies', 'tvshows', 'homevideos', 'music', 'books', 'photos', 'games', 'livetv', 'playlists', 'folders'
      final supportedLibraries = libraries.where((lib) {
        final type = lib.collectionType?.toLowerCase();
        return type == 'movies' ||
            type == 'tvshows' ||
            type == 'homevideos' ||
            type == 'photos' ||
            type == 'music';
      }).toList();

      emit(
        state.copyWith(
          libraries: state.libraries.toSuccess(supportedLibraries),
        ),
      );
    } catch (e, stack) {
      LoggerService.api.severe('Failed to load libraries', e, stack);
      emit(state.copyWith(libraries: state.libraries.toError()));
    }
  }
}
