---
name: api-to-model
description: >-
  Triggered when the user runs `/api-to-model` or asks to convert an API JSON response
  into Flutter Clean Architecture Domain Entities, Data Models, and Unit Tests. Defaults
  to reading `schema_input.json`.
---

# API-to-Model Generator Skill

Automated generator that converts JSON payloads into production-grade, Clean Architecture **Domain Entities**, **Data Models**, and **Unit Tests** for Flutter applications.

> ⚡ **Token discipline:** When invoked via `/api-to-model`, this workflow runs inside a dedicated subagent so the large source JSON and generated code never enter the main conversation (see `.claude/commands/api-to-model.md`). Regardless of how it is triggered, **never read the whole source file into context** — sample one representative record as described in Step 1.

---

## 🎯 Command Syntax
```text
/api-to-model <EntityName> [OptionalFilePathOrJson]
```

- If no file/JSON is passed after `<EntityName>`, it **defaults to reading `schema_input.json`**.
- Example 1 (Default file): `/api-to-model UserProfile`
- Example 2 (Custom file): `/api-to-model OrderDetails mocks/sample_order.json`
- Example 3 (Inline JSON): `/api-to-model Product {"id": 1, "price": 99.99}`

---

## 🔄 Generation Workflow

### Step 1: Sample the JSON — never read the whole file
The source often contains many near-identical records, but the schema is fully defined by **one**. Reading the entire file wastes tokens (a 30-record fixture is ~15k tokens for zero extra schema information). Extract a single representative record with a shell command and read **only that output** — do not open the source file with the Read tool.

1. **Resolve the source:**
   - Omitted / no file arg → default file `schema_input.json`.
   - A file path → that file.
   - Inline JSON → write it to `/tmp/api_to_model_input.json` first, then sample it the same way.
2. **Extract ONE record with `jq`** (preferred). This one expression covers all three common shapes — a bare array, a wrapper object whose value is an array (paginated responses like `{"users": [...], "total": ...}`), and a single object:
   ```bash
   jq 'if type=="array" then .[0]
       elif ([.[]?|select(type=="array")]|length)>0 then [.[]?|select(type=="array")][0][0]
       else . end' <SOURCE_FILE>
   ```
   Read only this single-record output to infer the schema. (If the first top-level array is not the record list, adjust the path, e.g. `jq '.data[0]' <SOURCE_FILE>`.)
3. **Fallback if `jq` is unavailable:** `head -c 4000 <SOURCE_FILE>` to detect the shape, then read a bounded slice — still never the whole file.

### Step 2: Inferred Type Mapping & Defensive Parsing
Apply Senior-Engineer defensive casting in `fromJson`:
- **Numbers / Doubles**: `(json['key'] as num?)?.toDouble() ?? 0.0`
- **Integers**: `json['key'] as int? ?? 0`
- **Strings**: `json['key'] as String? ?? ''`
- **Booleans**: `json['key'] as bool? ?? false`
- **String Lists**: `(json['key'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []`
- **Nested Objects**: Generate nested `<ChildEntity>` in `domain/entities/` and `<ChildModel>` in `data/models/`.

### Step 3: Generate Files
1. **Domain Entity** (`lib/domain/entities/<snake_case>.dart`):
   - Pure Dart only (no serialization/JSON annotations).
   - Extends `Equatable` with complete `props`.
   - Immutable `final` properties.
   - `copyWith()` method.
2. **Data Model** (`lib/data/models/<snake_case>_model.dart`):
   - Extends the Domain Entity.
   - `factory fromJson(Map<String, dynamic> json)`.
   - `Map<String, dynamic> toJson()`.
   - `toEntity()` and `factory fromEntity(Entity entity)`.
3. **Unit Test** (`test/data/models/<snake_case>_model_test.dart`):
   - Tests `fromJson` parsing matching the sample JSON.
   - Tests `toJson` output structure.
   - Tests `toEntity` domain mapping.

### Step 4: Verification
Run `flutter analyze` and `flutter test` to ensure zero compilation or type errors.
