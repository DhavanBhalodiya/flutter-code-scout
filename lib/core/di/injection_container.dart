import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/movie_local_data_source.dart';
import '../../data/datasources/movie_remote_data_source.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/get_favorite_movies.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/search_movies.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../presentation/blocs/favorites/favorites_bloc.dart';
import '../../presentation/blocs/movie_detail/movie_detail_bloc.dart';
import '../../presentation/blocs/movie_search/movie_search_bloc.dart';
import '../../presentation/blocs/popular_movies/popular_movies_bloc.dart';
import '../network/api_client.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies, datasources, repositories, use cases, and blocs.
Future<void> initDependencies() async {
  // ----------------------------------------------------
  // External
  // ----------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ----------------------------------------------------
  // Core Network Client
  // ----------------------------------------------------
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ----------------------------------------------------
  // Data Sources
  // ----------------------------------------------------
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ----------------------------------------------------
  // Repository
  // ----------------------------------------------------
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ----------------------------------------------------
  // Use Cases
  // ----------------------------------------------------
  sl.registerLazySingleton(() => GetPopularMovies(sl()));
  sl.registerLazySingleton(() => SearchMovies(sl()));
  sl.registerLazySingleton(() => GetMovieDetails(sl()));
  sl.registerLazySingleton(() => GetFavoriteMovies(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));

  // ----------------------------------------------------
  // BLoCs (Registered as Factory so each subscriber gets fresh instance or scoped)
  // ----------------------------------------------------
  sl.registerFactory(
    () => PopularMoviesBloc(getPopularMovies: sl()),
  );
  sl.registerFactory(
    () => MovieSearchBloc(searchMovies: sl()),
  );
  sl.registerFactory(
    () => MovieDetailBloc(
      getMovieDetails: sl(),
      toggleFavorite: sl(),
    ),
  );
  sl.registerFactory(
    () => FavoritesBloc(
      getFavoriteMovies: sl(),
      toggleFavorite: sl(),
    ),
  );
}
