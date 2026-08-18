import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/usecases/get_favorite_movies.dart';
import '../../../domain/usecases/toggle_favorite.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteMovies getFavoriteMovies;
  final ToggleFavorite toggleFavorite;

  FavoritesBloc({
    required this.getFavoriteMovies,
    required this.toggleFavorite,
  }) : super(const FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<ToggleFavoriteMovie>(_onToggleFavoriteMovie);
    on<RemoveFavoriteMovie>(_onRemoveFavoriteMovie);
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    try {
      final favorites = await getFavoriteMovies();
      if (favorites.isEmpty) {
        emit(const FavoritesEmpty());
      } else {
        emit(FavoritesLoaded(favorites: favorites));
      }
    } on Failure catch (failure) {
      emit(FavoritesError(message: failure.message));
    } catch (e) {
      emit(FavoritesError(message: 'Failed to load favorites: $e'));
    }
  }

  Future<void> _onToggleFavoriteMovie(
    ToggleFavoriteMovie event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await toggleFavorite(movie: event.movie);
      // Reload favorites list
      final favorites = await getFavoriteMovies();
      if (favorites.isEmpty) {
        emit(const FavoritesEmpty());
      } else {
        emit(FavoritesLoaded(favorites: favorites));
      }
    } on Failure catch (failure) {
      emit(FavoritesError(message: failure.message));
    } catch (e) {
      emit(FavoritesError(message: 'Failed to update favorite: $e'));
    }
  }

  Future<void> _onRemoveFavoriteMovie(
    RemoveFavoriteMovie event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final target = currentState.favorites.firstWhere(
        (m) => m.id == event.movieId,
        orElse: () => currentState.favorites.first,
      );
      if (target.id == event.movieId) {
        await _onToggleFavoriteMovie(ToggleFavoriteMovie(target), emit);
      }
    }
  }
}
