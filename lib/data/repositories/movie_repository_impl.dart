import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/movie_remote_data_source.dart';
import '../models/movie_model.dart';

/// Concrete implementation of [MovieRepository] coordinating between
/// remote TMDB API and local persistence.
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final remoteMovies = await remoteDataSource.getPopularMovies(page: page);
      final favoriteIds = await _getFavoriteIdsSet();

      return remoteMovies.map((movie) {
        final isFav = favoriteIds.contains(movie.id);
        return movie.copyWith(isFavorite: isFav);
      }).toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(message: 'Failed to fetch popular movies: $e');
    }
  }

  @override
  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final remoteMovies = await remoteDataSource.searchMovies(
        query: query,
        page: page,
      );
      final favoriteIds = await _getFavoriteIdsSet();

      return remoteMovies.map((movie) {
        final isFav = favoriteIds.contains(movie.id);
        return movie.copyWith(isFavorite: isFav);
      }).toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(message: 'Failed to search movies: $e');
    }
  }

  @override
  Future<MovieDetail> getMovieDetails({required int movieId}) async {
    try {
      final detailModel = await remoteDataSource.getMovieDetails(movieId: movieId);
      final isFav = await localDataSource.isFavorite(movieId);
      return detailModel.copyWith(isFavorite: isFav);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(message: 'Failed to fetch movie details: $e');
    }
  }

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return favorites.map((m) => m.copyWith(isFavorite: true)).toList();
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(message: 'Failed to load favorite movies: $e');
    }
  }

  @override
  Future<bool> toggleFavorite({required Movie movie}) async {
    try {
      final isCurrentlyFavorite = await localDataSource.isFavorite(movie.id);
      if (isCurrentlyFavorite) {
        await localDataSource.removeFavorite(movie.id);
        return false;
      } else {
        await localDataSource.saveFavorite(MovieModel.fromEntity(movie));
        return true;
      }
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnknownFailure(message: 'Failed to toggle favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite({required int movieId}) async {
    try {
      return await localDataSource.isFavorite(movieId);
    } catch (e) {
      return false;
    }
  }

  Future<Set<int>> _getFavoriteIdsSet() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return favorites.map((m) => m.id).toSet();
    } catch (_) {
      return {};
    }
  }
}
