# CI/CD Pipeline

## CI on Pull Requests

1. Checkout and dependency cache restore.
2. Java build and unit tests (`mvn verify`).
3. Frontend lint/test/build.
4. OpenAPI lint and SQL syntax checks.
5. Container image build scan (SAST + vulnerability scan).

## CD to Staging (merge to `main`)

1. Build and push immutable images tagged by commit SHA.
2. Apply manifests to staging namespace.
3. Run smoke tests against gateway health and core flows.
4. Publish deployment report.

## CD to Production

1. Manual approval gate.
2. Progressive rollout (canary 10% -> 50% -> 100%).
3. Auto rollback if SLO or error budget guardrail is breached.

## Artifact and Release Rules

- Every deploy references image digests, not mutable tags.
- Release notes generated from merged PRs.
- Database migrations run in controlled pre-deploy job.
