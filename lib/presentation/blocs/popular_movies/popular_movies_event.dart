import 'package:equatable/equatable.dart';

abstract class PopularMoviesEvent extends Equatable {
  const PopularMoviesEvent();

  @override
  List<Object?> get props => [];
}

class FetchPopularMovies extends PopularMoviesEvent {
  const FetchPopularMovies();
}

class FetchMorePopularMovies extends PopularMoviesEvent {
  const FetchMorePopularMovies();
}

class RefreshPopularMovies extends PopularMoviesEvent {
  const RefreshPopularMovies();
}

class UpdateMovieFavoriteStatus extends PopularMoviesEvent {
  final int movieId;
  final bool isFavorite;

  const UpdateMovieFavoriteStatus({
    required this.movieId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [movieId, isFavorite];
}
