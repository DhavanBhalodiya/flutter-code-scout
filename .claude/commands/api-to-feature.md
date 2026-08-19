# `/api-to-feature <FeatureName> [OptionalFilePathOrJson]`

Converts a raw API JSON response into a complete, production-grade **Clean Architecture Vertical Slice** (Domain Entity, Data Model, DataSource, Repository, UseCase, BLoC, UI Screen, GetIt DI, Model Tests, and BLoC Unit Tests) using the hybrid deterministic engine with **95% token savings**.

## Usage
- Run `/api-to-feature <FeatureName>` (defaults to reading `schema_input.json`)
- Or `/api-to-feature <FeatureName> path/to/sample.json`
- Or `/api-to-feature <FeatureName> '{"id": 1, "name": "Item"}'`

## Instructions
1. Run:
   ```bash
   dart run tool/feature_scaffolder.dart $1 $2
   ```
2. Run `flutter analyze` and `flutter test` to verify zero compiler warnings and 100% test pass.
3. Report the list of created files to the user with clickable links.
