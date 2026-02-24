# Load Testing Baseline

## Goal

Establish repeatable baseline performance checks for:

- Checkout API: `POST /api/v1/orders/corporate`
- Tracking API: `GET /api/v1/deliveries/orders/{orderId}/tracking`

## Tooling

- k6 script: `load/k6/core-api-baseline.js`
- Runner: `scripts/run-load-baseline.sh`
- GitHub workflow: `.github/workflows/load-baseline.yml`

## SLO Thresholds

- Checkout:
  - Error rate: `< 1%`
  - p95 latency: `< 800ms`
  - Throughput floor: `> 0.8 req/s`
- Tracking:
  - Error rate: `< 1%`
  - p95 latency: `< 500ms`
  - Throughput floor: `> 1.5 req/s`

## Required Environment

- `BASE_URL`: environment base URL (gateway or API entrypoint)
- `AUTH_TOKEN`: valid bearer token for protected routes

## Local Execution

```bash
BASE_URL=https://staging-api.example.com \
AUTH_TOKEN=eyJhbGciOi... \
./scripts/run-load-baseline.sh
```

If `k6` is not installed locally, the runner uses Docker image `grafana/k6:0.49.0`.

## CI Execution

Run `Load Baseline` workflow with:

- `base_url`
- optional `checkout_rate`, `tracking_rate`, and `duration`

CI reads `LOAD_TEST_AUTH_TOKEN` repository secret and uploads:

- `artifacts/load-baseline-summary.json`

## Notes

- Use a non-production token and environment for baseline runs.
- Default rates are intentionally conservative because gateway-level rate limits apply.
