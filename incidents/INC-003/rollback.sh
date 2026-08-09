#!/usr/bin/env bash
set -Eeuo pipefail

NS="${NS:-northstar-dev}"
DEPLOYMENT="${DEPLOYMENT:-checkout}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$SCRIPT_DIR/evidence"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/northstar-floci-k3s.yaml}"

if [[ -f "$STATE_DIR/traffic.pid" ]]; then
  PID="$(cat "$STATE_DIR/traffic.pid")"
  kill "$PID" 2>/dev/null || true
  rm -f "$STATE_DIR/traffic.pid"
fi

if [[ -s "$STATE_DIR/original-image.txt" ]]; then
  ORIGINAL_IMAGE="$(cat "$STATE_DIR/original-image.txt")"
  kubectl set image deployment/"$DEPLOYMENT" checkout="$ORIGINAL_IMAGE" -n "$NS"
else
  kubectl rollout undo deployment/"$DEPLOYMENT" -n "$NS"
fi

kubectl rollout status deployment/"$DEPLOYMENT" -n "$NS" --timeout=3m
date --iso-8601=seconds > "$STATE_DIR/rollback-completed.txt"
echo "Rollback complete. Verify SLO and alert recovery."
