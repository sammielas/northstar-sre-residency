# CHG-002 — Checkout 0.7.0 Deployment

## Change Type

Normal Application Release

## Service

Northstar Checkout

## Requested

2026-08-19T22:06:58Z

## Proposed Change

Deploy Checkout version 0.7.0 using the Kubernetes RollingUpdate strategy.

## Reliability Objective

Checkout Availability SLO: 99.9%

## Pre-Change Decision

PENDING

## Validation Requirements

- Checkout has no active P1/P2 incident.
- Checkout replicas are Ready.
- Redis is healthy.
- PostgreSQL is healthy.
- Current Availability is healthy.
- Current Error Rate is low.
- Current Burn Rate is acceptable.
- CPU and Memory saturation are healthy.
- Deployment strategy preserves healthy capacity.
- Readiness probes protect traffic during rollout.

## Rollback

Rollback to the previous known-good Checkout ReplicaSet/image if the
candidate release fails validation or causes unacceptable customer impact.
