# NorthStar SRE Residency — INC-003

## Incident
**INC-003 — Bad Checkout Deployment**

## Purpose
Practice deployment correlation, SLO-based detection, rollback, and recovery validation.

The injected revision will pass `/health` and `/ready`, so Kubernetes considers the rollout healthy while customer-facing latency and errors degrade.

## Before you start
Verify the cluster and observability stack are healthy, then ensure Traefik is forwarded on `127.0.0.1:18080`.

## Workflow
1. Read `README.md`.
2. Do **not** read `facilitator/` yet.
3. Run `chmod +x inject.sh rollback.sh && ./inject.sh`.
4. Investigate with Alertmanager, Grafana, Prometheus and Loki.
5. Correlate the degradation with rollout history only after forming a hypothesis.
6. Save evidence in `evidence/`.
7. When rollback is justified, run `./rollback.sh`.
8. Verify SLO and alert recovery.
9. Complete `postmortem.md`.
10. Only then read `facilitator/root-cause.md`.

Core rule: **customer impact → telemetry → change correlation → hypothesis → rollback → verification**.
