#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ARTIFACT_DIR="${ARTIFACT_DIR:-artifacts}"
LOG_DIR="$ARTIFACT_DIR/stage3-readiness-logs"
REPORT_FILE="${REPORT_FILE:-$ARTIFACT_DIR/stage3-rollout-readiness.md}"
REQUIRE_LOAD_BASELINE="${REQUIRE_LOAD_BASELINE:-true}"
RUN_SECURITY_SCANS="${RUN_SECURITY_SCANS:-false}"

mkdir -p "$LOG_DIR"

RESULT_ROWS=()
OVERALL_STATUS="GO"

append_result() {
  local check_name="$1"
  local status="$2"
  local details="$3"
  RESULT_ROWS+=("| $check_name | $status | $details |")

  if [[ "$status" == "FAIL" || "$status" == "BLOCKED" ]]; then
    OVERALL_STATUS="NO-GO"
  fi
}

run_check() {
  local check_name="$1"
  local command="$2"
  local log_file="$LOG_DIR/$3.log"

  if eval "$command" >"$log_file" 2>&1; then
    append_result "$check_name" "PASS" "Completed successfully. Log: \`$log_file\`"
  else
    append_result "$check_name" "FAIL" "Command failed. Log: \`$log_file\`"
  fi
}

run_check "Core Flow Smoke" "./scripts/run-core-flow-smoke.sh" "core-flow-smoke"
run_check "Gateway Contract" "./scripts/check-gateway-contract.sh" "gateway-contract"
run_check "JWT Rotation Rehearsal" "./scripts/run-jwt-rotation-rehearsal.sh" "jwt-rotation-rehearsal"

if [[ -n "${BASE_URL:-}" && -n "${AUTH_TOKEN:-}" ]]; then
  run_check "Load Baseline" "./scripts/run-load-baseline.sh" "load-baseline"
elif [[ "$REQUIRE_LOAD_BASELINE" == "true" ]]; then
  append_result "Load Baseline" "BLOCKED" "Missing \`BASE_URL\` and/or \`AUTH_TOKEN\`."
else
  append_result "Load Baseline" "SKIP" "Skipped because load baseline is optional in this run."
fi

if [[ "$RUN_SECURITY_SCANS" == "true" ]]; then
  run_check "Secret Scan" "./scripts/run-secret-scan.sh" "secret-scan"
  run_check "Dependency Audit" "./scripts/run-dependency-audit.sh" "dependency-audit"
else
  append_result "Secret Scan" "SKIP" "Skipped (\`RUN_SECURITY_SCANS=false\`)."
  append_result "Dependency Audit" "SKIP" "Skipped (\`RUN_SECURITY_SCANS=false\`)."
fi

{
  echo "# Stage 3 Rollout Readiness Report"
  echo
  echo "- Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "- Overall decision: **$OVERALL_STATUS**"
  echo
  echo "| Check | Status | Details |"
  echo "|---|---|---|"
  for row in "${RESULT_ROWS[@]}"; do
    echo "$row"
  done
} > "$REPORT_FILE"

cat "$REPORT_FILE"

if [[ "$OVERALL_STATUS" == "NO-GO" ]]; then
  exit 1
fi
