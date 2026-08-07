#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="northstar-dev"
DEPLOYMENT="checkout"
HOST="checkout.localhost"
TRAEFIK_PORT="18080"

echo "=========================================="
echo " Northstar INC-001: Latency SLO Breach"
echo "=========================================="

ORIGINAL_REPLICAS="$(
  kubectl get deployment "$DEPLOYMENT" \
    -n "$NAMESPACE" \
    -o jsonpath='{.spec.replicas}'
)"

echo
echo "Original replicas: $ORIGINAL_REPLICAS"

cleanup() {
  echo
  echo "=========================================="
  echo " Recovering Checkout"
  echo "=========================================="

  echo "Rolling back throttled deployment..."

  kubectl rollout undo \
    deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" || true

  kubectl rollout status \
    deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --timeout=5m || true

  echo "Restoring replica count to $ORIGINAL_REPLICAS..."

  kubectl scale \
    deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --replicas="$ORIGINAL_REPLICAS" || true

  kubectl rollout status \
    deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --timeout=5m || true

  echo
  echo "Recovery completed."
}

trap cleanup EXIT INT TERM

echo
echo "Step 1: Reducing Checkout to one replica..."

kubectl scale \
  deployment/"$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --replicas=1

kubectl rollout status \
  deployment/"$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --timeout=5m

echo
echo "Step 2: Applying CPU throttling..."

kubectl set resources deployment "$DEPLOYMENT" \
  -n "$NAMESPACE" \
  -c=checkout \
  --requests=cpu=50m \
  --limits=cpu=100m

kubectl rollout status \
  deployment/"$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --timeout=5m

echo
echo "Step 3: Confirming degraded Checkout configuration..."

kubectl get deployment "$DEPLOYMENT" \
  -n "$NAMESPACE" \
  -o jsonpath='replicas={.spec.replicas}{" cpu-request="}{.spec.template.spec.containers[0].resources.requests.cpu}{" cpu-limit="}{.spec.template.spec.containers[0].resources.limits.cpu}{"\n"}'

echo
echo "Step 4: Starting load..."
echo
echo "Press CTRL+C when the alert is FIRING."
echo
echo "The script will automatically roll Checkout back."
echo

while true; do
  seq 1 100 |
  xargs -P 50 -I{} \
    curl \
      --silent \
      --max-time 5 \
      --output /dev/null \
      --header "Host: $HOST" \
      "http://127.0.0.1:${TRAEFIK_PORT}/health" \
      || true
done