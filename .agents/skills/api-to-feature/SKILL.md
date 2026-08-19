---
name: api-to-feature
description: >-
  Triggered when the user runs `/api-to-feature <FeatureName>` or asks to scaffold a complete
  end-to-end Clean Architecture feature (Entity, Model, UseCase, BLoC, GetIt DI, and Tests)
  from API JSON using the hybrid token-efficient engine. Defaults to reading `schema_input.json`.
---

# ⚡ Hybrid API-to-Feature Scaffolder Skill (95% Token Reduction)

An autonomous generator that turns any API JSON response into a complete, production-grade **Clean Architecture Vertical Slice** in seconds.

---

## 🎯 Command Syntax
```text
/api-to-feature <FeatureName> [OptionalFilePathOrJson]
```

### Examples:
- **Default file** (reads `schema_input.json`):
  ```text
  /api-to-feature ShowCast
  ```
- **Custom mock path**:
  ```text
  /api-to-feature EpisodeDetails assets/mocks/sample_episode.json
  ```
- **Inline JSON payload**:
  ```text
  /api-to-feature Product {"id": 101, "title": "Headphones", "price": 99.99}
  ```

---

## ⚡ How It Works Under the Hood

The skill leverages the **Hybrid Deterministic Synthesis Engine** (`tool/feature_scaffolder.dart`) to achieve **95% token savings** over standard LLM code generation:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User runs: /api-to-feature <FeatureName>                 │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Executes tool/feature_scaffolder.dart)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Scaffolds Complete Vertical Slice:                       │
│    ├── lib/domain/entities/<name>.dart (Pure & Equatable)   │
│    ├── lib/data/models/<name>_model.dart (Null-Safe JSON)   │
│    ├── lib/data/datasources/<name>_remote_data_source.dart  │
│    ├── lib/domain/repositories/<name>_repository.dart       │
│    ├── lib/data/repositories/<name>_repository_impl.dart    │
│    ├── lib/domain/usecases/get_<name>.dart (UseCase)        │
│    ├── lib/presentation/blocs/<name>/ (Event, State, BLoC)  │
│    ├── lib/presentation/screens/<name>_screen.dart (UI)     │
│    ├── test/data/models/<name>_model_test.dart (Model Tests)│
│    ├── test/presentation/blocs/<name>_bloc_test.dart (Tests)│
│    └── lib/core/di/injection_container.dart (GetIt Auto-DI) │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Automated Validation:                                    │
│    Runs `flutter analyze` & `flutter test` automatically    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Execution Protocol for the Agent

When the user runs `/api-to-feature <FeatureName>`:
1. **Resolve input source**:
   - If argument 2 is provided, use that file path or JSON string.
   - Otherwise, default to `schema_input.json`.
2. **Execute Scaffolder CLI**:
   ```bash
   dart run tool/feature_scaffolder.dart <FeatureName> <Source>
   ```
3. **Verify with Analyzer & Tests**:
   ```bash
   flutter analyze && flutter test
   ```
4. **Respond to User**:
   - Provide a concise summary of created files with clickable `file:///` links.
