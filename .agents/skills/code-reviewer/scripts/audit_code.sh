#!/usr/bin/env bash
# audit_code.sh - Fast automated code quality and git status audit script

echo "=========================================="
echo "🛡️  Running Code Review Pre-Audit Checks"
echo "=========================================="

echo ""
echo "1. Checking Flutter Static Analysis..."
flutter analyze

echo ""
echo "2. Checking Test Suite..."
flutter test

echo ""
echo "3. Modified / Staged Files:"
git status --short

echo ""
echo "✅ Pre-audit complete. Ready for deep architecture review."
