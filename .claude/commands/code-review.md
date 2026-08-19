---
description: Run a Clean Architecture + Flutter quality code review and generate tickets
argument-hint: [path | file | "git diff"] (optional; defaults to whole codebase)
---

# /code-review Command for Claude Code CLI

**Review scope:** $ARGUMENTS

> If the scope above is empty, review the entire codebase.
> If it is a path (e.g. `lib/presentation/`), review only files under that path.
> If it is a file (e.g. `lib/data/models/movie_model.dart`), do a deep inspection of that file.
> If it is `git diff`, review only staged and uncommitted changes.

Execute the following workflow:

## Step 1: Pre-Audit Checks
Run the automated pre-audit script. **Forward the review scope** so `flutter analyze` /
`flutter test` only run against the requested subtree:
```bash
# Path or file scope → pass it through so analyze/test are scoped:
./.agents/skills/code-reviewer/scripts/audit_code.sh lib/presentation/screens
# Whole-codebase or `git diff` review → run with no argument:
./.agents/skills/code-reviewer/scripts/audit_code.sh
```
Pass `$ARGUMENTS` as the scope when it is a path or file; omit it when the scope is empty or
`git diff` (the script accepts an optional `[SCOPE]` path).

## Step 2: Architecture & Quality Review
Inspect the target code (per the scope above) against the guidelines in `.agents/rules/flutter_clean_architecture.md`:
1. **Clean Architecture Boundaries**:
   - `domain/`: Pure Dart, no UI/framework dependencies, immutable `Equatable` entities.
   - `data/`: Model mapping, exception-to-failure translation, repository contracts.
   - `presentation/`: BLoC state management, no direct data layer imports, zero business logic in widgets.
2. **Flutter Memory & Performance**:
   - Proper disposal of controllers, animation controllers, scroll controllers, focus nodes, stream subscriptions, and timers in `dispose()`.
   - Use `const` on static widget subtrees.
3. **Security**:
   - No hardcoded secrets, keys, or sensitive credentials.
4. **Internationalization** (see rules §5):
   - No hardcoded user-facing strings; locale-aware date/number formatting via `intl`; directional layout (`start`/`end`).

## Step 3: Generate Review Report & Create Tickets
1. Output the structured review report using the single source-of-truth template at
   `.agents/skills/code-reviewer/templates/review_template.md` (including the health-score rubric).
2. For every **Blocker**, **Warning**, or **Suggestion** found:
   - Create a date-stamped folder `.tickets/YYYY-MM-DD/` if it doesn't exist.
   - Create a ticket file `.tickets/YYYY-MM-DD/TICKET-XXX-<name>.md` with status `OPEN`, problem details, and proposed diff.
   - Update `.tickets/YYYY-MM-DD/INDEX.md` with the ticket summary.
3. If **no issues** are found, do not create an empty `.tickets/` folder — just report a clean result.
