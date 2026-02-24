#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -z "${BASE_URL:-}" ]]; then
  echo "ERROR: BASE_URL is required."
  exit 1
fi

if [[ -z "${AUTH_TOKEN:-}" ]]; then
  echo "ERROR: AUTH_TOKEN is required."
  exit 1
fi

K6_SCRIPT="load/k6/core-api-baseline.js"
SUMMARY_FILE="${SUMMARY_FILE:-artifacts/load-baseline-summary.json}"
OUTPUT_DIR="$(dirname "$SUMMARY_FILE")"
mkdir -p "$OUTPUT_DIR"

if command -v k6 >/dev/null 2>&1; then
  echo "Using local k6 binary."
  k6 run --summary-export "$SUMMARY_FILE" "$K6_SCRIPT"
  echo "Load baseline completed. Summary: $SUMMARY_FILE"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "Using Dockerized k6 image (grafana/k6:0.49.0)."
  docker run --rm \
    -e BASE_URL \
    -e AUTH_TOKEN \
    -e CHECKOUT_DURATION \
    -e CHECKOUT_RATE \
    -e CHECKOUT_PREALLOCATED_VUS \
    -e CHECKOUT_MAX_VUS \
    -e CHECKOUT_P95_MS \
    -e CHECKOUT_MIN_RPS \
    -e TRACKING_DURATION \
    -e TRACKING_RATE \
    -e TRACKING_PREALLOCATED_VUS \
    -e TRACKING_MAX_VUS \
    -e TRACKING_P95_MS \
    -e TRACKING_MIN_RPS \
    -v "$ROOT_DIR:/work" \
    -w /work \
    grafana/k6:0.49.0 \
    run --summary-export "$SUMMARY_FILE" "$K6_SCRIPT"
  echo "Load baseline completed. Summary: $SUMMARY_FILE"
  exit 0
fi

echo "ERROR: Neither k6 nor docker is available. Install k6 or docker to run load baselines."
exit 1
