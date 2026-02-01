import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/paginated_media_list/bloc/paginated_media_list_bloc.dart';
import 'package:playcado/paginated_media_list/widgets/paginated_media_grid.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/widgets/widgets.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LoggerService.home.info('Building MoviesScreen');
    final repo = context.read<LibraryRepository>();

    return BlocProvider<PaginatedMediaListBloc>(
      create: (context) => PaginatedMediaListBloc(
        fetcher:
            ({
              required int startIndex,
              required int limit,
              required String sortBy,
              required String sortOrder,
            }) => repo.getMovies(
              startIndex: startIndex,
              limit: limit,
              sortBy: sortBy,
              sortOrder: sortOrder,
            ),
      )..add(PaginatedMediaListItemsFetched()),
      child: const Scaffold(extendBodyBehindAppBar: true, body: MoviesGrid()),
    );
  }
}

class MoviesGrid extends StatelessWidget {
  const MoviesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginatedMediaListBloc, PaginatedMediaListState>(
      builder: (context, state) {
        return PaginatedMediaGrid(
          title: context.l10n.movies,
          header: IconTitle(title: context.l10n.movies),
          items: state.items.value,
          isLoading: state.items.isLoading,
          isError: state.items.isError,
          hasReachedMax: state.hasReachedMax,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
          dateSortLabel: context.l10n.releaseDate,
          onLoadMore: () {
            context.read<PaginatedMediaListBloc>().add(
              PaginatedMediaListMoreItemsFetched(),
            );
          },
          onRefresh: () async {
            context.read<PaginatedMediaListBloc>().add(
              PaginatedMediaListItemsFetched(),
            );
            await Future.delayed(const Duration(milliseconds: 500));
          },
          onRetry: () {
            context.read<PaginatedMediaListBloc>().add(
              PaginatedMediaListItemsFetched(),
            );
          },
          onSortChanged: (sortBy, sortOrder) {
            context.read<PaginatedMediaListBloc>().add(
              PaginatedMediaListSortChanged(
                sortBy: sortBy,
                sortOrder: sortOrder,
              ),
            );
          },
        );
      },
    );
  }
}
