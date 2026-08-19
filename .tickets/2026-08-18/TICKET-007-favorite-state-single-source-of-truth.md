# TICKET-007: Favorite state duplicated across three BLoCs and hand-synced from widgets

- **Severity**: 💡 SUGGESTION
- **Status**: OPEN
- **Area**: `lib/presentation/` (screens + blocs)

## Problem
`isFavorite` lives independently inside `PopularMoviesBloc`, `MovieSearchBloc`,
`MovieDetailBloc`, and `FavoritesBloc`. Widgets keep the four copies in sync by manually
firing cross-bloc events on every toggle. For example
`movie_search_screen.dart:_toggleFavorite` dispatches to three blocs:

```dart
context.read<MovieSearchBloc>().add(UpdateSearchMovieFavoriteStatus(...));
context.read<PopularMoviesBloc>().add(UpdateMovieFavoriteStatus(...));
context.read<FavoritesBloc>().add(ToggleFavoriteMovie(...));
```

The same triple-dispatch pattern is repeated in `popular_movies_screen.dart`,
`favorites_screen.dart`, and `movie_detail_screen.dart`'s `BlocConsumer.listener`. This is
fragile: any new surface that toggles a favorite must remember to notify every other bloc,
or the UI silently drifts out of sync. It also places synchronization logic in the widget
layer.

## Proposed Fix
Introduce a single source of truth for favorites and have the list/detail blocs react to it
rather than being poked by widgets. Options:
- Expose a `Stream<Set<int>>` of favorite IDs from `MovieRepository`/`MovieLocalDataSource`
  and have each bloc `emit` on changes, or
- Add a shared `FavoritesCubit` that other blocs subscribe to.

The `Update...FavoriteStatus` events and the per-widget triple-dispatch can then be removed.

## Verification
```bash
flutter analyze
flutter test
# Manual: toggle a favorite on the detail screen, then confirm the Popular grid,
# Search list, and Favorites tab all reflect it without extra taps.
```
