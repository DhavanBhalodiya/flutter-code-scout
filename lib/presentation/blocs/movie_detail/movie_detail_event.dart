import 'package:equatable/equatable.dart';
import '../../../domain/entities/movie_detail.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieDetail extends MovieDetailEvent {
  final int movieId;

  const FetchMovieDetail(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class ToggleMovieDetailFavorite extends MovieDetailEvent {
  final MovieDetail movieDetail;

  const ToggleMovieDetailFavorite(this.movieDetail);

  @override
  List<Object?> get props => [movieDetail];
}
