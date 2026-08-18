import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/movie.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/popular_movies/popular_movies_bloc.dart';
import '../blocs/popular_movies/popular_movies_event.dart';
import '../blocs/popular_movies/popular_movies_state.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class PopularMoviesScreen extends StatefulWidget {
  const PopularMoviesScreen({super.key});

  @override
  State<PopularMoviesScreen> createState() => _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends State<PopularMoviesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PopularMoviesBloc>().add(const FetchMorePopularMovies());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.movie_creation_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Popular Movies', style: AppTypography.titleLarge),
          ],
        ),
      ),
      body: BlocBuilder<PopularMoviesBloc, PopularMoviesState>(
        builder: (context, state) {
          if (state is PopularMoviesLoading) {
            return const LoadingIndicator(message: 'Discovering popular movies...');
          } else if (state is PopularMoviesError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<PopularMoviesBloc>()
                  .add(const FetchPopularMovies()),
            );
          } else if (state is PopularMoviesLoaded) {
            if (state.movies.isEmpty) {
              return EmptyView(
                title: 'No Movies Found',
                message: 'Could not find any popular movies right now.',
                actionLabel: 'Refresh',
                onAction: () => context
                    .read<PopularMoviesBloc>()
                    .add(const RefreshPopularMovies()),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              onRefresh: () async {
                context
                    .read<PopularMoviesBloc>()
                    .add(const RefreshPopularMovies());
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final movie = state.movies[index];
                          return MovieCard(
                            movie: movie,
                            onTap: () => _navigateToDetail(context, movie),
                            onFavoriteToggle: () =>
                                _toggleFavorite(context, movie),
                          );
                        },
                        childCount: state.movies.length,
                      ),
                    ),
                  ),

                  // Pagination loading spinner
                  if (state.isFetchingMore)
                    const SliverToBoxAdapter(
                      child: LoadingIndicator(compact: true),
                    ),
                  if (state.hasReachedMax && state.movies.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            "You've reached the end of the list",
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MovieDetailScreen.route(
        movieId: movie.id,
        initialTitle: movie.title,
        initialPosterUrl: movie.posterUrl,
      ),
    );
  }

  void _toggleFavorite(BuildContext context, Movie movie) {
    // Optimistically toggle locally in PopularMoviesBloc
    final newFavoriteStatus = !movie.isFavorite;
    context.read<PopularMoviesBloc>().add(
          UpdateMovieFavoriteStatus(
            movieId: movie.id,
            isFavorite: newFavoriteStatus,
          ),
        );

    // Save to FavoritesBloc and persistence
    context.read<FavoritesBloc>().add(
          ToggleFavoriteMovie(movie.copyWith(isFavorite: newFavoriteStatus)),
        );
  }
}
