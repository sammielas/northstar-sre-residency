#!/usr/bin/env bash
set -euo pipefail

DASHBOARD="${1:?Usage: $0 <dashboard-json> <configmap-name>}"
CONFIGMAP="${2:?Usage: $0 <dashboard-json> <configmap-name>}"

ROOT="$(git rev-parse --show-toplevel)"
INPUT="$ROOT/platform/observability/grafana/dashboards/$DASHBOARD"
OUTPUT="$ROOT/platform/observability/grafana/configmaps/${CONFIGMAP}.yaml"

if [[ ! -f "$INPUT" ]]; then
  echo "ERROR: dashboard not found: $INPUT"
  exit 1
fi

jq empty "$INPUT"

mkdir -p "$(dirname "$OUTPUT")"

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

kubectl create configmap "$CONFIGMAP" \
  -n monitoring \
  --from-file="$DASHBOARD=$INPUT" \
  --dry-run=client \
  -o yaml > "$TMP"

kubectl label \
  --local \
  -f "$TMP" \
  grafana_dashboard=1 \
  -o yaml > "$OUTPUT"

echo "Generated: $OUTPUT"
