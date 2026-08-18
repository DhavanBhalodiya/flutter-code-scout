# /fix-ticket Command for Claude Code CLI

When the user runs `/fix-ticket <TICKET_ID_OR_PATH>` or asks to resolve tickets:

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
