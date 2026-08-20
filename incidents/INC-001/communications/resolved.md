# INC-001 — Resolved

**Severity:** P1 — Critical  
**Service:** Northstar Checkout  
**Status:** RESOLVED  
**Time:** 2026-08-19 10:38:53 UTC

The incident affecting Northstar Checkout has been resolved.

Customer Checkout transactions are completing successfully and service
health indicators have returned to normal operating levels.

The incident was associated with loss of Redis availability, which
prevented Checkout from completing transactions.

Redis availability was restored through emergency change CHG-001.

The SRE team has validated recovery through Kubernetes health checks,
customer transactions, Prometheus SLIs and the Grafana service-health
dashboard.

A blameless Root Cause Analysis will document the incident timeline,
contributing factors and corrective actions.
