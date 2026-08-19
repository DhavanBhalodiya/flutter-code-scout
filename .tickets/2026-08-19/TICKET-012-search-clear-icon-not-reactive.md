# 🎫 TICKET-2026-08-19-012: Search clear (✕) button never appears/disappears reactively

- **Status**: `OPEN`
- **Severity**: `⚠️ WARNING`
- **Target File**: [lib/presentation/screens/movie_search_screen.dart](../../lib/presentation/screens/movie_search_screen.dart) (L88-L93)
- **Created**: `2026-08-19`
- **Tags**: `ui-bug`, `state-management`, `reactivity`

---

## 🔍 Problem Description
The `suffixIcon` clear button is rendered conditionally on the controller's text:

```dart
suffixIcon: _searchController.text.isNotEmpty
    ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: _clearSearch)
    : null,
```

This is evaluated inside `_MovieSearchScreenState.build()`, but that `build()` only re-runs on
`setState()` or a dependency change — **neither happens when the user types**:
- `TextField.onChanged` → `_onQueryChanged` only runs the debouncer and dispatches a BLoC event;
  it never calls `setState`.
- The `BlocBuilder` wraps only the `body`, so a BLoC emission rebuilds the list — **not** the
  `AppBar`/`TextField` where the `suffixIcon` lives.

Result: the clear button reflects the controller text only at the *initial* build (empty → no
button) and does not update as the user types or clears — the ✕ affordance is effectively dead.

---

## 🛠️ Action Plan & Proposed Fix
Make the `suffixIcon` react to controller changes. Cleanest option — wrap just the icon in a
`ValueListenableBuilder` on the controller (no full-screen rebuild):

```dart
suffixIcon: ValueListenableBuilder<TextEditingValue>(
  valueListenable: _searchController,
  builder: (context, value, _) => value.text.isEmpty
      ? const SizedBox.shrink()
      : IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: _clearSearch,
        ),
),
```

Alternative: add `_searchController.addListener(() => setState(() {}))` in `initState` (and remove
it in `dispose`), but that rebuilds the whole screen per keystroke — prefer the scoped builder.

---

## ✅ Verification
```bash
flutter analyze
flutter test
```
Manual: type into the search field → ✕ appears; tap ✕ or clear text → ✕ disappears.
