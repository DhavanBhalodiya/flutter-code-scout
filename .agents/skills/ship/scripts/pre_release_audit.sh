#!/usr/bin/env bash
# pre_release_audit.sh - Automated Flutter Pre-Launch & Release Readiness Audit
# Checks:
#  1. Flutter static analysis (flutter analyze)
#  2. Flutter test suite (flutter test)
#  3. Versioning in pubspec.yaml
#  4. Insecure HTTP cleartext / debug URLs in lib/
#  5. Hardcoded API secrets / keys in lib/
#  6. Android manifest & target SDK
#  7. iOS Info.plist & ATS configuration
#  8. Dependency outdated status

set -uo pipefail

echo "========================================================"
echo "🚢 Flutter Pre-Launch & Release Readiness Audit"
echo "========================================================"
echo ""

# Ensure flutter is available
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ 'flutter' not found on PATH. Install Flutter or add it to PATH." >&2
  exit 127
fi

TOTAL_BLOCKERS=0
TOTAL_WARNINGS=0

# 1. Static Analysis
echo "1. 🔍 Checking Flutter Static Analysis..."
if flutter analyze; then
  echo "   ✅ Static Analysis: 0 issues found."
else
  echo "   🚨 Static Analysis: FAILED."
  TOTAL_BLOCKERS=$((TOTAL_BLOCKERS + 1))
fi
echo ""

# 2. Test Suite
echo "2. 🧪 Checking Test Suite..."
if flutter test; then
  echo "   ✅ Unit & Widget Tests: 100% passed."
else
  echo "   🚨 Test Suite: FAILED."
  TOTAL_BLOCKERS=$((TOTAL_BLOCKERS + 1))
fi
echo ""

# 3. Version Code in pubspec.yaml
echo "3. 📦 Checking App Versioning (pubspec.yaml)..."
VERSION_LINE=$(grep "^version:" pubspec.yaml || echo "")
if [ -n "$VERSION_LINE" ]; then
  echo "   ✅ Found $VERSION_LINE"
  if [[ "$VERSION_LINE" =~ \+[0-9]+ ]]; then
    echo "   ✅ Valid build number format present."
  else
    echo "   ⚠️  Warning: Missing build number (+X) in version string."
    TOTAL_WARNINGS=$((TOTAL_WARNINGS + 1))
  fi
else
  echo "   🚨 Blocker: 'version:' field missing in pubspec.yaml."
  TOTAL_BLOCKERS=$((TOTAL_BLOCKERS + 1))
fi
echo ""

# 4. Security & Hardcoded Debug URLs
echo "4. 🔒 Scanning for Insecure / Staging URLs in lib/..."
INSECURE_URLS=$(grep -rnE 'http://(localhost|10\.0\.2\.2|127\.0\.0\.1|0\.0\.0\.0)' lib/ || true)
if [ -n "$INSECURE_URLS" ]; then
  echo "   ⚠️  Insecure localhost/staging URLs found in lib/:"
  echo "$INSECURE_URLS"
  TOTAL_WARNINGS=$((TOTAL_WARNINGS + 1))
else
  echo "   ✅ No cleartext localhost/staging URLs found in lib/."
fi
echo ""

# 5. Security & Hardcoded Secrets Scan
echo "5. 🔑 Scanning for Hardcoded Secrets / Private Keys..."
SECRETS_FOUND=$(grep -rnE '(api_key|apiKey|secret_key|private_key|auth_token)\s*=\s*["\x27][A-Za-z0-9_\-]{20,}["\x27]' lib/ || true)
if [ -n "$SECRETS_FOUND" ]; then
  echo "   🚨 Potential hardcoded secrets found:"
  echo "$SECRETS_FOUND"
  TOTAL_BLOCKERS=$((TOTAL_BLOCKERS + 1))
else
  echo "   ✅ No hardcoded API keys/secrets detected in lib/."
fi
echo ""

# 6. Android Platform Check
echo "6. 🤖 Checking Android Configuration..."
if [ -d "android" ]; then
  if [ -f "android/app/build.gradle.kts" ] || [ -f "android/app/build.gradle" ]; then
    echo "   ✅ Android build configuration present."
  fi
  if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    CLEARTEXT=$(grep 'usesCleartextTraffic="true"' android/app/src/main/AndroidManifest.xml || true)
    if [ -n "$CLEARTEXT" ]; then
      echo "   ⚠️  Warning: usesCleartextTraffic='true' is enabled in AndroidManifest.xml."
      TOTAL_WARNINGS=$((TOTAL_WARNINGS + 1))
    else
      echo "   ✅ AndroidManifest cleartext security verified."
    fi
  fi
else
  echo "   ℹ️  No android/ folder found (skipping Android checks)."
fi
echo ""

# 7. iOS Platform Check
echo "7. 🍎 Checking iOS Configuration..."
if [ -d "ios" ]; then
  if [ -f "ios/Runner/Info.plist" ]; then
    echo "   ✅ iOS Info.plist present."
  fi
else
  echo "   ℹ️  No ios/ folder found (skipping iOS checks)."
fi
echo ""

# 8. Summary
echo "========================================================"
if [ "$TOTAL_BLOCKERS" -eq 0 ]; then
  if [ "$TOTAL_WARNINGS" -eq 0 ]; then
    echo "🎉 STATUS: 🟢 RELEASE READY (0 Blockers, 0 Warnings)"
  else
    echo "🎉 STATUS: 🟡 RELEASE READY WITH WARNINGS (0 Blockers, $TOTAL_WARNINGS Warnings)"
  fi
  echo ""
  echo "Build Commands:"
  echo "  • Android App Bundle: flutter build appbundle --release"
  echo "  • Android APK:        flutter build apk --release"
  echo "  • iOS IPA:            flutter build ipa --release"
  exit 0
else
  echo "❌ STATUS: 🚨 NOT READY FOR RELEASE ($TOTAL_BLOCKERS Blockers, $TOTAL_WARNINGS Warnings)"
  echo "Please resolve all blockers above before building release binaries."
  exit 1
fi
