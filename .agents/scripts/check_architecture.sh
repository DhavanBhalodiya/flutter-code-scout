#!/usr/bin/env bash
set -e

# ==============================================================================
# AST Architecture Boundary Checker for Flutter Clean Architecture
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🛡️  Running Clean Architecture AST Boundary Scan..."
echo "📂 Project root: $ROOT_DIR"

cd "$ROOT_DIR"

# Run the Dart AST Linter across lib/
if dart "$SCRIPT_DIR/ast_arch_linter.dart" "$ROOT_DIR/lib"; then
  echo "✨ Architecture is 100% compliant. Zero layer leakage detected."
  exit 0
else
  echo "⚠️  Architecture violations detected above. Please fix layer boundaries."
  exit 1
fi
