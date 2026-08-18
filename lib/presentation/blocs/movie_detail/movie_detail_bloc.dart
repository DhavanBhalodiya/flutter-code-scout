import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/get_movie_details.dart';
import '../../../domain/usecases/toggle_favorite.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final GetMovieDetails getMovieDetails;
  final ToggleFavorite toggleFavorite;

  MovieDetailBloc({
    required this.getMovieDetails,
    required this.toggleFavorite,
  }) : super(const MovieDetailInitial()) {
    on<FetchMovieDetail>(_onFetchMovieDetail);
    on<ToggleMovieDetailFavorite>(_onToggleMovieDetailFavorite);
  }

  Future<void> _onFetchMovieDetail(
    FetchMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(const MovieDetailLoading());
    try {
      final detail = await getMovieDetails(movieId: event.movieId);
      emit(MovieDetailLoaded(movieDetail: detail));
    } on Failure catch (failure) {
      emit(MovieDetailError(message: failure.message));
    } catch (e) {
      emit(MovieDetailError(message: 'Failed to load movie details: $e'));
    }
  }

  Future<void> _onToggleMovieDetailFavorite(
    ToggleMovieDetailFavorite event,
    Emitter<MovieDetailState> emit,
  ) async {
    final detail = event.movieDetail;
    final movieEntity = Movie(
      id: detail.id,
      title: detail.title,
      overview: detail.overview,
      posterPath: detail.posterPath,
      backdropPath: detail.backdropPath,
      voteAverage: detail.voteAverage,
      voteCount: detail.voteCount,
      releaseDate: detail.releaseDate,
      isFavorite: detail.isFavorite,
    );

    try {
      final newFavoriteStatus = await toggleFavorite(movie: movieEntity);
      emit(MovieDetailLoaded(
        movieDetail: detail.copyWith(isFavorite: newFavoriteStatus),
      ));
    } catch (e) {
      // In case of error toggling, state remains unchanged
    }
  }
}
