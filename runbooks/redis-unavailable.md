# Runbook — Redis Unavailable

## Purpose

Respond to Redis unavailability affecting Northstar Checkout.

## Symptoms

Possible indicators:

- Checkout HTTP 503 responses.
- Checkout replicas become unready.
- Checkout error rate increases.
- Checkout availability decreases.
- Redis Service has no endpoints.

## 1. Check Redis Deployment

```bash
kubectl get deployment redis -n northstar-dev
kubectl get pods -n northstar-dev | grep redis
kubectl get service redis -n northstar-dev
kubectl get endpoints redis -n northstar-dev
kubectl logs \
  -n northstar-dev \
  -l app.kubernetes.io/name=checkout \
  --since=10m
