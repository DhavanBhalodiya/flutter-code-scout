---
name: api-to-model
description: >-
  Triggered when the user runs `/api-to-model` or asks to convert an API JSON response
  into Flutter Clean Architecture Domain Entities, Data Models, and Unit Tests. Defaults
  to reading `schema_input.json`.
---

# API-to-Model Generator Skill

Automated generator that converts JSON payloads into production-grade, Clean Architecture **Domain Entities**, **Data Models**, and **Unit Tests** for Flutter applications.

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

### Step 1: Read & Normalize JSON
1. If argument is omitted or is a filename, read the file (default: `schema_input.json`).
2. Parse JSON. If the payload is a `List`, extract the first item `list[0]` to infer the schema.

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
