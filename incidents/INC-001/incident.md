# INC-001 — Checkout Service Unavailable

## Status

RESOLVED

## Severity

P1 — Critical

## Service

Northstar Checkout

## Detected

2026-08-19T08:41:08Z

## Customer Impact

Customers are unable to complete checkout transactions.
Validation requests returned HTTP 503 Service Unavailable.

## Current Technical Symptoms

- Checkout containers remain running.
- Checkout replicas are not Ready.
- Checkout transactions return HTTP 503.
- Redis is currently unavailable.
- Customer-facing Checkout availability is severely degraded.

## Initial Scope

The core Checkout transaction path is affected across the available
Checkout replicas.

## Severity Justification

P1 was assigned because a core revenue-generating customer journey is
unavailable and no functioning Checkout path or workaround has been
demonstrated.

## Root Cause

Under investigation.

## Incident State

Detection -> Validation -> Triage -> DECLARED

## Resolution

Redis availability was restored through emergency change CHG-001.

Following restoration:

- Redis returned to Ready state.
- Redis Service regained a backend endpoint.
- Checkout replicas automatically returned to Ready state.
- Customer Checkout transactions completed successfully.
- Checkout availability recovered.
- Checkout error rate recovered.
- Current short-window SLO burn rate returned to zero.

## Resolved

2026-08-19T10:38:09Z
