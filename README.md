# 🛡️ Flutter Code Scout: Full-Lifecycle AI Agent System

An intelligent, autonomous **Clean Architecture Pair-Programmer, Scaffolder, Code Reviewer & Release System** tailored for Flutter & Dart applications. Built with **Antigravity Customizations**, **Deterministic Scaffolding**, and cross-platform compatibility for **Claude Code CLI**, **Cursor**, and **CI/CD pipelines**.

---

```
  PLAN                BUILD              TEST            REVIEW            SHIP
 ┌──────────────┐    ┌──────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐
 │ Feature Plan │───▶│ 100% Slice   │───│ Auto Tests │──▶│ Health &   │──▶│ Pre-Launch │
 │ & State Spec │    │ & UI Screen  │   │ Model/BLoC │   │ .tickets/  │   │ Audit Gate │
 └──────────────┘    └──────────────┘   └────────────┘   └────────────┘   └────────────┘
  /plan-feature       /api-to-feature    flutter test     /code-review        /ship
```

---

## ⚡ Slash Command Reference

| SDLC Phase | Slash Command | Action | Key Output |
| :--- | :--- | :--- | :--- |
| 🗺️ **PLAN** | **`/plan-feature <Name>`** | Architectural blueprint, UI wireframe & BLoC state machine | `.plans/<name>.md`<br>`schema_input.json` |
| ⚡ **BUILD** | **`/api-to-feature <Name>`** | Scaffolds 100% runnable Clean Architecture slice in 1 sec (95% token savings) | Domain, Data, BLoC, UI Screen, Tests, DI |
| 📦 **MODEL** | **`/api-to-model <Name>`** | Crash-proof JSON parser, Domain Entity & Model unit tests | `entities/`, `models/`, model tests |
| 🛡️ **REVIEW**| **`/code-review`** | Audits Clean Architecture, memory leaks, performance & security | Review Report + Health Score<br>`.tickets/YYYY-MM-DD/` |
| 🔧 **FIX** | **`/fix-ticket <ID>`** | Autonomously resolves ticket, edits code, and verifies tests | Ticket marked `RESOLVED ✅` |
| 🚢 **SHIP** | **`/ship`** | Pre-launch release inspection across Dart, Android, iOS & Security | Release Readiness Report<br>Build commands (`.aab`, `.ipa`) |

---

## 🚀 Key Highlights

- **Complete SDLC Coverage**: Seamless workflow from ideation (`/plan-feature`) to deterministic building (`/api-to-feature`), code auditing (`/code-review`), and release (`/ship`).
- **95% Token Savings**: Hybrid Dart CLI synthesis engine generates 10 files in 1 second with ~150 tokens.
- **100% Vertical Slice Generation**: Scaffolds Domain, Data, UseCase, BLoC, **UI Screen (with BlocProvider & Loading/Error states)**, **BLoC Unit Tests**, Model Tests, and Auto-DI.
- **Automated Ticket System**: Organizes code review findings into trackable, date-stamped tickets in `.tickets/` with quantified health scores.
- **One-Command Auto-Fixing**: Tell the agent `"Fix ticket TICKET-001"` to apply drop-in code fixes and re-verify zero regression.
- **Pre-Launch Release Audit**: Inspects Android Manifest, Gradle target SDK, iOS Info.plist, secrets, and cleartext HTTP before publishing.
- **Universal Compatibility**: Works out of the box in **Antigravity IDE (Google)**, **Claude Code CLI (Anthropic)**, and standard terminal/CI environments.
- **Bundled Sample Project**: Pre-configured with a Clean Architecture media discovery app powered by the **100% free, keyless TVMaze API**.

---

## ⚡ Quickstart

### 🤖 If using Google Antigravity IDE:
```text
1. /plan-feature ShowReviews "User reviews and rating breakdown for TV shows"
2. /api-to-feature ShowReviews
3. /code-review
4. Fix ticket TICKET-001
5. /ship
```

