#!/usr/bin/env bash
set -euo pipefail
NS="${NS:-northstar-dev}"
DEPLOY="${DEPLOY:-checkout}"
EVIDENCE="incidents/INC-004/evidence"
mkdir -p "$EVIDENCE"

kubectl get deployment "$DEPLOY" -n "$NS" -o yaml > "$EVIDENCE/deployment-before.yaml"
{
 date
 kubectl get deployment "$DEPLOY" -n "$NS"
 kubectl get pods -n "$NS" -l app.kubernetes.io/name=checkout -o wide
 kubectl top pods -n "$NS" -l app.kubernetes.io/name=checkout 2>/dev/null || true
 kubectl top node 2>/dev/null || true
} > "$EVIDENCE/pre-injection.txt"

echo "Injecting INC-004 memory leak simulator..."
kubectl patch deployment "$DEPLOY" -n "$NS" --type='strategic' -p '
spec:
  template:
    metadata:
      annotations:
        northstar.io/incident: "INC-004"
    spec:
      containers:
      - name: memory-leak-simulator
        image: python:3.12-slim
        imagePullPolicy: IfNotPresent
        command:
        - python
        - -c
        - |
          import time
          chunks=[]
          print("INC-004 simulator started", flush=True)
          while True:
              chunks.append(bytearray(20 * 1024 * 1024))
              print(f"retained_chunks={len(chunks)} approx_mib={len(chunks)*20}", flush=True)
              time.sleep(5)
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            cpu: 100m
            memory: 160Mi
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 65534
          capabilities:
            drop: ["ALL"]
'
kubectl rollout status deployment/"$DEPLOY" -n "$NS" --timeout=3m || true
echo "Injected. Investigate before running rollback.sh."
