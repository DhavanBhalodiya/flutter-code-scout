---
name: code-reviewer
description: >-
  Triggered when the user runs `/code-review` or explicitly requests a code review.
  Automated code review agent specialized in Flutter, Dart, Clean Architecture, BLoC state management,
  memory safety, performance optimization, and security audits.
---

# Code Reviewer Agent Skill

This skill provides an automated code review workflow tailored for Flutter applications using Clean Architecture and BLoC.

---

## 🎯 Review Workflow

When requested to review code (a specific file, git diff, PR, or the entire codebase), follow this systematic procedure:

### Step 1: Scope & Diff Analysis
1. Determine the target files:
   - If reviewing uncommitted changes: inspect `git diff` or `git status`.
   - If reviewing specific files: read the target files completely using `view_file`.
   - If reviewing a whole feature: inspect all files in the feature slice across layers (`domain/`, `data/`, `presentation/`, `core/`).
2. Run static analysis: execute `flutter analyze` via `run_command` to detect any syntax, type, or linting errors.

### Step 2: Layer-by-Layer Architecture Audit
Audit the code against the [Clean Architecture Rules](../../rules/flutter_clean_architecture.md):
- **Domain Layer**: Check for zero imports from `flutter/material.dart`, `dio`, `sqflite`, or `data/` layer. Verify all entities extend `Equatable`.
- **Data Layer**: Verify `models/` convert cleanly (`fromJson`, `toJson`, `toEntity`, `fromEntity`). Verify `repositories/` catch low-level exceptions and map them to domain `Failure`s.
- **Presentation Layer**: Verify widgets delegate all state and side-effects to BLoC events. Verify no direct calls to `data/` datasources.
- **Core Layer**: Check configuration, DI registration, and network clients.

### Step 3: Performance, Memory & Bug Checks
- **Resource Cleanup**: Check that all controllers (`TextEditingController`, `ScrollController`, `AnimationController`), streams, and timers are disposed in `dispose()`.
- **Widget Efficiency**: Check for missing `const` constructors on immutable subtrees.
- **Null Safety & Type Casts**: Ensure safe casting on dynamic JSON (`(json['key'] as num?)?.toDouble() ?? 0.0`).
- **Error States**: Verify that every BLoC emits an Error state when failures occur, and that the UI renders a retry button.

### Step 4: Security & Secrets Check
- Ensure no private tokens, API keys, credentials, or sensitive URLs are hardcoded in source files.

### Step 5: Generate Actionable Tickets in `.tickets/YYYY-MM-DD/`
For any Blocker, Warning, or Suggestion identified during review:
1. Create a dated folder `.tickets/YYYY-MM-DD/` if it does not exist.
2. Generate individual ticket files `TICKET-XXX-<short-slug>.md` with status `OPEN`, problem description, and proposed code diffs.
3. Update `.tickets/YYYY-MM-DD/INDEX.md` with the ticket summary table.

### Step 6: Resolving Tickets (`Fix ticket <ID>`)
When the user asks to fix a ticket (e.g. `Fix ticket TICKET-001` or `Fix all open tickets`):
1. Locate and read the ticket file in `.tickets/YYYY-MM-DD/`.
2. Apply the requested code fix using file editing tools.
3. Run the verification command specified in the ticket (`flutter analyze`, `flutter test`).
4. Update the ticket status in the markdown file to **`RESOLVED`** with the resolution timestamp.

---

## 📊 Severity Classification

- 🚨 **[BLOCKER]**: Architectural boundary violation, memory leak, unhandled crash, or security vulnerability. Must be resolved before merging.
- ⚠️ **[WARNING]**: Inefficient widget rebuild, missing error state, unhandled edge case, or potential type mismatch.
- 💡 **[SUGGESTION]**: Readability improvement, missing `const`, documentation comment, or minor refactoring opportunity.
- ✅ **[GOOD PRACTICE]**: Commendation highlighting clean, well-tested, or decoupled code.

---

## 📝 Review Report Template

```markdown
# 🛡️ Code Review Report
**Scope**: `<Files or Feature Reviewed>`
**Overall Health Score**: `<Score>/100 (<Grade: A+, A, B, C, F>)`

---

### 🚨 Blockers (Must Fix)
- **File**: `[file_basename](file:///path/to/file#L10)`
  - **Issue**: Description of the blocker.
  - **Why it matters**: Explanation of impact.
  - **Suggested Fix**:
    ```dart
    // Proposed drop-in code fix
    ```

---

### ⚠️ Warnings (Review Needed)
- **File**: `[file_basename](file:///path/to/file#L25)`
  - **Issue**: Description of warning.
  - **Suggested Fix**: ...

---

### 💡 Suggestions & Optimizations
- **File**: `[file_basename](file:///path/to/file#L50)`
  - **Optimization**: Add `const` constructor / extract sub-widget.

---

### ✅ Commendations & Strengths
- Highlights of good practices found in the code.
```
