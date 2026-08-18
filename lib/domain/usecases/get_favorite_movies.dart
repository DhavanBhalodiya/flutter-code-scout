import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case to fetch all saved favorite movies.
class GetFavoriteMovies {
  final MovieRepository repository;

  const GetFavoriteMovies(this.repository);

  Future<List<Movie>> call() async {
    return await repository.getFavoriteMovies();
  }
}
