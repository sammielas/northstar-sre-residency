#!/usr/bin/env bash
set -euo pipefail
NS="${NS:-northstar-dev}"
DEPLOY="${DEPLOY:-checkout}"
EVIDENCE="incidents/INC-004/evidence"
mkdir -p "$EVIDENCE"

{
 date
 kubectl get pods -n "$NS" -l app.kubernetes.io/name=checkout -o wide
 kubectl top pods -n "$NS" 2>/dev/null || true
 kubectl top node 2>/dev/null || true
} > "$EVIDENCE/pre-rollback.txt"

echo "Removing memory leak simulator..."
kubectl patch deployment "$DEPLOY" -n "$NS" --type='strategic' -p '
spec:
  template:
    metadata:
      annotations:
        northstar.io/incident: null
    spec:
      containers:
      - name: memory-leak-simulator
        $patch: delete
'
kubectl rollout status deployment/"$DEPLOY" -n "$NS" --timeout=3m
kubectl get deployment "$DEPLOY" -n "$NS"
kubectl get pods -n "$NS" -l app.kubernetes.io/name=checkout
