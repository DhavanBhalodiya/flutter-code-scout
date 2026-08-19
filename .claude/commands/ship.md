# `/ship`

Performs an automated multi-platform pre-flight release audit for the Flutter application across Quality, Versioning, Android, iOS, and Security before building App Store and Google Play release packages.

## Usage
- `/ship`

## Instructions
1. Run the automated pre-release audit suite:
   ```bash
   ./.agents/skills/ship/scripts/pre_release_audit.sh
   ```
2. Inspect `pubspec.yaml` versioning, Android Manifest/Gradle, iOS Info.plist, and scan `lib/` for secrets or insecure cleartext URLs.
3. Present the Release Readiness Report based on [`.agents/skills/ship/templates/release_report_template.md`](../../.agents/skills/ship/templates/release_report_template.md).
4. If release ready, provide the exact production build commands (`flutter build appbundle --release` / `flutter build ipa --release`).
