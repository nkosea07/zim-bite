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

ARTIFACT_DIR="${ARTIFACT_DIR:-artifacts}"
CANARY_DIR="$ARTIFACT_DIR/canary"
REPORT_FILE="${REPORT_FILE:-$CANARY_DIR/stage3-canary-drill.md}"
PHASES="${CANARY_PHASES:-10,50,100}"
FULL_CHECKOUT_RATE="${FULL_CHECKOUT_RATE:-10}"
FULL_TRACKING_RATE="${FULL_TRACKING_RATE:-20}"
PHASE_DURATION="${PHASE_DURATION:-2m}"

mkdir -p "$CANARY_DIR"

OVERALL_STATUS="GO"

{
  echo "# Stage 3 Canary Drill Report"
  echo
  echo "- Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "- Base URL: \`$BASE_URL\`"
  echo
  echo "| Phase | Checkout RPS | Tracking RPS | Checkout p95 (ms) | Checkout error | Tracking p95 (ms) | Tracking error | Result |"
  echo "|---|---:|---:|---:|---:|---:|---:|---|"
} > "$REPORT_FILE"

for phase in ${PHASES//,/ }; do
  if ! [[ "$phase" =~ ^[0-9]+$ ]]; then
    echo "ERROR: invalid phase value '$phase'. Use comma-separated integers like 10,50,100."
    exit 1
  fi

  checkout_rate=$(( FULL_CHECKOUT_RATE * phase / 100 ))
  tracking_rate=$(( FULL_TRACKING_RATE * phase / 100 ))
  if [[ "$checkout_rate" -lt 1 ]]; then checkout_rate=1; fi
  if [[ "$tracking_rate" -lt 1 ]]; then tracking_rate=1; fi

  phase_summary="$CANARY_DIR/phase-${phase}-summary.json"
  phase_log="$CANARY_DIR/phase-${phase}.log"

  phase_result="PASS"
  if ! SUMMARY_FILE="$phase_summary" \
    CHECKOUT_DURATION="$PHASE_DURATION" \
    TRACKING_DURATION="$PHASE_DURATION" \
    CHECKOUT_RATE="$checkout_rate" \
    TRACKING_RATE="$tracking_rate" \
    ./scripts/run-load-baseline.sh > "$phase_log" 2>&1; then
    phase_result="FAIL"
    OVERALL_STATUS="NO-GO"
  fi

  checkout_p95=$(jq -r '.metrics["http_req_duration{scenario:checkout}"].values["p(95)"] // "n/a"' "$phase_summary" 2>/dev/null || echo "n/a")
  checkout_err=$(jq -r '.metrics["http_req_failed{scenario:checkout}"].values.rate // "n/a"' "$phase_summary" 2>/dev/null || echo "n/a")
  tracking_p95=$(jq -r '.metrics["http_req_duration{scenario:tracking}"].values["p(95)"] // "n/a"' "$phase_summary" 2>/dev/null || echo "n/a")
  tracking_err=$(jq -r '.metrics["http_req_failed{scenario:tracking}"].values.rate // "n/a"' "$phase_summary" 2>/dev/null || echo "n/a")

  if [[ "$checkout_p95" == "n/a" || "$tracking_p95" == "n/a" ]]; then
    phase_result="FAIL"
    OVERALL_STATUS="NO-GO"
  fi

  echo "| ${phase}% | $checkout_rate | $tracking_rate | $checkout_p95 | $checkout_err | $tracking_p95 | $tracking_err | $phase_result |" >> "$REPORT_FILE"
done

echo >> "$REPORT_FILE"
echo "- Overall decision: **$OVERALL_STATUS**" >> "$REPORT_FILE"
echo "- Logs: \`$CANARY_DIR/phase-*.log\`" >> "$REPORT_FILE"
echo "- Summaries: \`$CANARY_DIR/phase-*-summary.json\`" >> "$REPORT_FILE"

cat "$REPORT_FILE"

if [[ "$OVERALL_STATUS" == "NO-GO" ]]; then
  exit 1
fi
