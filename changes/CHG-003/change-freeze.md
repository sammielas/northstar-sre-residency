# Checkout Change Freeze

## Status

ACTIVE

## Trigger

CHG-003 caused severe customer-facing reliability degradation.

At the point of freeze:

- Checkout Availability: 0%
- Checkout Error Rate: 100%
- Availability SLO: 99.9%
- Error-Budget Burn Rate: approximately 1000x

## Scope

Northstar Checkout normal production changes.

## Restrictions

Temporarily prohibited:

- Feature releases
- Routine Checkout configuration changes
- Non-essential infrastructure changes affecting Checkout

Permitted:

- Rollback
- Incident mitigation
- Emergency reliability fixes
- Diagnostic activity approved as part of incident response

## Exit Criteria

The freeze may be lifted only when:

1. Checkout has returned to sustained healthy availability.
2. Error rate has returned to normal.
3. Burn rate has normalised.
4. The failed 0.8.0 release has been reviewed.
5. The defect has been understood.
6. Required corrective actions have been identified.
7. SRE and the service owner agree normal change risk is acceptable.

## Effective

2026-08-20T14:19:16Z

## Freeze Lifted

2026-08-20T14:24:01Z

## Reason

The service has demonstrated sustained recovery following rollback.

Validation confirmed:

- Availability returned to 100%.
- Error rate returned to 0%.
- Current burn rate returned to 0.00x.
- The failed 0.8.0 release was reviewed.
- The release defect is understood.
- The failed candidate will not be redeployed without correction and
  renewed validation.

Normal Checkout changes may resume subject to the standard pre-change
reliability gate.
