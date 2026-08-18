import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case to search movies by text query with pagination.
class SearchMovies {
  final MovieRepository repository;

  const SearchMovies(this.repository);

  Future<List<Movie>> call({required String query, int page = 1}) async {
    return await repository.searchMovies(query: query, page: page);
  }
}
