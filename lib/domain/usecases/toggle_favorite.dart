import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Use case to toggle a movie's favorite status.
class ToggleFavorite {
  final MovieRepository repository;

  const ToggleFavorite(this.repository);

  Future<bool> call({required Movie movie}) async {
    return await repository.toggleFavorite(movie: movie);
  }
}
