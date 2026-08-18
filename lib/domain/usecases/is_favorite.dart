import '../repositories/movie_repository.dart';

/// Use case to check if a specific movie is favorited.
class IsFavorite {
  final MovieRepository repository;

  const IsFavorite(this.repository);

  Future<bool> call({required int movieId}) async {
    return await repository.isFavorite(movieId: movieId);
  }
}