### 💻 If using Anthropic Claude Code CLI:
```bash
# Launch Claude in project root
claude

# Run native slash commands:
/plan-feature ShowReviews "User reviews and rating breakdown"
/api-to-feature ShowReviews
/code-review
/fix-ticket TICKET-001
/ship
```

---

# 🗺️ Phase 1: Feature Planning (`/plan-feature`)

Plan and design a complete, production-grade **Clean Architecture Feature Blueprint** before writing code. Automatically generates UI wireframes, BLoC state machines, data contracts, and test plans in `.plans/<name>.md`, then syncs the mock API payload to `schema_input.json`.

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Run in Chat / CLI:                                       │
│    /plan-feature ShowReviews "User reviews and ratings"     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Automatically Generated Blueprint:                       │
│    ├── .plans/show_reviews.md                               │
│    │   ├── 📱 UI Wireframe & Screen Hierarchy (Material 3)  │
│    │   ├── 🔄 BLoC Events & State Transition Matrix         │
│    │   ├── 🌐 API Schema Contract & Crash-Safe Types        │
│    │   └── 🧪 Unit & BLoC Test Coverage Strategy            │
│    └── schema_input.json (Auto-populated with mock payload) │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. 1-Click Instant Scaffolding (1 Second, 95% Token Saved): │
│    /api-to-feature ShowReviews                              │
└─────────────────────────────────────────────────────────────┘
```

### 💻 Usage Options:
```bash
# Option 1: Feature name only (Infers best-practice Clean Architecture)
/plan-feature ShowReviews

# Option 2: Feature name + user requirements (Recommended)
/plan-feature UserProfile "User profile screen with avatar, stats, watch history, and edit profile action"

# Option 3: Feature name + raw sample API JSON response
/plan-feature EpisodeGuide [{"id": 101, "season": 1, "number": 1, "name": "Pilot", "rating": 8.7}]
```

---

# ⚡ Phase 2: Full-Stack Scaffolder (`/api-to-feature`)

Turn any raw API JSON response into a complete, runnable **Clean Architecture Vertical Slice** in **1 second** using our hybrid deterministic engine.

```bash
/api-to-feature ShowCast
```

### 📦 The 10 Generated Artifacts (+ Auto-DI Injection):
```text
lib/
├── domain/
│   ├── entities/show_cast.dart                     # 1. Equatable Domain Entity
│   ├── repositories/show_cast_repository.dart      # 2. Repository Contract
│   └── usecases/get_show_cast.dart                 # 3. Domain UseCase
├── data/
│   ├── models/show_cast_model.dart                 # 4. Null-Safe Data Model
│   ├── datasources/show_cast_remote_data_source.dart# 5. Remote DataSource Impl
│   └── repositories/show_cast_repository_impl.dart # 6. Repository Implementation
├── presentation/
│   ├── blocs/show_cast/                            # 7. Event, State & BLoC
│   └── screens/show_cast_screen.dart               # 8. Complete UI Screen (Provider + Builder)
├── core/di/injection_container.dart             # 9. Auto-injected GetIt DI
test/
├── data/models/show_cast_model_test.dart           # 10. Model Serialization Unit Tests
└── presentation/blocs/show_cast_bloc_test.dart     # 11. BLoC Stream Unit Tests
```

---

# 📦 Phase 3: Instant Model Generator (`/api-to-model`)

Turn any raw API JSON response into production-grade **Clean Architecture Domain Entities**, **Data Models**, and **Unit Tests** in seconds with zero boilerplate.

```bash
# Reads schema_input.json by default:
/api-to-model ActorListResponse

# Custom mock file:
/api-to-model OrderDetails assets/mocks/sample_order.json

