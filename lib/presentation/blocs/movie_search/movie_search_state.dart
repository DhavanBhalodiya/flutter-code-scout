import 'package:equatable/equatable.dart';
import '../../../domain/entities/movie.dart';

abstract class MovieSearchState extends Equatable {
  const MovieSearchState();

  @override
  List<Object?> get props => [];
}

class MovieSearchInitial extends MovieSearchState {
  const MovieSearchInitial();
}

class MovieSearchLoading extends MovieSearchState {
  const MovieSearchLoading();
}

class MovieSearchLoaded extends MovieSearchState {
  final List<Movie> movies;
  final String query;
  final int currentPage;
  final bool hasReachedMax;
  final bool isFetchingMore;

  const MovieSearchLoaded({
    required this.movies,
    required this.query,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  MovieSearchLoaded copyWith({
    List<Movie>? movies,
    String? query,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return MovieSearchLoaded(
      movies: movies ?? this.movies,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
        movies,
        query,
        currentPage,
        hasReachedMax,
        isFetchingMore,
      ];
}

class MovieSearchEmpty extends MovieSearchState {
  final String query;

  const MovieSearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class MovieSearchError extends MovieSearchState {
  final String message;
  final String query;

  const MovieSearchError({required this.message, required this.query});

  @override
  List<Object?> get props => [message, query];
}
