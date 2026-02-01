part of 'paginated_media_list_bloc.dart';

abstract class PaginatedMediaListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PaginatedMediaListItemsFetched extends PaginatedMediaListEvent {}

class PaginatedMediaListMoreItemsFetched extends PaginatedMediaListEvent {}

class PaginatedMediaListSortChanged extends PaginatedMediaListEvent {
  final String sortBy;
  final String sortOrder;

  PaginatedMediaListSortChanged({
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  List<Object> get props => [sortBy, sortOrder];
}
