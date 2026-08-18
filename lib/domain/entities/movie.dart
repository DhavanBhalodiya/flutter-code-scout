import 'package:equatable/equatable.dart';

/// Pure domain entity representing a Movie/Show item in lists, grids, and favorites.
class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final bool isFavorite;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    this.isFavorite = false,
  });

  /// Returns full poster image URL
  String? get posterUrl {
    if (posterPath == null || posterPath!.trim().isEmpty) return null;
    if (posterPath!.startsWith('http://') || posterPath!.startsWith('https://')) {
      return posterPath;
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  /// Returns full backdrop image URL
  String? get backdropUrl {
    if (backdropPath == null || backdropPath!.trim().isEmpty) return posterUrl;
    if (backdropPath!.startsWith('http://') || backdropPath!.startsWith('https://')) {
      return backdropPath;
    }
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }

  /// Copies movie with updated fields
  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
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
        isFavorite,
      ];
}
