#!/usr/bin/env bash
set -euo pipefail
NS=northstar-dev
APP=checkout
ORIGINAL_VALUE="$(kubectl get deployment $APP -n $NS -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DATABASE_URL")].value}')"
cleanup(){ kubectl set env deployment/$APP -n $NS DATABASE_URL="$ORIGINAL_VALUE"; kubectl rollout status deployment/$APP -n $NS; }
trap cleanup EXIT
kubectl set env deployment/$APP -n $NS DATABASE_URL='postgresql://broken:broken@postgres:5432/checkout'
kubectl rollout status deployment/$APP -n $NS
while true; do curl -H 'Host: checkout.localhost' http://127.0.0.1:18080/checkout >/dev/null 2>&1 || true; sleep 0.2; done
