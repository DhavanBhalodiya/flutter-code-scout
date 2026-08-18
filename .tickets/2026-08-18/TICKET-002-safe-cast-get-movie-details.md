# 🎫 TICKET-2026-08-18-002: Add Safe Cast in MovieRemoteDataSourceImpl.getMovieDetails

- **Status**: `OPEN`
- **Severity**: `⚠️ WARNING`
- **Target File**: [movie_remote_data_source.dart](file:///Users/indianic/FLUTTER/CodeScout/flutter_code_scout/lib/data/datasources/movie_remote_data_source.dart#L58-L64)
- **Created**: `2026-08-18`
- **Tags**: `type-safety`, `runtime-crash`, `data-source`

---

## 🔍 Problem Description
In `MovieRemoteDataSourceImpl.getMovieDetails`, the raw API response is forcefully cast to `Map<String, dynamic>`:
```dart
final response = await apiClient.get(
  ApiEndpoints.showDetails(movieId),
);
return MovieDetailModel.fromJson(response as Map<String, dynamic>);
```
If the server returns an unexpected structure or an empty response body, a raw unhandled `TypeError` is thrown at runtime rather than a clean `ServerException`.

---

## 🛠️ Action Plan & Proposed Fix
Safely check if `response` is an instance of `Map<String, dynamic>` before deserializing, and throw a clear `ServerException` if invalid.

### Proposed Code:
```dart
@override
Future<MovieDetailModel> getMovieDetails({required int movieId}) async {
  final response = await apiClient.get(
    ApiEndpoints.showDetails(movieId),
  );
  if (response is Map<String, dynamic>) {
    return MovieDetailModel.fromJson(response);
  }
  throw const ServerException(message: 'Invalid response received for movie details.');
}
```

---

## ✅ Verification
Run the test suite:
```bash
flutter test
```
