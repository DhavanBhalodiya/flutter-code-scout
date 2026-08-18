import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/usecases/search_movies.dart';
import 'movie_search_event.dart';
import 'movie_search_state.dart';

class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  final SearchMovies searchMovies;

  MovieSearchBloc({required this.searchMovies})
      : super(const MovieSearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FetchMoreSearchResults>(_onFetchMoreSearchResults);
    on<ClearSearch>(_onClearSearch);
    on<UpdateSearchMovieFavoriteStatus>(_onUpdateSearchMovieFavoriteStatus);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MovieSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const MovieSearchInitial());
      return;
    }

    emit(const MovieSearchLoading());

    try {
      final movies = await searchMovies(query: query, page: 1);
      if (movies.isEmpty) {
        emit(MovieSearchEmpty(query: query));
      } else {
        emit(MovieSearchLoaded(
          movies: movies,
          query: query,
          currentPage: 1,
          hasReachedMax: movies.length < 20,
        ));
      }
    } on Failure catch (failure) {
      emit(MovieSearchError(message: failure.message, query: query));
    } catch (e) {
      emit(MovieSearchError(
        message: 'Failed to search movies: $e',
        query: query,
      ));
    }
  }

  Future<void> _onFetchMoreSearchResults(
    FetchMoreSearchResults event,
    Emitter<MovieSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MovieSearchLoaded ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    final nextPage = currentState.currentPage + 1;
    try {
      final newMovies = await searchMovies(
        query: currentState.query,
        page: nextPage,
      );

      if (newMovies.isEmpty) {
        emit(currentState.copyWith(
          hasReachedMax: true,
          isFetchingMore: false,
        ));
      } else {
        emit(currentState.copyWith(
          movies: List.of(currentState.movies)..addAll(newMovies),
          currentPage: nextPage,
          hasReachedMax: newMovies.length < 20,
          isFetchingMore: false,
        ));
      }
    } on Failure catch (_) {
      emit(currentState.copyWith(isFetchingMore: false));
    } catch (_) {
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<MovieSearchState> emit,
  ) {
    emit(const MovieSearchInitial());
  }

  void _onUpdateSearchMovieFavoriteStatus(
    UpdateSearchMovieFavoriteStatus event,
    Emitter<MovieSearchState> emit,
  ) {
    if (state is MovieSearchLoaded) {
      final loadedState = state as MovieSearchLoaded;
      final updatedMovies = loadedState.movies.map((movie) {
        if (movie.id == event.movieId) {
          return movie.copyWith(isFavorite: event.isFavorite);
        }
        return movie;
      }).toList();
      emit(loadedState.copyWith(movies: updatedMovies));
    }
  }
}
