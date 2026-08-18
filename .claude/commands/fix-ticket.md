---
description: Apply the fix described in a ticket, verify it, and mark it RESOLVED
argument-hint: <TICKET_ID | path> (e.g. TICKET-002) or "all open"
---

# /fix-ticket Command for Claude Code CLI

**Ticket to fix:** $ARGUMENTS

> If the value above is a ticket ID (e.g. `TICKET-002`) or a path, resolve that single ticket.
> If it is `all open` (or `all open tickets`), resolve every ticket with status `OPEN` in the most recent `.tickets/YYYY-MM-DD/` folder.
> If it is empty, ask the user which ticket to fix.

## Step 1: Locate Ticket
Find and read the specified ticket file under `.tickets/YYYY-MM-DD/`.

## Step 2: Apply Code Fix
Apply the code modification described in the ticket's "Action Plan & Proposed Fix" section.

## Step 3: Run Verification
Execute the verification command:
```bash
flutter analyze
flutter test
```

## Step 4: Update Ticket Status
1. Mark the ticket status in the markdown file as `RESOLVED ✅` with the resolution date.
2. Update `.tickets/YYYY-MM-DD/INDEX.md` to reflect `RESOLVED ✅`.
3. Provide a summary of changes to the user.
