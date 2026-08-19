# TICKET-008: Search BLoC can render stale results from a raced query

- **Severity**: 💡 SUGGESTION
- **Status**: OPEN
- **Area**: `lib/presentation/blocs/movie_search/movie_search_bloc.dart`

## Problem
`MovieSearchBloc` registers `on<SearchQueryChanged>` with the default event transformer,
which processes events **concurrently**. Two in-flight searches are not ordered by
completion, so a slower response for an older query can resolve *after* a newer one and
overwrite the correct results:

```dart
on<SearchQueryChanged>(_onSearchQueryChanged); // default = concurrent
```

The 500 ms `Debouncer` in `movie_search_screen.dart` reduces the window but does not close
it — when network latency exceeds the inter-keystroke gap, the stale response still wins.

## Proposed Fix
Make query handling restartable so a new query cancels the previous one. With
`bloc_concurrency`:

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';

on<SearchQueryChanged>(_onSearchQueryChanged, transformer: restartable());
```

This guarantees only the latest query's emission survives.

## Verification
```bash
flutter analyze
flutter test
# Manual: type quickly and delete characters; confirm the list always matches the
# final query, never a stale intermediate one.
```
