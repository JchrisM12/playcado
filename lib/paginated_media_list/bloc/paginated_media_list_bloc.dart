import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/status_wrapper.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/logger_service.dart';

part 'paginated_media_list_event.dart';
part 'paginated_media_list_state.dart';

typedef PaginatedMediaFetcher =
    Future<List<MediaItem>> Function({
      required int startIndex,
      required int limit,
      required String sortBy,
      required String sortOrder,
    });

class PaginatedMediaListBloc
    extends Bloc<PaginatedMediaListEvent, PaginatedMediaListState> {
  final PaginatedMediaFetcher _fetcher;
  static const int _limit = 20;

  PaginatedMediaListBloc({required PaginatedMediaFetcher fetcher})
    : _fetcher = fetcher,
      super(const PaginatedMediaListState()) {
    on<PaginatedMediaListItemsFetched>(_onFetchItems);
    on<PaginatedMediaListMoreItemsFetched>(_onLoadMoreItems);
    on<PaginatedMediaListSortChanged>(_onChangeSort);
  }

  Future<void> _onFetchItems(
    PaginatedMediaListItemsFetched event,
    Emitter<PaginatedMediaListState> emit,
  ) async {
    emit(state.copyWith(items: state.items.toLoading(), hasReachedMax: false));

    try {
      final items = await _fetcher(
        startIndex: 0,
        limit: _limit,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );

      emit(
        state.copyWith(
          items: state.items.toSuccess(items),
          hasReachedMax: items.length < _limit,
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to fetch items', e, stackTrace);
      emit(state.copyWith(items: state.items.toError()));
    }
  }

  Future<void> _onLoadMoreItems(
    PaginatedMediaListMoreItemsFetched event,
    Emitter<PaginatedMediaListState> emit,
  ) async {
    if (state.hasReachedMax || state.items.isLoading) return;

    try {
      final currentItems = state.items.value ?? [];
      final newItems = await _fetcher(
        startIndex: currentItems.length,
        limit: _limit,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );

      if (newItems.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            items: state.items.toSuccess(currentItems + newItems),
            hasReachedMax: newItems.length < _limit,
          ),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to load more items', e, stackTrace);
    }
  }

  Future<void> _onChangeSort(
    PaginatedMediaListSortChanged event,
    Emitter<PaginatedMediaListState> emit,
  ) async {
    if (state.sortBy == event.sortBy && state.sortOrder == event.sortOrder) {
      return;
    }

    emit(
      state.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        items: state.items.toLoading(),
        hasReachedMax: false,
      ),
    );

    try {
      final items = await _fetcher(
        startIndex: 0,
        limit: _limit,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );

      emit(
        state.copyWith(
          items: state.items.toSuccess(items),
          hasReachedMax: items.length < _limit,
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.media.severe('Failed to sort items', e, stackTrace);
      emit(state.copyWith(items: state.items.toError()));
    }
  }
}
