# CHG-003 — Failed Release Review

## Failed Candidate

Checkout 0.8.0

## Observed Failure

The application remained technically healthy enough to respond to the
health endpoint while the customer Checkout transaction path returned
HTTP 503.

## Reliability Impact

During the failure:

- Checkout traffic was present.
- Availability fell to 0%.
- Error rate reached 100%.
- Error-budget burn rate reached approximately 1000x.
- The reliability gate returned FREEZE.

## Response

1. CHG-003 was stopped.
2. Checkout was rolled back to the known-good 0.7.0 image.
3. The injected failure configuration was removed.
4. Customer-facing reliability recovered.
5. The reliability gate returned GO.

## Key Lesson

Kubernetes health alone is not sufficient evidence that an application
release is safe.

Customer-facing SLIs must be monitored during and after deployment.

## Recommendation

Do not permit the 0.8.0 candidate to be redeployed until the defect is
corrected and validation demonstrates healthy customer transactions.
