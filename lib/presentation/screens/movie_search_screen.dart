import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/debounce.dart';
import '../../domain/entities/movie.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/movie_search/movie_search_bloc.dart';
import '../blocs/movie_search/movie_search_event.dart';
import '../blocs/movie_search/movie_search_state.dart';
import '../blocs/popular_movies/popular_movies_bloc.dart';
import '../blocs/popular_movies/popular_movies_event.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/movie_list_tile.dart';
import 'movie_detail_screen.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MovieSearchBloc>().add(const FetchMoreSearchResults());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }

  void _onQueryChanged(String query) {
    _debouncer.run(() {
      context.read<MovieSearchBloc>().add(SearchQueryChanged(query));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<MovieSearchBloc>().add(const ClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.searchTitle, style: AppTypography.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<MovieSearchBloc, MovieSearchState>(
        builder: (context, state) {
          if (state is MovieSearchInitial) {
            return EmptyView(
              icon: Icons.search_rounded,
              title: l10n.searchEmptyTitle,
              message: l10n.searchEmptyBody,
            );
          } else if (state is MovieSearchLoading) {
            return LoadingIndicator(message: l10n.searchLoading);
          } else if (state is MovieSearchEmpty) {
            return EmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.searchNoResultsTitle,
              message: l10n.searchNoResultsBody(state.query),
            );
          } else if (state is MovieSearchError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<MovieSearchBloc>().add(
                SearchQueryChanged(state.query),
              ),
            );
          } else if (state is MovieSearchLoaded) {
            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: state.movies.length + (state.isFetchingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.movies.length) {
                  return const LoadingIndicator(compact: true);
                }

                final movie = state.movies[index];
                return MovieListTile(
                  movie: movie,
                  onTap: () => _navigateToDetail(context, movie),
                  onFavoriteToggle: () => _toggleFavorite(context, movie),
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

  void _toggleFavorite(BuildContext context, Movie movie) {
    final newFavoriteStatus = !movie.isFavorite;

    // Update in Search Bloc
    context.read<MovieSearchBloc>().add(
      UpdateSearchMovieFavoriteStatus(
        movieId: movie.id,
        isFavorite: newFavoriteStatus,
      ),
    );

    // Sync with Popular Bloc
    context.read<PopularMoviesBloc>().add(
      UpdateMovieFavoriteStatus(
        movieId: movie.id,
        isFavorite: newFavoriteStatus,
      ),
    );

    // Persist in Favorites Bloc
    context.read<FavoritesBloc>().add(
      ToggleFavoriteMovie(movie.copyWith(isFavorite: newFavoriteStatus)),
    );
  }
}
