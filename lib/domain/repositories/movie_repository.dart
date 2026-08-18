import '../entities/movie.dart';
import '../entities/movie_detail.dart';

/// Abstract contract for Movie operations in the Domain layer.
///
/// Any data implementation (remote TMDB API, local DB, cache) must satisfy
/// this interface, adhering to Dependency Inversion.
abstract class MovieRepository {
  /// Fetches a paginated list of popular movies.
  Future<List<Movie>> getPopularMovies({int page = 1});

  /// Searches for movies matching the given query with pagination.
  Future<List<Movie>> searchMovies({required String query, int page = 1});

  /// Fetches detailed information for a movie by its TMDB ID.
  Future<MovieDetail> getMovieDetails({required int movieId});

  /// Retrieves all saved favorite movies from local storage.
  Future<List<Movie>> getFavoriteMovies();

  /// Toggles favorite status of a movie (adds if absent, removes if present).
  /// Returns the new favorite status (true if now favorited, false if removed).
  Future<bool> toggleFavorite({required Movie movie});

  /// Checks if a given movie ID is currently marked as favorite.
  Future<bool> isFavorite({required int movieId});
}
