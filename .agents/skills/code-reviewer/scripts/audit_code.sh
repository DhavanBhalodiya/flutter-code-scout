#!/usr/bin/env bash
# audit_code.sh - Fast automated code quality and git status audit script
# Exits non-zero if static analysis or the test suite fails, so it can gate CI/CD.

set -uo pipefail

echo "=========================================="
echo "🛡️  Running Code Review Pre-Audit Checks"
echo "=========================================="

# Ensure the Flutter toolchain is available before running checks.
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ 'flutter' not found on PATH. Install Flutter or add it to PATH." >&2
  exit 127
fi

fail=0

echo ""
echo "1. Checking Flutter Static Analysis..."
flutter analyze || fail=1

echo ""
echo "2. Checking Test Suite..."
flutter test || fail=1

echo ""
echo "3. Modified / Staged Files:"
git status --short

echo ""
if [ "$fail" -ne 0 ]; then
  echo "❌ Pre-audit FAILED. Fix analyze/test errors above before deep review."
else
  echo "✅ Pre-audit complete. Ready for deep architecture review."
fi

exit "$fail"
