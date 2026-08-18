import 'movie_model.dart';

/// Model representing a paginated movie response from TMDB.
class MovieResponseModel {
  final int page;
  final List<MovieModel> results;
  final int totalPages;
  final int totalResults;

  const MovieResponseModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponseModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    final movies = rawResults
        .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return MovieResponseModel(
      page: json['page'] as int? ?? 1,
      results: movies,
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }
}
