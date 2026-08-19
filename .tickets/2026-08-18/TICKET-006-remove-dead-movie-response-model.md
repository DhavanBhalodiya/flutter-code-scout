# TICKET-006: Remove unused `MovieResponseModel` (dead TMDB pagination shape)

- **Severity**: 💡 SUGGESTION
- **Status**: RESOLVED ✅ (2026-08-18)
- **Area**: `lib/data/models/movie_response_model.dart`

## Resolution
Deleted `lib/data/models/movie_response_model.dart`. `grep` confirmed the class had no
references outside its own file. `flutter analyze` reports no issues and `flutter test`
passes, verifying nothing depended on it.

## Problem
`MovieResponseModel` models a TMDB-style paginated envelope
(`page`, `results`, `total_pages`, `total_results`). The app integrates with TVMaze, which
returns a bare JSON array, so this class is never referenced anywhere outside its own file:

```
$ grep -rn "MovieResponseModel" lib test
lib/data/models/movie_response_model.dart:4:class MovieResponseModel {
lib/data/models/movie_response_model.dart:10:  const MovieResponseModel({
lib/data/models/movie_response_model.dart:17:  factory MovieResponseModel.fromJson(...)
lib/data/models/movie_response_model.dart:23:    return MovieResponseModel(...)
```

It is leftover scaffolding that misleads readers into thinking a paginated API contract
exists.

## Proposed Fix
Delete `lib/data/models/movie_response_model.dart`. If TMDB-style pagination is planned for
the future, keep it on a feature branch instead of in `main`.

## Verification
```bash
flutter analyze   # confirms no dangling references
flutter test
```
