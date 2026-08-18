# Movie Scout (Clean Architecture Flutter App)

A production-quality Flutter Movie Application built using **Clean Architecture** (Presentation, Domain, Data, and Core layers), **BLoC State Management**, **Dio**, **GetIt Dependency Injection**, and **Local Persistence**.

Powered by the **100% Free & Open TVMaze API** (`https://api.tvmaze.com`) — zero API keys or authentication required to get started immediately.

---

## 🏛️ Architecture Overview

The project is structured according to the principles of Clean Architecture and Dependency Inversion:

```
lib/
├── core/
│   ├── config/            # AppConfig (baseURL, timeouts, environment config)
│   ├── di/                # Service locator configuration (GetIt)
│   ├── error/             # Exception definitions and Failure mappings
│   ├── network/           # ApiClient (Dio) and TVMaze endpoints
│   ├── theme/             # Modern cinematic dark theme, typography, colors
│   └── utils/             # Date formatting and debouncer utilities
│
├── domain/                # Pure business logic (zero dependencies on UI or external frameworks)
│   ├── entities/          # Movie and MovieDetail domain entities
│   ├── repositories/      # Abstract repository contracts (MovieRepository)
│   └── usecases/          # Granular use cases (GetPopularMovies, SearchMovies, etc.)
│
├── data/                  # Data layer (implements domain interfaces)
│   ├── datasources/       # Remote (TVMaze API) and Local (SharedPreferences) data sources
│   ├── models/            # JSON serialization/deserialization models
│   └── repositories/      # MovieRepositoryImpl coordinating remote & cache
│
└── presentation/          # User Interface & State Management
    ├── blocs/             # PopularMoviesBloc, MovieSearchBloc, MovieDetailBloc, FavoritesBloc
    ├── screens/           # PopularMoviesScreen, MovieSearchScreen, MovieDetailScreen, FavoritesScreen
    └── widgets/           # MovieCard, MovieListTile, RatingBadge, CachedImage, ErrorView, EmptyView
```

---

## 🚀 Features

- **Popular Shows & Movies**: Paginated discovery grid with pull-to-refresh and infinite scroll.
- **Search**: Real-time debounced search across TVMaze catalog.
- **Title Details**: Hero backdrop, poster, rating, runtime, release date, genres, overview synopsis, and favorite toggle.
- **Favorites & Offline Persistence**: Save favorite titles locally using `SharedPreferences`.
- **Error & Loading States**: Comprehensive error messages, retry mechanisms, shimmer/loading indicators, and empty state graphics.
- **Dark Cinematic Theme**: Material 3 dark UI tailored for media discovery.

---

## ⚡ Quick Start (Zero-Config)

Because the app uses the free TVMaze API, **no API keys or tokens are needed**.

```bash
# Run the app on any connected device or simulator
flutter run
```

Or simply press **F5** in VS Code / Antigravity IDE.

---

## 🧪 Static Analysis & Verification

```bash
flutter analyze
```
