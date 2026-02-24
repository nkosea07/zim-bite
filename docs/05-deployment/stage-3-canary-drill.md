# Stage 3 Canary Drill

## Goal

Execute phased rollout validation (`10% -> 50% -> 100%`) and capture SLO observations as release evidence.

## Runner

- Script: `scripts/run-stage3-canary-drill.sh`
- Workflow: `.github/workflows/stage3-canary-drill.yml`

## Inputs

- `BASE_URL` (required)
- `AUTH_TOKEN` (required)
- `CANARY_PHASES` (default: `10,50,100`)
- `FULL_CHECKOUT_RATE` (default: `10`)
- `FULL_TRACKING_RATE` (default: `20`)
- `PHASE_DURATION` (default: `2m`)

## Output Artifacts

- `artifacts/canary/stage3-canary-drill.md`
- `artifacts/canary/phase-*.log`
- `artifacts/canary/phase-*-summary.json`

## Local Example

```bash
BASE_URL=https://staging-api.example.com \
AUTH_TOKEN=eyJhbGciOi... \
CANARY_PHASES=10,50,100 \
./scripts/run-stage3-canary-drill.sh
```

## Evidence Checklist

- Attach generated canary report to release ticket.
- Confirm each phase result is `PASS`.
- Confirm overall decision is `GO`.
- Record production go/no-go decision with timestamp and approver.
