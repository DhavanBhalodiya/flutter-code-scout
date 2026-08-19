import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/favorites/favorites_event.dart';
import 'presentation/blocs/movie_search/movie_search_bloc.dart';
import 'presentation/blocs/popular_movies/popular_movies_bloc.dart';
import 'presentation/blocs/popular_movies/popular_movies_event.dart';
import 'presentation/screens/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator / dependency injection
  await initDependencies();

  runApp(const MovieScoutApp());
}

class MovieScoutApp extends StatelessWidget {
  const MovieScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PopularMoviesBloc>(
          create: (_) =>
              sl<PopularMoviesBloc>()..add(const FetchPopularMovies()),
        ),
        BlocProvider<MovieSearchBloc>(create: (_) => sl<MovieSearchBloc>()),
        BlocProvider<FavoritesBloc>(
          create: (_) => sl<FavoritesBloc>()..add(const FetchFavorites()),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );
  }
}
