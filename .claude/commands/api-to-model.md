---
description: Generate Clean Architecture entity, data model, and unit test from JSON
argument-hint: <EntityName> [file path | inline JSON] (source defaults to schema_input.json)
---

# /api-to-model Command for Claude Code CLI

**Entity name:** $1
**Source (optional):** $2

> `$1` is the entity name (e.g. `ActorListResponse`) — required.
> `$2` is the JSON source — a file path (e.g. `mocks/sample_order.json`) or inline JSON.
> If `$1` is empty, ask the user for the entity name **before** launching the subagent.
> If `$2` is empty, the default input file `schema_input.json` is used.

## Step 1: Delegate generation to a subagent (keep the main context clean)
Do **NOT** read the JSON or generate files in this main conversation. The source file can be large (many near-identical records) and the generated Dart is ~1,000 lines — none of that should pollute the main context.

Launch a **single** subagent (Agent tool, `subagent_type: general-purpose`) with a task that says:

- Read and follow `.agents/skills/api-to-model/SKILL.md` exactly.
- Entity name: `$1`. Source: `$2` (default `schema_input.json`).
- **Sample ONE representative record** using the `jq` command in SKILL.md Step 1 — do **not** read the whole source file into context.
- Generate the 3 Clean Architecture files: the Domain Entity (`lib/domain/entities/<snake_case>.dart`), the Data Model (`lib/data/models/<snake_case>_model.dart`), and the Serialization Unit Test (`test/data/models/<snake_case>_model_test.dart`).
- Run `flutter analyze` and `flutter test`.
- **Return ONLY a compact summary:** the 3 generated file paths + the `analyze`/`test` pass-fail counts. Do **NOT** paste file contents or the source JSON back.

## Step 2: Relay the result
Report the subagent's summary to the user: the generated file paths and the verification results. If verification failed, surface the failing output the subagent reported.
