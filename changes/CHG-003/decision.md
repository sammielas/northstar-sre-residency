# CHG-003 Deployment Decision

## Decision

STOP

## Time

2026-08-20T14:12:51Z

## Reason

Checkout reliability degraded during the 0.8.0 release.

Measured evidence:

- Current Checkout traffic: approximately 0.99 requests/second
- Availability: 0%
- Error rate: 100%
- Availability SLO: 99.9%
- Error-budget burn rate: approximately 1000x
- Synthetic customer Checkout requests returned HTTP 503

The release is considered unsafe.

No further normal rollout activity is authorised.

## Required Action

Rollback to the last known-good Checkout release, version 0.7.0.

## Recovery Validation

2026-08-20T14:22:34Z

Rollback to Checkout 0.7.0 restored service reliability.

Post-rollback measurements:

- Availability: 100%
- Error Rate: 0%
- SLO Target: 99.9%
- Burn Rate: 0.00x
- Reliability Gate: GO

The service is technically healthy.

The change freeze remains temporarily active pending review of the
failed 0.8.0 release and confirmation that normal change risk is
acceptable.
