import '../../domain/entities/movie.dart';

/// Data model representing a Movie/Show, providing JSON serialization/deserialization
/// supporting both TVMaze public API and cached formats.
class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    super.releaseDate,
    super.isFavorite,
  });

  /// Helper to clean HTML tags (like <p>, <b>) returned by TVMaze summaries.
  static String _cleanSummary(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Factory constructor to parse JSON from TVMaze, TMDB, or local cache.
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    String? poster;
    String? backdrop;

    if (json['image'] is Map<String, dynamic>) {
      final imageMap = json['image'] as Map<String, dynamic>;
      poster = imageMap['medium'] as String? ?? imageMap['original'] as String?;
      backdrop = imageMap['original'] as String? ?? imageMap['medium'] as String?;
    } else {
      poster = json['poster_path'] as String?;
      backdrop = json['backdrop_path'] as String?;
    }

    double rating = 0.0;
    if (json['rating'] is Map<String, dynamic>) {
      final ratingMap = json['rating'] as Map<String, dynamic>;
      rating = (ratingMap['average'] as num?)?.toDouble() ?? 0.0;
    } else if (json['vote_average'] != null) {
      rating = (json['vote_average'] as num?)?.toDouble() ?? 0.0;
    }

    final int votes = json['vote_count'] as int? ?? (json['weight'] as int? ?? 0);
    final String title = json['name'] as String? ?? json['title'] as String? ?? 'Untitled';
    final String summary = _cleanSummary(json['summary'] as String? ?? json['overview'] as String?);
    final String? releaseDate = json['premiered'] as String? ?? json['release_date'] as String?;

    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: title,
      overview: summary,
      posterPath: poster,
      backdropPath: backdrop,
      voteAverage: rating,
      voteCount: votes,
      releaseDate: releaseDate,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// Converts the model to JSON for local persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'is_favorite': isFavorite,
    };
  }

  /// Factory to convert a domain [Movie] entity to [MovieModel].
  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      isFavorite: movie.isFavorite,
    );
  }

  /// Converts this [MovieModel] to a pure domain [Movie] entity.
  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      voteCount: voteCount,
      releaseDate: releaseDate,
      isFavorite: isFavorite,
    );
  }
}
