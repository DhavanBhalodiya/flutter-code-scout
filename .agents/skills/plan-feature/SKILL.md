---
name: plan-feature
description: >-
  Triggered when the user runs `/plan-feature <FeatureName>` or asks to design/plan a new Flutter Clean
  Architecture feature before writing code. Generates a comprehensive feature blueprint, UI state machine,
  API JSON schema, test plan, and auto-populates `schema_input.json`.
---

# 🗺️ Flutter Feature Planner Skill (`/plan-feature`)

An intelligent architectural planner that converts a feature idea or API requirement into a structured, production-grade **Clean Architecture Blueprint** before any code is generated.

---

## 🎯 Command Syntax

```text
/plan-feature <FeatureName> [OptionalDescriptionOrJson]
```

### Examples:
- **Planning by Feature Name**:
  ```text
  /plan-feature ShowReviews
  ```
- **Planning with Goal / User Requirements**:
  ```text
  /plan-feature UserProfile User profile screen with avatar, stats, watch history, and edit profile action
  ```
- **Planning with Sample API JSON**:
  ```text
  /plan-feature MovieCast [{"id": 1, "name": "Actor Name", "character": "Character Name", "avatarUrl": "https://..."}]
  ```

---

## ⚡ Execution Protocol for the Agent

When the user triggers `/plan-feature <FeatureName>`:

### Step 1: Elicit & Synthesize Feature Requirements
1. **Feature Scope Analysis**:
   - Determine what the feature is intended to do (screens, state transitions, API endpoints, actions).
   - If the user provided detailed requirements or sample JSON, incorporate them directly.
   - If requirements are brief or ambiguous, establish sensible defaults aligned with Flutter Material 3 and Clean Architecture best practices.

### Step 2: Generate Feature Plan Document
1. Create directory `.plans/` if it does not exist.
2. Generate the markdown file at `.plans/<feature_snake_case>.md` using [`templates/feature_plan_template.md`](templates/feature_plan_template.md) as the reference structure:
   - **User Journey & Edge Cases**: Offline support, shimmer loading, empty states, error retry.
   - **Architecture Slice**: Domain entities, use cases, repository contracts, and data models.
   - **BLoC State Machine**: All events and states (`Initial`, `Loading`, `Loaded`, `Empty`, `Error`).
   - **UI Breakdown**: Widget hierarchy, responsive layout, `Semantics` accessibility.
   - **Data Contract & Safe Types**: JSON schema with crash-proof null safety parsing rules.
   - **Test Matrix**: Model unit tests, usecase tests, and BLoC transition tests.

### Step 3: Auto-Populate `schema_input.json`
1. Write the synthesized mock API JSON payload directly to [`schema_input.json`](../../schema_input.json).
2. Ensure the JSON is well-formatted and contains representative sample values for all fields.

### Step 4: Present Summary & Provide 1-Click Next Step
1. Present an executive summary of the planned feature with a clickable link to `.plans/<feature_snake_case>.md`.
2. Provide the immediate next command to execute deterministic scaffolding:
   ```text
   /api-to-feature <FeatureName>
   ```
