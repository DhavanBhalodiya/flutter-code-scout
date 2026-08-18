import 'package:equatable/equatable.dart';
import '../../../domain/entities/movie.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FetchFavorites extends FavoritesEvent {
  const FetchFavorites();
}

class ToggleFavoriteMovie extends FavoritesEvent {
  final Movie movie;

  const ToggleFavoriteMovie(this.movie);

  @override
  List<Object?> get props => [movie];
}

class RemoveFavoriteMovie extends FavoritesEvent {
  final int movieId;

  const RemoveFavoriteMovie(this.movieId);

  @override
  List<Object?> get props => [movieId];
}
