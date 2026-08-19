# TICKET-005: Detail-screen favorite toggle silently swallows errors

- **Severity**: ⚠️ WARNING
- **Status**: OPEN
- **Area**: `lib/presentation/blocs/movie_detail/movie_detail_bloc.dart`

## Problem
`_onToggleMovieDetailFavorite` catches every error into an empty block:

```dart
// movie_detail_bloc.dart:53
try {
  final newFavoriteStatus = await toggleFavorite(movie: movieEntity);
  emit(MovieDetailLoaded(
    movieDetail: detail.copyWith(isFavorite: newFavoriteStatus),
  ));
} catch (e) {
  // In case of error toggling, state remains unchanged
}
```

If persistence fails, the bloc emits nothing: the heart icon never flips, no error is
surfaced, and the user gets zero feedback. This violates the resilience rule in
`.agents/rules/flutter_clean_architecture.md` §3 (the UI must always provide visual
feedback, including for the error state) and hides real cache failures during debugging.

## Proposed Fix
Surface the failure — at minimum log it, and preferably emit a transient error signal the
UI can show (e.g. a SnackBar) while keeping the loaded content on screen.

```dart
} on Failure catch (failure) {
  emit(MovieDetailActionError(
    movieDetail: detail,
    message: failure.message,
  ));
  emit(MovieDetailLoaded(movieDetail: detail)); // restore content
}
```

If a new state class is undesirable, at least replace the empty catch with a logged
re-emit of the current `detail` so the intent is explicit and failures are observable.

## Verification
```bash
flutter analyze
flutter test
```
