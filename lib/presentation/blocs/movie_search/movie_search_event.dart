import 'package:equatable/equatable.dart';

abstract class MovieSearchEvent extends Equatable {
  const MovieSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends MovieSearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FetchMoreSearchResults extends MovieSearchEvent {
  const FetchMoreSearchResults();
}

class ClearSearch extends MovieSearchEvent {
  const ClearSearch();
}

class UpdateSearchMovieFavoriteStatus extends MovieSearchEvent {
  final int movieId;
  final bool isFavorite;

  const UpdateSearchMovieFavoriteStatus({
    required this.movieId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [movieId, isFavorite];
}
