---
description: Generate Clean Architecture entity, data model, and unit test from JSON
argument-hint: <EntityName> [file path | inline JSON] (source defaults to schema_input.json)
---

# /api-to-model Command for Claude Code CLI

**Entity name:** $1
**Source (optional):** $2

> `$1` is the entity name (e.g. `ActorListResponse`) — required.
> `$2` is the JSON source — a file path (e.g. `mocks/sample_order.json`) or inline JSON.
> If `$1` is empty, ask the user for the entity name.
> If `$2` is empty, read the default input file `schema_input.json`.

## Step 1: Resolve Source JSON
1. If no source (`$2`) is given, read the default input file: `schema_input.json`.
2. If a file path is provided, read that file.
3. If inline JSON is passed, parse the string. (Note: file-based input is more reliable than inline JSON for complex payloads.)
4. If the payload is a `List`, use the first item `list[0]` to infer the schema.

## Step 2: Generate Clean Architecture Files
Generate 3 files for the entity `$1`:

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
