#!/usr/bin/env bash
set -Eeuo pipefail

NS="${NS:-northstar-dev}"
DEPLOYMENT="${DEPLOYMENT:-checkout}"
HOST_REGISTRY="${HOST_REGISTRY:-localhost:5100}"
CLUSTER_REGISTRY="${CLUSTER_REGISTRY:-floci-ecr-registry:5000}"
REPO_PATH="${REPO_PATH:-000000000000/us-east-1/northstar/checkout}"
BAD_TAG=${BAD_TAG:-0.4.1-bad}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$SCRIPT_DIR/evidence"
BAD_DIR="$SCRIPT_DIR/facilitator/bad-revision"
mkdir -p "$STATE_DIR"

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/northstar-floci-k3s.yaml}"

HOST_IMAGE="${HOST_REGISTRY}/${REPO_PATH}:${BAD_TAG}"
CLUSTER_IMAGE="${CLUSTER_REGISTRY}/${REPO_PATH}:${BAD_TAG}"

CURRENT_IMAGE="$(kubectl get deployment "$DEPLOYMENT" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].image}')"
printf '%s\n' "$CURRENT_IMAGE" > "$STATE_DIR/original-image.txt"
date --iso-8601=seconds > "$STATE_DIR/injection-started.txt"

echo "Building bad revision..."
docker build -t "$HOST_IMAGE" "$BAD_DIR"

echo "Pushing bad revision..."
docker push "$HOST_IMAGE"

echo "Deploying $CLUSTER_IMAGE ..."
kubectl set image deployment/"$DEPLOYMENT" checkout="$CLUSTER_IMAGE" -n "$NS"
kubectl rollout status deployment/"$DEPLOYMENT" -n "$NS" --timeout=3m

echo "Starting background traffic..."
nohup bash -c '
while true; do
  for i in $(seq 1 20); do
    curl --silent --max-time 5 --output /dev/null \
      --header "Host: checkout.localhost" \
      http://127.0.0.1:18080/checkout || true
  done
  sleep 0.1
done
' >"$STATE_DIR/traffic.log" 2>&1 &
echo "$!" > "$STATE_DIR/traffic.pid"

echo "INC-003 injected. Investigate before reading facilitator/root-cause.md."
