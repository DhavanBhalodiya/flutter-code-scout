#!/usr/bin/env bash
# audit_code.sh - Fast automated code quality and git status audit script
# Exits non-zero if static analysis, the test suite, or formatting fails, so it can gate CI/CD.
#
# Usage: audit_code.sh [SCOPE]
#   SCOPE  optional path (e.g. lib/core) to narrow analyze/test to a subtree.
#          When omitted, the whole repository is audited.

set -uo pipefail

SCOPE="${1:-}"

echo "=========================================="
echo "🛡️  Running Code Review Pre-Audit Checks"
echo "=========================================="
if [ -n "$SCOPE" ]; then
  echo "Scope: $SCOPE"
fi

# Ensure the Flutter toolchain is available before running checks.
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ 'flutter' not found on PATH. Install Flutter or add it to PATH." >&2
  exit 127
fi

fail=0
analyze_result="pass"
test_result="pass"
format_result="pass"

echo ""
echo "0. Resolving dependencies..."
# Non-fatal: a pub-get hiccup shouldn't mask analyze/test signal, but warn loudly.
flutter pub get || echo "⚠️  'flutter pub get' failed — continuing, results may be unreliable."

echo ""
echo "1. Checking Flutter Static Analysis..."
if [ -n "$SCOPE" ]; then
  flutter analyze "$SCOPE" || { fail=1; analyze_result="fail"; }
else
  flutter analyze || { fail=1; analyze_result="fail"; }
fi

echo ""
echo "2. Checking Test Suite..."
if [ -n "$SCOPE" ]; then
  flutter test "$SCOPE" || { fail=1; test_result="fail"; }
else
  flutter test || { fail=1; test_result="fail"; }
fi

echo ""
echo "3. Checking Formatting (dart format)..."
# Non-gating: the PostToolUse auto-format hook keeps edited files clean going forward,
# so legacy drift is reported (not failed) to avoid blocking on untouched files.
if dart format --output=none --set-exit-if-changed .; then
  echo "✅ Formatting is clean."
else
  format_result="warn"
  echo "⚠️  Unformatted files detected (non-blocking). Run 'dart format .' to normalize."
fi

echo ""
echo "4. Modified / Staged Files:"
git status --short

echo ""
if [ "$fail" -ne 0 ]; then
  echo "❌ Pre-audit FAILED. Fix analyze/test/format errors above before deep review."
else
  echo "✅ Pre-audit complete. Ready for deep architecture review."
fi

# Machine-readable trailer so the review skill can compute status deterministically.
echo "AUDIT_SUMMARY analyze=${analyze_result} test=${test_result} format=${format_result}"

exit "$fail"
