#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATEWAY_CONFIG="$ROOT_DIR/services/api-gateway/src/main/resources/application.yml"
SPECS_DIR="$ROOT_DIR/docs/03-api/specs"
ARTIFACT_DIR="$ROOT_DIR/artifacts"
REPORT_FILE="$ARTIFACT_DIR/gateway-contract-report.md"

mkdir -p "$ARTIFACT_DIR"

ROUTE_ENTRIES_FILE="$(mktemp)"
REPORT_ROWS_FILE="$(mktemp)"
EXTRA_SPECS_FILE="$(mktemp)"
trap 'rm -f "$ROUTE_ENTRIES_FILE" "$REPORT_ROWS_FILE" "$EXTRA_SPECS_FILE"' EXIT

awk '
  /- id:[[:space:]]*/ {
    id=$3
  }
  /Path=\/api\/v1\// {
    path=$0
    sub(/^.*Path=/, "", path)
    sub(/\*\*.*/, "", path)
    sub(/\/$/, "", path)
    print id "|" path
  }
' "$GATEWAY_CONFIG" | sort -u > "$ROUTE_ENTRIES_FILE"

if [[ ! -s "$ROUTE_ENTRIES_FILE" ]]; then
  echo "ERROR: No gateway routes were parsed from $GATEWAY_CONFIG"
  exit 1
fi

failure=0

while IFS='|' read -r route_id route_prefix; do
  if [[ -z "$route_id" || -z "$route_prefix" ]]; then
    continue
  fi

  spec_file="$SPECS_DIR/$route_id.yaml"

  if [[ ! -f "$spec_file" ]]; then
    echo "| $route_id | $route_prefix | $route_id.yaml | FAIL | Missing spec file: docs/03-api/specs/$route_id.yaml |" >> "$REPORT_ROWS_FILE"
    failure=1
    continue
  fi

  escaped_prefix="$(printf '%s\n' "$route_prefix" | sed 's/[.[\*^$()+?{|]/\\&/g')"
  has_server_url=0
  has_paths=0

  if grep -qE "^[[:space:]]*-[[:space:]]*url:[[:space:]]*${escaped_prefix}[[:space:]]*$" "$spec_file"; then
    has_server_url=1
  fi

  if grep -q "^  /" "$spec_file"; then
    has_paths=1
  fi

  if [[ "$has_server_url" -eq 1 && "$has_paths" -eq 1 ]]; then
    echo "| $route_id | $route_prefix | $route_id.yaml | PASS | Server URL matches route prefix and paths are present |" >> "$REPORT_ROWS_FILE"
  else
    echo "| $route_id | $route_prefix | $route_id.yaml | FAIL | Spec must include server url $route_prefix and at least one path entry |" >> "$REPORT_ROWS_FILE"
    failure=1
  fi
done < "$ROUTE_ENTRIES_FILE"

for spec_path in "$SPECS_DIR"/*.yaml; do
  spec_id="$(basename "$spec_path" .yaml)"
  if ! grep -q "^${spec_id}|" "$ROUTE_ENTRIES_FILE"; then
    echo "- $spec_id.yaml" >> "$EXTRA_SPECS_FILE"
    failure=1
  fi
done

{
  echo "# Gateway Contract Report"
  echo
  echo "| Route ID | Prefix | Spec | Result | Note |"
  echo "|---|---|---|---|---|"
  sort "$REPORT_ROWS_FILE"

  if [[ -s "$EXTRA_SPECS_FILE" ]]; then
    echo
    echo "## Unmapped Specs"
    cat "$EXTRA_SPECS_FILE"
  fi
} > "$REPORT_FILE"

cat "$REPORT_FILE"

if [[ "$failure" -ne 0 ]]; then
  echo "ERROR: Gateway contract checks failed."
  exit 1
fi

echo "Gateway contract checks passed."
