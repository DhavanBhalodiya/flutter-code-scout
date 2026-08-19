---
name: ship
description: >-
  Triggered when the user runs `/ship` or asks to prepare/verify a release build of the Flutter application.
  Performs an automated multi-platform pre-flight audit across Quality, Versioning, Android, iOS, and Security.
---

# 🚢 Flutter Pre-Launch & Release Readiness Skill (`/ship`)

An automated pre-flight release inspector that verifies the Flutter project against production release standards before building `.aab` or `.ipa` artifacts.

---

## 🎯 Command Syntax

```text
/ship
```

---

## ⚡ Execution Protocol for the Agent

When the user runs `/ship` or requests release verification:

### Step 1: Execute Automated Pre-Release Audit Script
1. Run the pre-release script via terminal:
   ```bash
   ./.agents/skills/ship/scripts/pre_release_audit.sh
   ```
2. Capture the output status, blockers, and warnings.

### Step 2: Perform In-Depth Platform & Configuration Review
1. **Versioning**: Verify `version:` in `pubspec.yaml` (format `x.y.z+build`).
2. **Android Checks**: Check `android/app/build.gradle.kts` / `AndroidManifest.xml` for permissions and insecure flags.
3. **iOS Checks**: Check `ios/Runner/Info.plist` for privacy permission descriptions and ATS settings.
4. **Security Audit**: Scan `lib/` to confirm zero hardcoded credentials, test tokens, or staging URLs.

### Step 3: Generate Release Report
1. Format the findings using [`templates/release_report_template.md`](templates/release_report_template.md).
2. If issues are found:
   - Categorize as 🚨 **Blocker** (prevents release) or ⚠️ **Warning** (informational).
   - If blockers exist, generate actionable tickets in `.tickets/YYYY-MM-DD/`.
3. If all checks pass:
   - Mark status as **`🟢 RELEASE READY`**.
   - Provide direct release build commands (`flutter build appbundle --release`, `flutter build ipa --release`).
