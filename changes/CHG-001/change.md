# CHG-001 — Restore Redis Availability

## Change Type

Emergency Change

## Related Incident

INC-001 — P1 Checkout Service Unavailable

## Requested

2026-08-19T09:42:16Z

## Reason

Investigation of INC-001 found that the Redis Deployment has no
available replica.

Checkout depends on Redis to complete customer transactions.

Customer Checkout requests are currently returning HTTP 503.

## Proposed Change

Restore the Redis Deployment to one replica.

## Implementation Command

kubectl scale deployment/redis -n northstar-dev --replicas=1

## Expected Result

- Redis pod becomes Running and Ready.
- Redis Service receives a backend endpoint.
- Checkout reconnects to Redis.
- Checkout readiness returns to healthy.
- Customer Checkout transactions succeed.
- Availability begins recovering.
- Error rate begins decreasing.

## Risk

Low to moderate.

The change restores the Redis Deployment to its previously known
operational replica count.

## Validation

1. Verify Redis Deployment.
2. Verify Redis Pod.
3. Verify Redis Service endpoint.
4. Verify Checkout readiness.
5. Execute a customer Checkout transaction.
6. Check Prometheus SLIs.
7. Check Grafana service-health dashboard.

## Rollback

If restoring Redis introduces unexpected behaviour, investigate the
Redis pod and application state before making additional production
changes.

## Status

APPROVED FOR EMERGENCY IMPLEMENTATION

## Implementation Result

SUCCESSFUL

Redis availability was restored and Checkout subsequently returned
to Ready state.

A post-change customer transaction completed successfully.

## Completed

2026-08-19T09:50:05Z