# Inline JSON payload:
/api-to-model Product {"id": 101, "title": "Headphones", "price": 99.99}
```

### 💡 Crash-Proof Type Safety:
- **Automatic Numeric Coercion**: Maps `int` vs `double` safely using `(json['key'] as num?)?.toDouble()`. No runtime `TypeError` crashes.
- **Auto-Sanitization**: Strips HTML tags from API strings automatically.
- **Deep Nested Mapping**: Flattens nested JSON structures into null-safe domain properties.

---

# 🛡️ Phase 4: Automated Code Review & Tickets (`/code-review`)

## 🏛️ How Code Review Works Under the Hood

```
                               ┌─────────────────────────────┐
                               │  User triggers /code-review │
                               └──────────────┬──────────────┘
                                              │
                    ┌─────────────────────────┴─────────────────────────┐
                    ▼                                                   ▼
       ┌─────────────────────────┐                         ┌─────────────────────────┐
       │   Automated Pre-Audit   │                         │ Clean Architecture &    │
       │ (flutter analyze & test)│                         │ Flutter Quality Audits  │
       └────────────┬────────────┘                         └────────────┬────────────┘
                    │                                                   │
                    └─────────────────────────┬─────────────────────────┘
                                              ▼
                               ┌─────────────────────────────┐
                               │   Interactive Review Report │
                               │   + Auto-Generated Tickets  │
                               │   (.tickets/YYYY-MM-DD/)    │
                               └──────────────┬──────────────┘
                                              │
                                              ▼
                               ┌─────────────────────────────┐
                               │  "Fix ticket TICKET-001"    │
                               │  Agent applies fix & tests  │
                               │  Ticket marked RESOLVED ✅  │
                               └─────────────────────────────┘
```

### 💻 Available Review Commands:
| Command | Action |
| :--- | :--- |
| **`/code-review`** | Full repository audit (`flutter analyze` + `test` + architecture + tickets). |
| **`/code-review lib/presentation/`** | Targeted audit on UI layer (memory leaks, controller disposal, const constructors). |
| **`/code-review lib/data/models/movie_model.dart`** | Deep inspection on a specific file. |
| **`/code-review git diff`** | Reviews uncommitted changes before you commit. |

---

## 🎫 The Automated Ticket System (`.tickets/`)

Whenever the review agent detects issues, it automatically organizes them into date-stamped tickets:

```text
.tickets/
└── 2026-08-18/
    ├── INDEX.md                                       # Summary table of daily tickets
    ├── TICKET-001-syntax-error-api-endpoints.md       # 🚨 Blocker (RESOLVED ✅)
    ├── TICKET-002-safe-cast-get-movie-details.md      # ⚠️ Warning (OPEN)
    └── TICKET-003-const-optimizations-search-screen.md# 💡 Suggestion (OPEN)
```

### 🛠️ How to Resolve Tickets:
- **Fix a specific ticket**:
  > *"Fix ticket TICKET-002"* or `/fix-ticket TICKET-002`
- **Fix all open tickets**:
  > *"Fix all open tickets in .tickets/2026-08-18/"*

The agent will:
1. Read ticket instructions.
2. Edit target files with drop-in fixes.
3. Run `flutter analyze` & `flutter test` to verify zero regression.
4. Mark ticket status **`RESOLVED`** ✅.

---

# 🚢 Phase 5: Pre-Launch Release Inspector (`/ship`)

Automates comprehensive multi-platform pre-flight verification before publishing to the App Store or Google Play.

```bash
/ship
```

### 📋 What `/ship` Audits:
- 🧪 **Quality Gates**: `flutter analyze` (0 errors/warnings) & `flutter test` (100% test pass).
- 📦 **App Versioning**: Validates `version: X.Y.Z+BuildNumber` format in `pubspec.yaml`.
- 🤖 **Android Platform**: Verifies permissions and flags cleartext traffic risks in `AndroidManifest.xml`.
- 🍎 **iOS Platform**: Verifies privacy descriptions and App Transport Security in `Info.plist`.
- 🔒 **Security Scan**: Detects hardcoded localhost/staging URLs (`http://`) and exposed credentials in `lib/`.
- 🚀 **Release Commands**: Outputs ready-to-run release build commands (`flutter build appbundle --release`, `flutter build ipa --release`).

