import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

/// Contract for remote movie/show data source.
abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> searchMovies({required String query, int page = 1});
  Future<MovieDetailModel> getMovieDetails({required int movieId});
}

/// Concrete implementation of [MovieRemoteDataSource] using TVMaze public API.
class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    // TVMaze pagination starts at 0
    final pageIndex = (page > 0) ? page - 1 : 0;
    final response = await apiClient.get(
      ApiEndpoints.popularShows,
      queryParameters: {'page': pageIndex},
    );

    if (response is List<dynamic>) {
      return response
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<MovieModel>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.searchShows,
      queryParameters: {
        'q': query,
      },
    );

    if (response is List<dynamic>) {
      return response
          .where((item) => item is Map<String, dynamic> && item['show'] != null)
          .map((item) => MovieModel.fromJson(item['show'] as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<MovieDetailModel> getMovieDetails({required int movieId}) async {
    final response = await apiClient.get(
      ApiEndpoints.showDetails(movieId),
    );
    return MovieDetailModel.fromJson(response as Map<String, dynamic>);
  }
}
