import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/movie.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/favorites/favorites_state.dart';
import '../blocs/movie_search/movie_search_bloc.dart';
import '../blocs/movie_search/movie_search_event.dart';
import '../blocs/popular_movies/popular_movies_bloc.dart';
import '../blocs/popular_movies/popular_movies_event.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/movie_list_tile.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const FavoritesScreen({super.key, this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Favorites', style: AppTypography.titleLarge),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const LoadingIndicator(message: 'Loading your favorites...');
          } else if (state is FavoritesError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<FavoritesBloc>().add(const FetchFavorites()),
            );
          } else if (state is FavoritesEmpty) {
            return EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              message:
                  'Mark movies as favorites to easily access them offline anytime.',
              actionLabel: 'Explore Movies',
              onAction: onExploreTap,
            );
          } else if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return EmptyView(
                icon: Icons.favorite_border_rounded,
                title: 'No Favorites Yet',
                message:
                    'Mark movies as favorites to easily access them offline anytime.',
                actionLabel: 'Explore Movies',
                onAction: onExploreTap,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = state.favorites[index];
                return MovieListTile(
                  movie: movie,
                  onTap: () => _navigateToDetail(context, movie),
                  onFavoriteToggle: () => _removeFavorite(context, movie),
                );
              },
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

  void _removeFavorite(BuildContext context, Movie movie) {
    // Remove from favorites
    context.read<FavoritesBloc>().add(RemoveFavoriteMovie(movie.id));

    // Update synchronization in popular & search bloc
    context.read<PopularMoviesBloc>().add(
          UpdateMovieFavoriteStatus(
            movieId: movie.id,
            isFavorite: false,
          ),
        );
    context.read<MovieSearchBloc>().add(
          UpdateSearchMovieFavoriteStatus(
            movieId: movie.id,
            isFavorite: false,
          ),
        );
  }
}
