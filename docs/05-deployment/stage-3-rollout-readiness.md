# Stage 3 Rollout Readiness

## Goal

Execute a repeatable go/no-go rehearsal before staging or production rollout.

## Runner

- Script: `scripts/run-stage3-rollout-readiness.sh`
- Workflow: `.github/workflows/stage3-rollout-readiness.yml`

## What It Checks

- Core flow smoke tests
- Gateway/OpenAPI contract checks
- JWT key rotation rehearsal
- Load baseline checks (if `BASE_URL` and `AUTH_TOKEN` are provided)
- Secret scan and dependency audit (optional toggle)

## Output

- `artifacts/stage3-rollout-readiness.md`
- `artifacts/stage3-readiness-logs/*.log`

The script exits non-zero on `FAIL` or `BLOCKED` mandatory checks.

## Local Example

```bash
REQUIRE_LOAD_BASELINE=false \
RUN_SECURITY_SCANS=false \
./scripts/run-stage3-rollout-readiness.sh
```

## Staging/Prod Rehearsal Example

```bash
BASE_URL=https://staging-api.example.com \
AUTH_TOKEN=eyJhbGciOi... \
RUN_SECURITY_SCANS=true \
REQUIRE_LOAD_BASELINE=true \
./scripts/run-stage3-rollout-readiness.sh
```
