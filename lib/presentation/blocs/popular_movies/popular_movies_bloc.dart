import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/usecases/get_popular_movies.dart';
import 'popular_movies_event.dart';
import 'popular_movies_state.dart';

class PopularMoviesBloc extends Bloc<PopularMoviesEvent, PopularMoviesState> {
  final GetPopularMovies getPopularMovies;

  PopularMoviesBloc({required this.getPopularMovies})
      : super(const PopularMoviesInitial()) {
    on<FetchPopularMovies>(_onFetchPopularMovies);
    on<FetchMorePopularMovies>(_onFetchMorePopularMovies);
    on<RefreshPopularMovies>(_onRefreshPopularMovies);
    on<UpdateMovieFavoriteStatus>(_onUpdateMovieFavoriteStatus);
  }

  Future<void> _onFetchPopularMovies(
    FetchPopularMovies event,
    Emitter<PopularMoviesState> emit,
  ) async {
    emit(const PopularMoviesLoading());
    try {
      final movies = await getPopularMovies(page: 1);
      emit(PopularMoviesLoaded(
        movies: movies,
        hasReachedMax: movies.isEmpty,
        currentPage: 1,
      ));
    } on Failure catch (failure) {
      emit(PopularMoviesError(message: failure.message));
    } catch (e) {
      emit(PopularMoviesError(message: 'Failed to load popular movies: $e'));
    }
  }

  Future<void> _onFetchMorePopularMovies(
    FetchMorePopularMovies event,
    Emitter<PopularMoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PopularMoviesLoaded ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    final nextPage = currentState.currentPage + 1;
    try {
      final newMovies = await getPopularMovies(page: nextPage);
      if (newMovies.isEmpty) {
        emit(currentState.copyWith(
          hasReachedMax: true,
          isFetchingMore: false,
        ));
      } else {
        emit(currentState.copyWith(
          movies: List.of(currentState.movies)..addAll(newMovies),
          currentPage: nextPage,
          hasReachedMax: false,
          isFetchingMore: false,
        ));
      }
    } on Failure catch (_) {
      // In case pagination fails, we maintain the current list and reset fetching flag
      emit(currentState.copyWith(isFetchingMore: false));
    } catch (_) {
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }

  Future<void> _onRefreshPopularMovies(
    RefreshPopularMovies event,
    Emitter<PopularMoviesState> emit,
  ) async {
    try {
      final movies = await getPopularMovies(page: 1);
      emit(PopularMoviesLoaded(
        movies: movies,
        hasReachedMax: movies.isEmpty,
        currentPage: 1,
      ));
    } on Failure catch (failure) {
      emit(PopularMoviesError(message: failure.message));
    } catch (e) {
      emit(PopularMoviesError(message: 'Failed to refresh movies: $e'));
    }
  }

  void _onUpdateMovieFavoriteStatus(
    UpdateMovieFavoriteStatus event,
    Emitter<PopularMoviesState> emit,
  ) {
    if (state is PopularMoviesLoaded) {
      final loadedState = state as PopularMoviesLoaded;
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
