#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p artifacts
REPORT_PATH="artifacts/gitleaks-report.json"
CONFIG_PATH=".gitleaks.toml"

if command -v gitleaks >/dev/null 2>&1; then
  echo "Using local gitleaks binary."
  gitleaks detect \
    --source . \
    --config "$CONFIG_PATH" \
    --report-format json \
    --report-path "$REPORT_PATH" \
    --redact
  echo "Secret scan completed. Report: $REPORT_PATH"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "Using Dockerized gitleaks image (zricethezav/gitleaks:v8.24.2)."
  docker run --rm \
    -v "$ROOT_DIR:/repo" \
    zricethezav/gitleaks:v8.24.2 \
    detect \
    --source /repo \
    --config /repo/"$CONFIG_PATH" \
    --report-format json \
    --report-path /repo/"$REPORT_PATH" \
    --redact
  echo "Secret scan completed. Report: $REPORT_PATH"
  exit 0
fi

echo "ERROR: Neither gitleaks nor docker is available. Install one to run secret scanning."
exit 1
