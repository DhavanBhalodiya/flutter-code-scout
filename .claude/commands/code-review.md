# /code-review Command for Claude Code CLI

When the user runs `/code-review` (optionally specifying target files or diff), execute the following workflow:

## Step 1: Pre-Audit Checks
Run the automated pre-audit script:
```bash
./.agents/skills/code-reviewer/scripts/audit_code.sh
```

## Step 2: Architecture & Quality Review
Inspect the target code against the guidelines in `.agents/rules/flutter_clean_architecture.md`:
1. **Clean Architecture Boundaries**:
   - `domain/`: Pure Dart, no UI/framework dependencies, immutable `Equatable` entities.
   - `data/`: Model mapping, exception-to-failure translation, repository contracts.
   - `presentation/`: BLoC state management, no direct data layer imports, zero business logic in widgets.
2. **Flutter Memory & Performance**:
   - Proper disposal of controllers, animation controllers, scroll controllers, and streams in `dispose()`.
   - Use `const` on static widget subtrees.
3. **Security**:
   - No hardcoded secrets, keys, or sensitive credentials.

## Step 3: Generate Review Report & Create Tickets
1. Output the structured review report with health score and findings.
2. For every **Blocker**, **Warning**, or **Suggestion** found:
   - Create a date-stamped folder `.tickets/YYYY-MM-DD/` if it doesn't exist.
   - Create a ticket file `.tickets/YYYY-MM-DD/TICKET-XXX-<name>.md` with status `OPEN`, problem details, and proposed diff.
   - Update `.tickets/YYYY-MM-DD/INDEX.md` with the ticket summary.
