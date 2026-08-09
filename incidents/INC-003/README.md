# INC-003 — Bad Checkout Deployment

## Severity
SEV-2 / Customer-impacting degradation

## Pager
`CheckoutHighP95Latency`

## Customer reports
- Checkout completes, but much more slowly than usual.
- Some requests fail intermittently.
- Browsing and login appear normal.

## Known fact
A Checkout deployment completed shortly before the alert.

## Objective
Determine whether the release caused the degradation and restore service using the safest justified mitigation.

## Success criteria
Explain the customer impact, violated SLI/SLO, relevant change, why the new revision is implicated, why rollback is justified, and how recovery was verified.
