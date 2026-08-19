# `/plan-feature <FeatureName> [OptionalDescriptionOrJson]`

Plans and designs a complete, production-grade **Flutter Clean Architecture Feature Blueprint** before code is generated. Automatically defines UI wireframe hierarchy, BLoC state machines, data schema contracts, test strategies, and populates `schema_input.json`.

## Usage
- `/plan-feature <FeatureName>`
- `/plan-feature <FeatureName> <Description of user requirements>`
- `/plan-feature <FeatureName> '<Raw JSON sample>'`

## Instructions
1. Review user requirements and infer full Clean Architecture components (Domain Entity, Model, DataSource, Repository, UseCase, BLoC, Screen).
2. Generate the comprehensive architecture blueprint file at `.plans/<feature_snake_case>.md` following the template in [`.agents/skills/plan-feature/templates/feature_plan_template.md`](../../.agents/skills/plan-feature/templates/feature_plan_template.md).
3. Automatically write the sample API JSON response into `schema_input.json`.
4. Report the plan summary to the user with a clickable link to `.plans/<feature_snake_case>.md`.
5. Guide the user to run `/api-to-feature <FeatureName>` to scaffold the entire vertical slice in 1 second.
