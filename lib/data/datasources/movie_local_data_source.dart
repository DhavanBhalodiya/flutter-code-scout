import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../models/movie_model.dart';

/// Contract for local storage operations regarding favorites.
abstract class MovieLocalDataSource {
  Future<List<MovieModel>> getFavorites();
  Future<void> saveFavorite(MovieModel movie);
  Future<void> removeFavorite(int movieId);
  Future<bool> isFavorite(int movieId);
}

/// Concrete implementation using [SharedPreferences].
class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String favoritesKey = 'CACHED_FAVORITE_MOVIES';

  MovieLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MovieModel>> getFavorites() async {
    try {
      final jsonList = sharedPreferences.getStringList(favoritesKey);
      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }
      return jsonList
          .map((item) => MovieModel.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read favorites from cache: $e');
    }
  }

  @override
  Future<void> saveFavorite(MovieModel movie) async {
    try {
      final currentList = await getFavorites();
      // Ensure no duplicates
      final updatedList = currentList.where((m) => m.id != movie.id).toList();
      updatedList.insert(0, MovieModel.fromEntity(movie.copyWith(isFavorite: true)));

      final stringList =
          updatedList.map((m) => jsonEncode(m.toJson())).toList();
      await sharedPreferences.setStringList(favoritesKey, stringList);
    } catch (e) {
      throw CacheException(message: 'Failed to save favorite movie: $e');
    }
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    try {
      final currentList = await getFavorites();
      final updatedList = currentList.where((m) => m.id != movieId).toList();
      final stringList =
          updatedList.map((m) => jsonEncode(m.toJson())).toList();
      await sharedPreferences.setStringList(favoritesKey, stringList);
    } catch (e) {
      throw CacheException(message: 'Failed to remove favorite movie: $e');
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((m) => m.id == movieId);
    } catch (e) {
      return false;
    }
  }
}
