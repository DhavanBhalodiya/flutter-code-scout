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
