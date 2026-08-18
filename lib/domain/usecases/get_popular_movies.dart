import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case to fetch a paginated list of popular movies.
class GetPopularMovies {
  final MovieRepository repository;

  const GetPopularMovies(this.repository);

  Future<List<Movie>> call({int page = 1}) async {
    return await repository.getPopularMovies(page: page);
  }
}
