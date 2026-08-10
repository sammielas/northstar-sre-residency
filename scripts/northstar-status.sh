#!/usr/bin/env bash
set -euo pipefail

export KUBECONFIG="${KUBECONFIG_PATH:-$HOME/.kube/northstar-floci-k3s.yaml}"

echo "=== Docker ==="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' |
grep -E 'NAMES|floci|northstar'

echo
echo "=== Kubernetes Nodes ==="
kubectl get nodes -o wide

echo
echo "=== Unhealthy Pods ==="
kubectl get pods -A |
grep -vE 'Running|Completed' || true

echo
echo "=== Monitoring ==="
kubectl get pods -n monitoring

echo
echo "=== Logging ==="
kubectl get pods -n logging

echo
echo "=== NorthStar ==="
kubectl get pods -n northstar-dev

echo
echo "=== Node Usage ==="
kubectl top node
