#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_IMAGE="localhost:5100/000000000000/us-east-1/northstar/jvm-cache-demo:0.1.0"
DOCKER_CONFIG_DIR="/tmp/northstar-docker-config"
mkdir -p "$ROOT/evidence" "$DOCKER_CONFIG_DIR"
printf '{"auths":{}}\n' > "$DOCKER_CONFIG_DIR/config.json"

docker build -t "$HOST_IMAGE" "$ROOT/application"
DOCKER_CONFIG="$DOCKER_CONFIG_DIR" docker push "$HOST_IMAGE"
kubectl apply -f "$ROOT/application/deployment.yaml"
kubectl rollout status deployment/jvm-cache-demo -n northstar-dev --timeout=3m
kubectl apply -f "$ROOT/prometheus/servicemonitor.yaml"
kubectl apply -f "$ROOT/prometheus/rules.yaml"

kubectl port-forward -n northstar-dev service/jvm-cache-demo 18081:8080 >"$ROOT/evidence/port-forward.log" 2>&1 &
echo $! > "$ROOT/evidence/port-forward.pid"
sleep 2

curl -fsS "http://127.0.0.1:18081/admin/leak?enabled=true"
echo

nohup bash -c '
while true; do
  curl -fsS http://127.0.0.1:18081/profile >/dev/null || true
  sleep 0.4
done
' >"$ROOT/evidence/traffic.log" 2>&1 &
echo $! > "$ROOT/evidence/traffic.pid"
date -Is > "$ROOT/evidence/injection-started.txt"

echo "INC-004B injected. Watch heap, GC, cache entries and P95."
