# 🎫 TICKET-2026-08-19-013: Hardcoded user-facing strings in search screen (i18n)

- **Status**: `RESOLVED`
- **Severity**: `⚠️ WARNING`
- **Target File**: [lib/presentation/screens/movie_search_screen.dart](../../lib/presentation/screens/movie_search_screen.dart) (L76, L86, L104-105, L108, L111-113)
- **Created**: `2026-08-19`
- **Resolved**: `2026-08-19`
- **Tags**: `i18n`, `l10n`, `localization`

---

## 🔍 Problem Description
Per [Clean Architecture Rules §5](../../.agents/rules/flutter_clean_architecture.md), user-facing
text must not be inline string literals. This screen hardcodes English throughout:

| Line | String |
| :--- | :--- |
| L76  | `'Search Movies'` (AppBar title) |
| L86  | `'Search by movie title...'` (hint) |
| L104-105 | `'Explore Movies'` / `'Type a title above to search through thousands of movies.'` |
| L108 | `'Searching movies...'` |
| L111 | `'No Results Found'` |
| L113 | `'We couldn\'t find any movies matching "${state.query}"'` |

None are localizable; the screen cannot be translated and the interpolated result message (L113)
also needs an ICU placeholder rather than string interpolation.

---

## 🛠️ Action Plan & Proposed Fix
Introduce Flutter localization (`flutter_localizations` + `gen-l10n`) and move these strings to an
`.arb` resource, referencing them via `AppLocalizations.of(context)`:

```dart
// .arb
"searchTitle": "Search Movies",
"searchHint": "Search by movie title...",
"searchEmptyTitle": "Explore Movies",
"searchEmptyBody": "Type a title above to search through thousands of movies.",
"searchLoading": "Searching movies...",
"searchNoResultsTitle": "No Results Found",
"searchNoResultsBody": "We couldn't find any movies matching \"{query}\".",
"@searchNoResultsBody": { "placeholders": { "query": {} } }

// widget
Text(AppLocalizations.of(context)!.searchTitle)
```

> Note: adopting `gen-l10n` also requires wiring `localizationsDelegates` + `supportedLocales` in
> `MaterialApp` (do it once, app-wide) — track as a separate app-level task if not present.

---

## ✅ Verification
```bash
flutter gen-l10n
flutter analyze
flutter test
```

---

## ✔️ Resolution (`2026-08-19`)
Adopted Flutter `gen-l10n` localization app-wide and moved every user-facing string off the widget.

**Infrastructure added**
- `pubspec.yaml`: added `flutter_localizations` (sdk) dependency, set `flutter: generate: true`,
  and pinned `intl: ^0.20.2` (required — `flutter_localizations` pins `intl` to `0.20.2`).
- `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  `output-dir: lib/l10n`, `nullable-getter: false` (so `AppLocalizations.of(context)` is non-null).
- `lib/l10n/app_en.arb`: 7 keys with descriptions; `searchNoResultsBody` uses a named ICU
  placeholder `{query}` (no string interpolation).
- Generated: `lib/l10n/app_localizations.dart` + `app_localizations_en.dart`.

**Wiring**
- `lib/main.dart`: `MaterialApp` now declares `localizationsDelegates:
  AppLocalizations.localizationsDelegates` and `supportedLocales:
  AppLocalizations.supportedLocales`. (No direct `flutter_localizations` import needed — the
  generated `localizationsDelegates` already bundles the global Material/Widgets/Cupertino
  delegates.)

**Screen**
- `movie_search_screen.dart`: all 7 strings now resolve via
  `final l10n = AppLocalizations.of(context);` →
  `l10n.searchTitle` / `searchHint` / `searchEmptyTitle` / `searchEmptyBody` /
  `searchLoading` / `searchNoResultsTitle` / `searchNoResultsBody(state.query)`.
  Dropped the now-invalid `const` on the initial `EmptyView` and the loading `LoadingIndicator`
  (they depend on runtime localization).

**Result:** `flutter analyze` → *No issues found*; `flutter test` → *All tests passed*.

> Follow-up (not part of this ticket): three other screens/widgets still hold hardcoded English
> (e.g. `home_screen.dart`, `error_view.dart`, detail/favorites screens). Now that the l10n
> pipeline exists, migrating them is additive — recommend a dedicated ticket to sweep the rest.
