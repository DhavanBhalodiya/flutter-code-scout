import 'package:equatable/equatable.dart';
import '../../../domain/entities/movie.dart';

abstract class PopularMoviesState extends Equatable {
  const PopularMoviesState();

  @override
  List<Object?> get props => [];
}

class PopularMoviesInitial extends PopularMoviesState {
  const PopularMoviesInitial();
}

class PopularMoviesLoading extends PopularMoviesState {
  const PopularMoviesLoading();
}

class PopularMoviesLoaded extends PopularMoviesState {
  final List<Movie> movies;
  final bool hasReachedMax;
  final int currentPage;
  final bool isFetchingMore;

  const PopularMoviesLoaded({
    required this.movies,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isFetchingMore = false,
  });

  PopularMoviesLoaded copyWith({
    List<Movie>? movies,
    bool? hasReachedMax,
    int? currentPage,
    bool? isFetchingMore,
  }) {
    return PopularMoviesLoaded(
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [movies, hasReachedMax, currentPage, isFetchingMore];
}

class PopularMoviesError extends PopularMoviesState {
  final String message;

  const PopularMoviesError({required this.message});

  @override
  List<Object?> get props => [message];
}
