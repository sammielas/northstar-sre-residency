# INC-002 — Checkout Returns 503

## Severity
Critical

## Scenario
A deployment completed successfully. Five minutes later Alertmanager fires and customers receive HTTP 503 from Checkout.

## Pager
- CheckoutHighErrorRate
- Severity: Critical
- Service: checkout

## Allowed Tools
- Grafana
- Prometheus
- Loki

Do not use kubectl logs/exec/describe until after forming a hypothesis.
