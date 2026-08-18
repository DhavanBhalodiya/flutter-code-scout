# 🎫 TICKET-2026-08-18-003: Optimize Search Screen with const Insets & Trim Guard

- **Status**: `OPEN`
- **Severity**: `💡 SUGGESTION`
- **Target Files**:
  - [movie_search_screen.dart](file:///Users/indianic/FLUTTER/CodeScout/flutter_code_scout/lib/presentation/screens/movie_search_screen.dart#L80)
  - [movie_search_bloc.dart](file:///Users/indianic/FLUTTER/CodeScout/flutter_code_scout/lib/presentation/blocs/movie_search/movie_search_bloc.dart#L25)
- **Created**: `2026-08-18`
- **Tags**: `performance`, `micro-optimization`, `widget-rebuild`

---

## 🔍 Problem Description
1. `Padding` and `ListView.separated` in `movie_search_screen.dart` use runtime instantiated `EdgeInsets` instead of `const EdgeInsets`.
2. Redundant network calls can occur if user enters search queries containing only whitespace.

---

## 🛠️ Action Plan & Proposed Fix
1. Mark static `EdgeInsets.fromLTRB(16, 0, 16, 12)` and `EdgeInsets.all(16.0)` as `const`.
2. Add `.trim()` check before firing search API calls in `MovieSearchBloc`.

---

## ✅ Verification
```bash
flutter analyze
flutter test
```
