import '../entities/movie_detail.dart';
import '../repositories/movie_repository.dart';

/// Use case to fetch detailed movie information by movie ID.
class GetMovieDetails {
  final MovieRepository repository;

  const GetMovieDetails(this.repository);

  Future<MovieDetail> call({required int movieId}) async {
    return await repository.getMovieDetails(movieId: movieId);
  }
}
