import '../../domain/entities/movie_detail.dart';

/// Data model representing detailed movie/show information from TVMaze API.
class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    super.releaseDate,
    super.runtime,
    super.genres,
    super.tagline,
    super.status,
    super.budget,
    super.revenue,
    super.isFavorite,
  });

  static String _cleanSummary(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Factory constructor to parse JSON from TVMaze show details response.
  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse genres array
    final rawGenres = json['genres'] as List<dynamic>?;
    final List<String> parsedGenres = rawGenres != null
        ? rawGenres
            .map((g) {
              if (g is String) return g;
              if (g is Map<String, dynamic>) return g['name'] as String? ?? '';
              return '';
            })
            .where((name) => name.isNotEmpty)
            .toList()
        : [];

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

    String? tagline = json['tagline'] as String?;
    if (tagline == null && json['network'] is Map<String, dynamic>) {
      final networkName = json['network']['name'] as String?;
      if (networkName != null) tagline = 'Broadcasted on $networkName';
    }

    return MovieDetailModel(
      id: json['id'] as int? ?? 0,
      title: title,
      overview: summary,
      posterPath: poster,
      backdropPath: backdrop,
      voteAverage: rating,
      voteCount: votes,
      releaseDate: releaseDate,
      runtime: json['runtime'] as int? ?? json['averageRuntime'] as int?,
      genres: parsedGenres,
      tagline: tagline,
      status: json['status'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// Converts this [MovieDetailModel] to a domain [MovieDetail] entity.
  MovieDetail toEntity() {
    return MovieDetail(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      voteCount: voteCount,
      releaseDate: releaseDate,
      runtime: runtime,
      genres: genres,
      tagline: tagline,
      status: status,
      budget: budget,
      revenue: revenue,
      isFavorite: isFavorite,
    );
  }
}
