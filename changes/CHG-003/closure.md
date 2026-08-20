# CHG-003 — Checkout 0.8.0 Change Closure

## Change

Deploy Checkout version 0.8.0.

## Objective

Validate a controlled application release using customer-facing
reliability signals and SLO-based change governance.

## Pre-Change State

The Checkout service was operating normally.

The reliability gate permitted the deployment.

Decision:

GO

## Failure Detection

Following deployment, the Checkout customer transaction path began
returning HTTP 503 responses.

The application health endpoint continued returning HTTP 200.

This demonstrated that application process health did not accurately
represent customer experience.

## Reliability Evidence

During the failure:

Traffic was present.

Availability fell to:

0%

Error rate increased to:

100%

The Checkout availability SLO was:

99.9%

Error-budget burn rate reached approximately:

1000x

The reliability gate returned:

FREEZE

## Change Decision

The release was declared unsafe.

Decision:

STOP

No further rollout progression was permitted.

## Mitigation

Checkout was restored to the last known-good release:

0.7.0

The failure-injection configuration was removed.

## Recovery Validation

Following rollback:

Availability returned to 100%.

Error rate returned to 0%.

Burn rate returned to 0x.

The reliability gate returned:

GO

## Change Freeze

Normal Checkout changes remained temporarily frozen while the failed
release was reviewed.

The freeze was lifted after:

- service recovery was confirmed;
- reliability telemetry returned to normal;
- the failed release was reviewed;
- the failure mechanism was understood;
- the failed candidate was prevented from immediate redeployment.

## Outcome

Service restored.

Customer impact ended.

Failed candidate withdrawn.

Normal change governance restored.

## Key Learning

Kubernetes health and readiness are necessary but are not sufficient
proof that a release is safe.

Deployment decisions should also incorporate customer-facing SLIs,
SLO compliance, error-budget consumption, and business impact.