---

# 🔍 Part 3: Architecture & Quality Guidelines

Audited against [`.agents/rules/flutter_clean_architecture.md`](.agents/rules/flutter_clean_architecture.md):

### 1. Clean Architecture Layer Purity
- **Domain Layer (`lib/domain/`)**: Pure Dart only. Zero dependencies on UI/Dio/Sqflite. All entities extend `Equatable`.
- **Data Layer (`lib/data/`)**: Robust JSON serialization (`fromJson`/`toJson`), exception-to-failure mappings, decoupled datasources.
- **Presentation Layer (`lib/presentation/`)**: BLoC state management with immutable states/events and zero business logic in widgets.

### 2. Flutter Performance & Memory Safety
- **Leak Prevention**: Strict disposal checks for `TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, and `Timer`.
- **Rebuild Optimization**: Enforces `const` constructors on immutable subtrees and avoids computations in `build()`.

### 3. Security & Resilience
- Flags hardcoded secrets, credentials, or insecure storage.
- Ensures async operations handle network timeouts and server errors gracefully.

---

# 🌐 Part 4: Cross-Platform Interoperability

| Tool / Environment | How It Integrates |
| :--- | :--- |
| **Antigravity IDE (Google)** | Automatically loads [`.agents/skills/`](.agents/skills/), [`.agents/rules/`](.agents/rules/flutter_clean_architecture.md), and [`.agents/hooks.json`](.agents/hooks.json). |
| **Claude Code CLI (Anthropic)** | Reads [`CLAUDE.md`](CLAUDE.md) and uses native slash commands in [`.claude/commands/`](.claude/commands/). |
| **Terminal / CI/CD Pipelines** | Executes [`./.agents/scripts/check_architecture.sh`](.agents/scripts/check_architecture.sh), [`./.agents/skills/code-reviewer/scripts/audit_code.sh`](.agents/skills/code-reviewer/scripts/audit_code.sh), and [`./.agents/skills/ship/scripts/pre_release_audit.sh`](.agents/skills/ship/scripts/pre_release_audit.sh). |

---

# 🛡️ Part 5: Deterministic AST Architecture Guard & Lifecycle Hooks

This repository is equipped with an automated **0-Token AST Architecture Linter Hook** ([`.agents/hooks.json`](.agents/hooks.json)) that continuously protects Clean Architecture layer purity in real time.

```
AI Edit / Tool Call ──▶ [PreToolUse Hook] ──▶ AST Boundary Check (<10ms) ──▶ Allowed / Denied 🚫
```

### 🧱 Enforced Layer Boundaries:

| Layer | Prohibited Imports & Leakages | Purpose |
| :--- | :--- | :--- |
| **Domain** (`lib/domain/`) | `package:flutter/*`, `package:dio/*`, `package:sqflite/*`, `lib/data/*`, `lib/presentation/*` | Pure Dart business logic & entities. |
| **Data** (`lib/data/`) | `lib/presentation/*`, `package:flutter/material.dart`, `package:flutter/cupertino.dart` | Decoupled data models & data sources. |
| **Presentation** (`lib/presentation/`) | Direct DataSources, direct `Dio` clients, raw database drivers | UI interacts strictly via UseCases & BLoC. |
| **Core** (`lib/core/`) | `lib/presentation/pages/*`, `lib/presentation/screens/*` | Shared utilities stay decoupled from specific UI screens. |

### 💻 Manual CLI & CI/CD Architecture Audit:
Developers and CI/CD pipelines can run the architecture check across the whole codebase anytime:

```bash
# Run standalone AST boundary audit:
./.agents/scripts/check_architecture.sh

# Or run the full pre-audit pipeline (Static analysis + AST check + Tests):
./.agents/skills/code-reviewer/scripts/audit_code.sh
```

