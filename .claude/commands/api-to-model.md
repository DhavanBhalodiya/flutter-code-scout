# /api-to-model Command for Claude Code CLI

When the user runs `/api-to-model <EntityName> [OptionalSource]`:

## Step 1: Resolve Source JSON
1. If no source argument is given, read the default input file: `schema_input.json`.
2. If a filepath is provided (e.g. `mock.json`), read that file.
3. If inline JSON is passed, parse the string.

## Step 2: Generate Clean Architecture Files
Generate 3 files for the entity `<EntityName>`:

1. **Domain Entity** (`lib/domain/entities/<snake_case>.dart`):
   - Pure immutable Dart class extending `Equatable`.
   - `copyWith()` method.
   - Zero UI/framework imports.

2. **Data Model** (`lib/data/models/<snake_case>_model.dart`):
   - Extends the domain entity.
   - `factory <EntityName>Model.fromJson(Map<String, dynamic> json)` with safe casting (`num?` to `double`, null checks).
   - `Map<String, dynamic> toJson()`.
   - `toEntity()` and `factory <EntityName>Model.fromEntity(...)`.

3. **Serialization Unit Test** (`test/data/models/<snake_case>_model_test.dart`):
   - Validates `fromJson`, `toJson`, and domain entity conversion.

## Step 3: Run Verification
Run:
```bash
flutter analyze
flutter test
```
Notify the user with the generated file paths and verification results.
