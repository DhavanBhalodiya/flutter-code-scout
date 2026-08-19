# TICKET-004: Search "load more" re-fetches the same results and appends duplicates

- **Severity**: ⚠️ WARNING
- **Status**: OPEN
- **Area**: `lib/presentation/blocs/movie_search/`, `lib/data/datasources/movie_remote_data_source.dart`

## Problem
The TVMaze `/search/shows?q=<query>` endpoint is **not paginated** — it returns the
full match set in a single response and ignores any `page` parameter.
`MovieRemoteDataSourceImpl.searchMovies` reflects this: it only sends `q` and never
forwards `page`:

```dart
// lib/data/datasources/movie_remote_data_source.dart:41
final response = await apiClient.get(
  ApiEndpoints.searchShows,
  queryParameters: {'q': query}, // <-- page is silently dropped
);
```

But `MovieSearchBloc` still drives infinite-scroll pagination:

```dart
// movie_search_bloc.dart:39
hasReachedMax: movies.length < 20,      // false when a query returns >= 20 hits
...
// movie_search_bloc.dart:67 (_onFetchMoreSearchResults)
final newMovies = await searchMovies(query: currentState.query, page: nextPage);
// same query -> identical full list -> appended again
emit(currentState.copyWith(
  movies: List.of(currentState.movies)..addAll(newMovies), // duplicates
```

**Effect:** any search returning ≥ 20 results leaves `hasReachedMax == false`. When the
user scrolls to 85%, `FetchMoreSearchResults` re-runs the identical query and appends the
same movies again — unbounded duplicate growth on every scroll.

## Proposed Fix
Treat search as a single-page result set (the API has no more pages to give).

```dart
// movie_search_bloc.dart _onSearchQueryChanged
emit(MovieSearchLoaded(
  movies: movies,
  query: query,
  currentPage: 1,
  hasReachedMax: true, // TVMaze search is single-shot; no pagination
));
```

With `hasReachedMax` always true, the guard in `_onFetchMoreSearchResults` short-circuits
and no duplicate fetch occurs. The `_onFetchMoreSearchResults` handler and the trailing
loader in `movie_search_screen.dart` can then be removed as dead paths, or left as inert
no-ops.

## Verification
```bash
flutter analyze
flutter test
# Manual: search a common term (e.g. "girl"), scroll to the bottom repeatedly,
# confirm the list does not grow with duplicate tiles.
```
