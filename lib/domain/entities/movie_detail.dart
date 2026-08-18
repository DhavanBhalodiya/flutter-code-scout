import 'package:equatable/equatable.dart';

/// Pure domain entity representing comprehensive details of a movie / show.
class MovieDetail extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final int? runtime;
  final List<String> genres;
  final String? tagline;
  final String? status;
  final int? budget;
  final int? revenue;
  final bool isFavorite;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    this.runtime,
    this.genres = const [],
    this.tagline,
    this.status,
    this.budget,
    this.revenue,
    this.isFavorite = false,
  });

  /// Full poster URL
  String? get posterUrl {
    if (posterPath == null || posterPath!.trim().isEmpty) return null;
    if (posterPath!.startsWith('http://') || posterPath!.startsWith('https://')) {
      return posterPath;
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  /// Full backdrop URL
  String? get backdropUrl {
    if (backdropPath == null || backdropPath!.trim().isEmpty) return posterUrl;
    if (backdropPath!.startsWith('http://') || backdropPath!.startsWith('https://')) {
      return backdropPath;
    }
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }

  /// Copies movie detail with updated fields
  MovieDetail copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    int? runtime,
    List<String>? genres,
    String? tagline,
    String? status,
    int? budget,
    int? revenue,
    bool? isFavorite,
  }) {
    return MovieDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      tagline: tagline ?? this.tagline,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      revenue: revenue ?? this.revenue,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        voteAverage,
        voteCount,
        releaseDate,
        runtime,
        genres,
        tagline,
        status,
        budget,
        revenue,
        isFavorite,
      ];
}
