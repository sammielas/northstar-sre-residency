# INC-001 — Checkout Service Outage

## Incident Summary

Northstar Checkout experienced a P1 service outage during which customer
Checkout requests returned HTTP 503.

The Checkout application containers remained running, but both replicas
became unready because a required Redis dependency was unavailable.

Redis availability was restored through emergency change CHG-001.
Checkout subsequently recovered without requiring an application
redeployment.

---

## Severity

P1 — Critical

---

## Affected Service

Northstar Checkout

---

## Customer Impact

Customers were unable to complete Checkout transactions during the
incident.

Observed symptoms included:

- HTTP 503 responses from Checkout.
- Checkout availability degradation.
- Increased Checkout error rate.
- Checkout replicas becoming unready.

---

## Detection

The incident was validated using:

- Customer transaction testing.
- Grafana service-health monitoring.
- Prometheus customer-facing SLIs.
- Kubernetes workload health.
- Checkout readiness state.

---

## Root Cause

The Redis Deployment had no available replica.

Checkout requires Redis during the transaction path. With Redis
unavailable, Checkout could not complete the Redis operation required
by the application.

The resulting application exception caused Checkout requests to return
HTTP 503.

---

## Technical Failure Chain

Redis Deployment unavailable
-> Redis Pod unavailable
-> Redis Service has no backend endpoint
-> Checkout cannot connect to Redis
-> Checkout transaction fails
-> HTTP 503 returned
-> Availability decreases
-> Error rate increases
-> SLO error budget is consumed

---

## Mitigation

Emergency change CHG-001 restored the Redis Deployment to one replica.

Once Redis became available:

1. Redis regained a Service endpoint.
2. Checkout could communicate with Redis.
3. Checkout readiness probes succeeded.
4. Existing Checkout Pods became Ready.
5. Customer transactions succeeded.
6. Availability recovered.
7. Error rate recovered.
8. Current short-window SLO burn rate returned to zero.

Checkout itself did not require redeployment.

---

## What Went Well

- Customer-facing metrics exposed the service impact.
- Checkout readiness correctly identified dependency unavailability.
- Kubernetes kept the Checkout containers running while they were
  temporarily unable to serve traffic.
- Prometheus provided measurable availability and error-rate evidence.
- Grafana provided a consolidated operational view.
- Incident evidence was captured during the response.
- Recovery was validated from the customer's perspective.
- The emergency change was documented before implementation.

---

## What Could Be Improved

- Redis represented a single-instance dependency.
- Loss of Redis availability affected all Checkout replicas.
- Dependency resilience should be reviewed.
- Alerting should identify dependency loss before or alongside widespread
  customer transaction failure.
- Operational recovery should be documented in a reusable runbook.
- Change governance should prevent accidental reduction of critical
  dependencies without appropriate controls.

---

## Lessons Learned

Application replicas alone do not guarantee service availability.

Checkout had multiple replicas, but both depended on the same Redis
service.

Reliability therefore depends on the complete customer transaction path,
not merely the number of application Pods.

Readiness probes protected traffic routing but could not repair an
unavailable external dependency.

---

## Follow-Up

Corrective and preventive actions are tracked separately with owners,
priorities and completion criteria.

---

# 5 Whys

## Problem

Customers could not complete Checkout transactions.

### Why 1

Why could customers not Checkout?

Because Checkout returned HTTP 503.

### Why 2

Why did Checkout return HTTP 503?

Because the application could not complete its required Redis operation.

### Why 3

Why could Checkout not communicate with Redis?

Because the Redis Deployment had no running replica and the Redis
Service therefore had no backend endpoint.

### Why 4

Why did loss of one Redis workload remove Redis availability completely?

Because the lab environment used a single Redis replica without a
high-availability Redis architecture.

### Why 5

Why could this dependency failure directly affect the complete Checkout
customer journey?

Because Checkout has a synchronous runtime dependency on Redis and the
current architecture does not provide sufficient redundancy or graceful
degradation for loss of that dependency.

## Systemic Finding

The incident was not simply "Redis went down."

The larger reliability weakness is that a critical Checkout dependency
can become a single point of failure.

---

# Change Governance Finding

During a P1 incident, non-essential production changes should be frozen
to reduce operational risk and prevent additional variables from being
introduced.

Emergency restoration changes may proceed through an expedited
emergency-change process with:

- documented justification,
- implementation steps,
- risk assessment,
- validation,
- rollback planning,
- incident linkage.

Future Northstar work will also evaluate preventative deployment and
policy controls for critical workloads.
