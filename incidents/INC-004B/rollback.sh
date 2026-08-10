#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$ROOT/evidence/traffic.pid" ]] && kill "$(cat "$ROOT/evidence/traffic.pid")" 2>/dev/null || true
curl -fsS "http://127.0.0.1:18081/admin/leak?enabled=false" || true
kubectl rollout restart deployment/jvm-cache-demo -n northstar-dev
kubectl rollout status deployment/jvm-cache-demo -n northstar-dev --timeout=3m
[[ -f "$ROOT/evidence/port-forward.pid" ]] && kill "$(cat "$ROOT/evidence/port-forward.pid")" 2>/dev/null || true
date -Is > "$ROOT/evidence/rollback-completed.txt"
echo "Rollback complete. Verify heap, GC, latency and alerts recover."
