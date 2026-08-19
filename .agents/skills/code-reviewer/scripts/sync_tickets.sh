#!/usr/bin/env bash
# sync_tickets.sh - Keep a ticket folder's INDEX.md consistent with each ticket's Status.
#
# Source of truth = the `- **Status**:` line inside each TICKET-*.md file.
# The INDEX.md status column is derived from it.
#
# Usage:
#   sync_tickets.sh [FOLDER]           Validate (default). Prints drift; exits 1 if any.
#   sync_tickets.sh --fix [FOLDER]     Rewrite INDEX.md status cells to match ticket bodies.
#
# FOLDER defaults to the most recent .tickets/YYYY-MM-DD/ directory.

set -uo pipefail

FIX=0
FOLDER=""
for arg in "$@"; do
  case "$arg" in
    --fix) FIX=1 ;;
    *)     FOLDER="$arg" ;;
  esac
done

# Default to the most recent dated ticket folder.
if [ -z "$FOLDER" ]; then
  FOLDER="$(ls -d .tickets/*/ 2>/dev/null | sort | tail -1)"
fi
FOLDER="${FOLDER%/}"

if [ -z "$FOLDER" ] || [ ! -d "$FOLDER" ]; then
  echo "❌ No ticket folder found (looked for: '${FOLDER:-<none>}')." >&2
  exit 2
fi

INDEX="$FOLDER/INDEX.md"
if [ ! -f "$INDEX" ]; then
  echo "❌ INDEX.md not found in $FOLDER." >&2
  exit 2
fi

# --- Build id->status map from ticket bodies --------------------------------
MAP="$(mktemp)"
trap 'rm -f "$MAP"' EXIT

shopt -s nullglob
for f in "$FOLDER"/TICKET-*.md; do
  id="$(basename "$f" | grep -oE '^TICKET-[0-9]+')"
  [ -z "$id" ] && continue
  line="$(grep -m1 -iE '^[[:space:]]*-[[:space:]]*\*\*Status\*\*:' "$f" || true)"
  if printf '%s' "$line" | grep -qi 'RESOLVED'; then
    echo "$id RESOLVED" >> "$MAP"
  else
    echo "$id OPEN" >> "$MAP"
  fi
done

if [ ! -s "$MAP" ]; then
  echo "❌ No TICKET-*.md files found in $FOLDER." >&2
  exit 2
fi

# --- Validate mode ----------------------------------------------------------
drift=0
while read -r id want; do
  row="$(grep -F "[$id]" "$INDEX" || true)"
  if [ -z "$row" ]; then
    echo "⚠️  $id: no row in INDEX.md"
    drift=1
    continue
  fi
  cur_cell="$(printf '%s' "$row" | awk -F'|' '{print $4}')"
  if printf '%s' "$cur_cell" | grep -qi 'RESOLVED'; then cur="RESOLVED"; else cur="OPEN"; fi
  if [ "$cur" != "$want" ]; then
    echo "❌ $id: ticket says $want but INDEX says $cur"
    drift=1
  fi
done < "$MAP"

if [ "$FIX" -eq 0 ]; then
  if [ "$drift" -eq 0 ]; then
    echo "✅ INDEX.md is in sync with all ticket Status fields."
    exit 0
  fi
  echo ""
  echo "Run with --fix to reconcile INDEX.md to the ticket bodies."
  exit 1
fi

# --- Fix mode: rewrite only the Status cell (field 4) of matching rows ------
TMP="$(mktemp)"
awk -F'|' -v OFS='|' '
  NR==FNR { split($0, a, " "); status[a[1]] = a[2]; next }
  {
    line = $0
    for (id in status) {
      if (index(line, "[" id "]")) {
        n = split(line, f, "|")
        if (status[id] == "RESOLVED") { f[4] = " `RESOLVED` ✅ " }
        else                          { f[4] = " `OPEN` " }
        line = f[1]
        for (i = 2; i <= n; i++) line = line "|" f[i]
        break
      }
    }
    print line
  }
' "$MAP" "$INDEX" > "$TMP"

mv "$TMP" "$INDEX"
echo "✅ Reconciled INDEX.md status cells to match ticket bodies in $FOLDER."
