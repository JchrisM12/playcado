import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/home/bloc/home_bloc.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/media/repos/library_repository.dart';
import 'package:playcado/paginated_media_list/widgets/media_poster.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LoggerService.home.info('Building HomeScreen');
    return BlocProvider(
      create: (context) =>
          HomeBloc(libraryRepository: context.read<LibraryRepository>())
            ..add(LoadHomeContent()),
      child: const Scaffold(extendBodyBehindAppBar: true, body: _HomeContent()),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    bloc.add(LoadHomeContent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final hasError = context.select<HomeBloc, bool>(
      (bloc) =>
          bloc.state.latestMovies.isError ||
          bloc.state.nextUp.isError ||
          bloc.state.continueWatching.isError,
    );

    if (hasError) {
      return _HomeErrorView(onRetry: () => _refresh(context));
    }

    final playerActive = context.select<VideoPlayerBloc, bool>(
      (bloc) => bloc.state.isActive,
    );
    final bottomPadding =
        MediaQuery.paddingOf(context).bottom + 10 + (playerActive ? 70 : 0);

    // Calculate dimensions to match PaginatedMediaGrid (maxCrossAxisExtent: 160, ratio: 0.5)
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double availableWidth = screenWidth - 32; // 16px horizontal padding
    final int crossAxisCount = (availableWidth / 160).ceil();
    final double itemWidth =
        (availableWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
    final double itemHeight = itemWidth / 0.5;

    // Landscape dimensions for Up Next (slightly reduced width)
    final double nextUpWidth = screenWidth * 0.65;
    final double nextUpHeight = (nextUpWidth / 1.77) + 56;

    // Select only the global loading state for the initial data fetch
    final isInitialLoading = context.select<HomeBloc, bool>(
      (bloc) =>
          bloc.state.continueWatching.isLoading &&
          bloc.state.nextUp.isLoading &&
          bloc.state.latestMovies.value == null,
    );

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: CustomScrollView(
        cacheExtent: 1000,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _HomeAppBar(),
          if (isInitialLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    _MediaCarousel(
                      title: context.l10n.upNext,
                      items: null,
                      isLoading: true,
                      category: 'shimmer',
                      itemWidth: nextUpWidth,
                      itemHeight: nextUpHeight,
                      isLandscape: true,
                    ),
                    _MediaCarousel(
                      title: context.l10n.continueWatching,
                      items: null,
                      isLoading: true,
                      category: 'shimmer',
                      itemWidth: itemWidth,
                      itemHeight: itemHeight,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NextUpSection(width: nextUpWidth, height: nextUpHeight),
                    _ContinueWatchingSection(
                      width: itemWidth,
                      height: itemHeight,
                    ),
                    _LatestMoviesSection(width: itemWidth, height: itemHeight),
                    _LatestTvSection(width: itemWidth, height: itemHeight),
                    SizedBox(height: bottomPadding),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: IconTitle(title: context.l10n.playcado),
      centerTitle: true,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.7),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push(AppRouter.searchPath),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _HomeErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            context.l10n.unableToLoadContent,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.pleaseCheckYourConnectionAndTryAgain),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _ContinueWatchingSection extends StatelessWidget {
  final double width;
  final double height;
  const _ContinueWatchingSection({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (HomeBloc bloc) => bloc.state.continueWatching,
    );

    return _MediaCarousel(
      title: context.l10n.continueWatching,
      items: status.value,
      isLoading: status.isLoading,
      category: 'continue',
      itemWidth: width,
      itemHeight: height,
    );
  }
}

class _NextUpSection extends StatelessWidget {
  final double width;
  final double height;
  const _NextUpSection({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final status = context.select((HomeBloc bloc) => bloc.state.nextUp);

    return _MediaCarousel(
      title: context.l10n.upNext,
      items: status.value,
      isLoading: status.isLoading,
      category: 'upnext',
      itemWidth: width,
      itemHeight: height,
      isLandscape: true,
    );
  }
}

class _LatestMoviesSection extends StatelessWidget {
  final double width;
  final double height;
  const _LatestMoviesSection({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final status = context.select((HomeBloc bloc) => bloc.state.latestMovies);

    return _MediaCarousel(
      title: context.l10n.recentlyAddedMovies,
      items: status.value,
      isLoading: status.isLoading,
      category: 'latest_movies',
      onSeeAll: () => context.go(AppRouter.moviesPath),
      itemWidth: width,
      itemHeight: height,
    );
  }
}

class _LatestTvSection extends StatelessWidget {
  final double width;
  final double height;
  const _LatestTvSection({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final status = context.select((HomeBloc bloc) => bloc.state.latestTv);

    return _MediaCarousel(
      title: context.l10n.recentlyAddedTv,
      items: status.value,
      isLoading: status.isLoading,
      category: 'latest_tv',
      onSeeAll: () => context.go(AppRouter.tvPath),
      itemWidth: width,
      itemHeight: height,
    );
  }
}

class _MediaCarousel extends StatelessWidget {
  final String title;
  final List<MediaItem>? items;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final String category;
  final double itemWidth;
  final double itemHeight;
  final bool isLandscape;

  const _MediaCarousel({
    required this.title,
    required this.items,
    required this.category,
    required this.itemWidth,
    required this.itemHeight,
    this.isLoading = false,
    this.onSeeAll,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && (items == null || items!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onSeeAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (onSeeAll != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: itemHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemExtent: itemWidth + 12,
            itemCount: isLoading ? 5 : items!.length,
            itemBuilder: (context, index) {
              final item = items?[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: MediaPoster(
                  item: item,
                  heroTag: '${category}_${item?.id}_$index',
                  isLandscape: isLandscape,
                  isLoading: isLoading || item == null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
