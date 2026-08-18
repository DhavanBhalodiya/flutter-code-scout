# Project Guidelines: Movie Scout (Flutter Clean Architecture)

This file instructs Claude / Claude Code CLI on how to interact with this project, run commands, and execute code reviews.

---

## 🛠️ Common Commands

- **Run Static Analysis**: `flutter analyze`
- **Run Unit Tests**: `flutter test`
- **Run Code Review Pre-Audit**: `./.agents/skills/code-reviewer/scripts/audit_code.sh`
- **Run App**: `flutter run`

---

## 🛡️ Code Review Protocol (`/code-review` or `/review`)

When asked to review code, run a code review, or execute `/code-review`:
1. **Pre-Audit**: Run `./.agents/skills/code-reviewer/scripts/audit_code.sh` or `flutter analyze` + `flutter test`.
2. **Architecture Check**: Enforce the Clean Architecture rules defined in [.agents/rules/flutter_clean_architecture.md](.agents/rules/flutter_clean_architecture.md):
   - **Domain**: Pure business logic, zero dependencies on UI/Dio/Sqflite, immutable `Equatable` entities.
   - **Data**: Models map to entities (`fromJson`, `toJson`), repositories catch low-level exceptions and map them to `Failure`s.
   - **Presentation**: BLoC pattern, zero business logic in widgets, immutable states & events.
   - **Performance**: Dispose all controllers/streams/timers, use `const` constructors on static subtrees.
3. **Format Output & Create Tickets**:
   - Follow the report template in [.agents/skills/code-reviewer/templates/review_template.md](.agents/skills/code-reviewer/templates/review_template.md).
   - Automatically write actionable tickets to `.tickets/YYYY-MM-DD/TICKET-XXX-<name>.md` with status `OPEN`.
4. **Resolve Tickets**: When the user requests `Fix ticket <ID>` or `Fix all open tickets`, inspect the ticket file, execute the code fix, run tests, and mark the ticket `RESOLVED`.

---

## 🏛️ Codebase Style & Architecture Rules

- Use Flutter **Material 3** cinematic dark theme definitions in `lib/core/theme/`.
- All dependency injection is managed via GetIt in `lib/core/di/injection_container.dart`.
- Public TV API integration uses TVMaze (`https://api.tvmaze.com`) requiring zero API keys.
