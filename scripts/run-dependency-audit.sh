#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p artifacts
REPORT_PATH="artifacts/trivy-dependency.sarif"
TRIVY_EXIT_CODE="${TRIVY_EXIT_CODE:-0}"

run_trivy_local() {
  trivy fs \
    --scanners vuln \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --exit-code "$TRIVY_EXIT_CODE" \
    --format sarif \
    --output "$REPORT_PATH" \
    .
}

run_trivy_docker() {
  local cache_dir="${TRIVY_CACHE_DIR:-$ROOT_DIR/.trivy-cache}"
  mkdir -p "$cache_dir"

  docker run --rm \
    -v "$ROOT_DIR:/work" \
    -v "$cache_dir:/root/.cache/trivy" \
    aquasec/trivy:0.57.1 \
    fs \
    --scanners vuln \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --exit-code "$TRIVY_EXIT_CODE" \
    --format sarif \
    --output /work/"$REPORT_PATH" \
    /work
}

if command -v trivy >/dev/null 2>&1; then
  echo "Using local trivy binary."
  run_trivy_local
  echo "Dependency audit completed. Report: $REPORT_PATH"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "Using Dockerized trivy image (aquasec/trivy:0.57.1)."
  run_trivy_docker
  echo "Dependency audit completed. Report: $REPORT_PATH"
  exit 0
fi

echo "ERROR: Neither trivy nor docker is available. Install one to run dependency audit."
exit 1
