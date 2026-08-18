# 🛡️ Flutter Code Review Agent & Ticket System

An intelligent, automated **Code Review Pair-Programmer & Ticket Management System** tailored for Flutter & Dart applications. Built with **Antigravity Customizations**, **Clean Architecture Enforcement**, and cross-platform compatibility for **Claude Code CLI**, **Cursor**, and **CI/CD pipelines**.

---

## 🚀 Key Highlights

- **Automated Code Auditing**: Audits code for Clean Architecture compliance, memory leaks, performance traps, security leaks, and Dart/Flutter best practices.
- **Smart Ticket Generation**: Automatically logs issues as structured tickets in `.tickets/YYYY-MM-DD/`.
- **One-Command Auto-Fixing**: Resolve issues simply by telling the agent `"Fix ticket TICKET-001"` or running `/fix-ticket TICKET-001`.
- **Universal Compatibility**: Works seamlessly in **Antigravity IDE (Google)**, **Claude Code CLI (Anthropic)**, and standard terminal/CI environments.
- **Bundled Sample Project**: Comes pre-configured with a Clean Architecture media discovery app powered by the **100% free, keyless TVMaze API** for immediate testing.

---

## ⚡ Quickstart

### 🤖 If using Google Antigravity IDE:
1. Open this repository in Antigravity.
2. In the AI chat, run:
   ```text
   /code-review
   ```
3. To resolve any generated ticket, prompt:
   ```text
   Fix ticket TICKET-002
   ```

### 💻 If using Anthropic Claude Code CLI:
1. In your terminal, navigate to the folder and launch Claude:
   ```bash
   claude
   ```
2. Use the native slash commands:
   ```text
   /code-review
   /fix-ticket TICKET-002
   ```

---

## 🏛️ How It Works Under the Hood

```
                               ┌─────────────────────────────┐
                               │  User triggers /code-review │
                               └──────────────┬──────────────┘
                                              │
                    ┌─────────────────────────┴─────────────────────────┐
                    ▼                                                   ▼
       ┌─────────────────────────┐                         ┌─────────────────────────┐
       │   Automated Pre-Audit   │                         │ Clean Architecture &    │
       │ (flutter analyze & test)│                         │ Flutter Quality Audits  │
       └────────────┬────────────┘                         └────────────┬────────────┘
                    │                                                   │
                    └─────────────────────────┬─────────────────────────┘
                                              ▼
                               ┌─────────────────────────────┐
                               │   Interactive Review Report │
                               │   + Auto-Generated Tickets  │
                               │   (.tickets/YYYY-MM-DD/)    │
                               └──────────────┬──────────────┘
                                              │
                                              ▼
                               ┌─────────────────────────────┐
                               │  "Fix ticket TICKET-001"    │
                               │  Agent applies fix & tests  │
                               │  Ticket marked RESOLVED ✅  │
                               └─────────────────────────────┘
```

---

## 💻 Available Review Commands

You can invoke the code reviewer directly from your chat prompt using on-demand commands:

| Command | Action |
| :--- | :--- |
| **`/code-review`** | Runs pre-audit checks (`flutter analyze` + `test`), audits all architectural layers, and outputs a full health score report. |
| **`/code-review lib/presentation/`** | Performs a targeted audit on the presentation layer (memory leaks, controller disposal, const constructors). |
| **`/code-review lib/data/models/movie_model.dart`** | Performs a deep inspection on a specific file. |
| **`/code-review git diff`** | Reviews only current staged and uncommitted changes before you commit. |
| **`/api-to-model <EntityName>`** | Reads `schema_input.json` and instantly generates the pure Domain Entity, Data Model with safe parsing, and serialization Unit Tests. |

---

## 🎫 The Automated Ticket System (`.tickets/`)

Whenever the review agent detects issues (**Blockers**, **Warnings**, or **Suggestions**), it automatically organizes them into date-stamped tickets:

### Directory Structure:
```text
.tickets/
└── 2026-08-18/
    ├── INDEX.md                                       # Summary table of daily tickets
    ├── TICKET-001-syntax-error-api-endpoints.md       # 🚨 Blocker (RESOLVED ✅)
    ├── TICKET-002-safe-cast-get-movie-details.md      # ⚠️ Warning (OPEN)
    └── TICKET-003-const-optimizations-search-screen.md# 💡 Suggestion (OPEN)
```

### Ticket Structure:
Every ticket contains:
1. **Severity Badge**: `🚨 BLOCKER`, `⚠️ WARNING`, or `💡 SUGGESTION`.
2. **Status**: `OPEN` ➡️ `RESOLVED` ✅.
3. **Problem Description**: Root cause and impact.
4. **Action Plan & Diff**: Exact proposed code changes.
5. **Verification Command**: Automated validation step (`flutter analyze`, `flutter test`).

---

## 🛠️ How to Resolve Tickets

You don't need to manually write fixes. Simply prompt the agent:

- **Fix a specific ticket**:
  > *"Fix ticket TICKET-002"* or `/fix-ticket TICKET-002`
- **Fix all open tickets**:
  > *"Fix all open tickets in .tickets/2026-08-18/"*

The agent will:
1. Read the ticket instructions.
2. Edit the target file with the drop-in fix.
3. Run `flutter analyze` & `flutter test` to verify zero regression.
4. Update the ticket status to **`RESOLVED`** ✅.

---

## 🔍 Audit Rules & Dimensions

The agent audits against the rules configured in [`.agents/rules/flutter_clean_architecture.md`](.agents/rules/flutter_clean_architecture.md):

### 1. Clean Architecture Layer Purity
- **Domain Layer (`lib/domain/`)**: Pure Dart only. Zero imports from `flutter/material.dart`, `dio`, `sqflite`, or `data/`. All entities extend `Equatable`.
- **Data Layer (`lib/data/`)**: Robust JSON serialization (`fromJson`/`toJson`), exception-to-failure mappings, and decoupled datasources.
- **Presentation Layer (`lib/presentation/`)**: BLoC state management with immutable states/events and zero business logic in widgets.

### 2. Flutter Performance & Memory Safety
- **Leak Prevention**: Strict disposal checks for `TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, and `Timer`.
- **Rebuild Optimization**: Enforces `const` constructors on immutable subtrees and avoids computations in `build()`.

### 3. Security & Resilience
- Flags hardcoded secrets, credentials, or insecure storage.
- Ensures all async operations handle network timeouts and server errors gracefully.

---

## 🌐 Cross-Platform Interoperability

| Tool / Environment | How It Integrates |
| :--- | :--- |
| **Antigravity IDE (Google)** | Automatically loads [`.agents/skills/code-reviewer/`](.agents/skills/code-reviewer/SKILL.md) and [`.agents/rules/`](.agents/rules/flutter_clean_architecture.md). |
| **Claude Code CLI (Anthropic)** | Reads [`CLAUDE.md`](CLAUDE.md) and uses native slash commands in [`.claude/commands/`](.claude/commands/). |
| **Terminal / CI/CD Pipelines** | Directly executes [`./.agents/skills/code-reviewer/scripts/audit_code.sh`](.agents/skills/code-reviewer/scripts/audit_code.sh). |

---

## 🧪 Verification & Audit Script

You can manually run the pre-audit suite in your terminal anytime:

```bash
# Run automated pre-audit checks
./.agents/skills/code-reviewer/scripts/audit_code.sh
```
