#!/usr/bin/env bash
set -e
kubectl rollout undo deployment/checkout -n northstar-dev
kubectl rollout status deployment/checkout -n northstar-dev
