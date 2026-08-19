# Flutter & Clean Architecture Quality Rules

This rule document defines architectural constraints, code style standards, and safety principles for Flutter projects utilizing Clean Architecture and BLoC.

---

## 1. Clean Architecture Boundaries

### Domain Layer (`lib/domain/`)
- **Zero Framework Coupling**: Must NEVER import `package:flutter/material.dart`, `package:dio/dio.dart`, `package:sqflite/`, `package:shared_preferences/`, or any concrete UI/network/storage library.
- **Pure Entities**: Entities must be immutable and extend `Equatable`.
- **Contracts Only**: Repositories in `domain/repositories/` must be abstract classes/interfaces returning domain entities or `Either<Failure, T>` / typed results.
- **Single-Responsibility Use Cases**: Each use case in `domain/usecases/` should execute one specific business operation and be callable via `call()`.

### Data Layer (`lib/data/`)
- **Model vs. Entity Separation**: Models in `data/models/` must extend or map to domain entities, handling JSON serialization/deserialization (`fromJson`, `toJson`, `toEntity`, `fromEntity`).
- **Data Source Segregation**: `RemoteDataSource` handles network/APIs, while `LocalDataSource` handles caching/database operations.
- **Exception to Failure Mapping**: `RepositoryImpl` must catch low-level `AppException` (e.g. `ServerException`, `CacheException`, `NetworkException`) and convert them into domain `Failure` objects (`ServerFailure`, `CacheFailure`, etc.).

### Presentation Layer (`lib/presentation/`)
- **State Management (BLoC)**: UI widgets must not execute business logic, network requests, or database calls directly. All interactions flow through BLoC events.
- **Immutable States & Events**: All BLoC events and states must extend `Equatable` to allow value equality comparison.
- **No Direct Data Layer Access**: Presentation must never import or consume `data/datasources/` or `data/models/` directly.

### Core Layer (`lib/core/`)
- Contains cross-cutting concerns: dependency injection (`injection_container.dart`), theme/colors, typography, network client (`ApiClient`), error definitions, and utility classes.

---

## 2. Flutter Performance & Memory Safety

### Memory Management & Disposing
- Any `StatefulWidget` creating a `TextEditingController`, `ScrollController`, `AnimationController`, `FocusNode`, `StreamSubscription`, or `Timer` MUST properly dispose of it inside `dispose()`.

### Widget Rebuild Optimization
- Mark all unchanging widgets and subtrees with `const`.
- Avoid heavy computational logic, parsing, or file I/O inside `Widget.build()`.
- Use `ListView.builder` or `SliverList` for dynamic lists rather than `ListView(children: [...])` or `Column(children: [...])`.

---

## 3. Error Handling & Resilience
- Every asynchronous network call must have try-catch error handling.
- The UI must always provide visual feedback for three distinct states:
  1. `LoadingState` (Progress indicator / Shimmer skeleton)
  2. `LoadedState` (Data content or EmptyView if list is empty)
  3. `ErrorState` (Clear error message with Retry action)

---

## 4. Security & Sensitive Data
- Do NOT hardcode API keys, passwords, secrets, or bearer tokens in code or commit them to VCS.
- Use compile-time environment definitions (`--dart-define`) or secure config loaders.

---

## 5. Internationalization & Localization (i18n / l10n)

A production-grade Flutter app must be translation-ready. Review the following:

- **No hardcoded user-facing strings**: Text rendered to the user (labels, buttons, error
  messages, empty/loading states, tooltips, `Semantics` labels) must NOT be inline string
  literals in widgets. Route them through `AppLocalizations` / `.arb` resources.
  - _Exempt_: log messages, keys, asset paths, and other non-user-facing strings.
- **Localization wiring**: Once l10n is adopted, `MaterialApp` must declare
  `localizationsDelegates` (including `AppLocalizations.delegate` and the Flutter delegates)
  and `supportedLocales`.
- **Locale-aware formatting**: Format dates, numbers, and currency only via `intl`
  (`DateFormat`, `NumberFormat`) — never by manual string building or hardcoded separators.
- **Pluralization & gender**: Use ICU message syntax (`plural`, `select`) with named
  placeholders — never string concatenation to assemble sentences.
- **RTL / bidi safety**: Prefer `EdgeInsetsDirectional` and `start`/`end` over `left`/`right`;
  avoid layouts that assume left-to-right reading order.
- **Text growth**: Do not assume translated strings fit a fixed width or single line; allow
  wrapping/overflow handling.

### Severity guidance for i18n findings
- Hardcoded user-facing string, or missing `localizationsDelegates`/`supportedLocales` →
  **⚠️ Warning**.
- Directional layout leak (`left`/`right` in a translatable UI) → **⚠️ Warning**.
- Manual date/number/currency formatting instead of `intl` → **💡 Suggestion**.

---

## Future Review Dimensions (not yet enforced)

These dimensions are recognized as industry-standard but are intentionally **out of scope**
for the current review definition. Do not fail a review for them; note them as future work:

- **Testing standards** — coverage thresholds, `bloc_test` per BLoC, widget/golden/integration tests.
- **Accessibility** — `Semantics`/`semanticLabel`, color contrast, ≥48dp tap targets, text scaling.
- **Mechanical boundary enforcement** — lint-enforced Clean Architecture import bans (vs. review-by-reading).
