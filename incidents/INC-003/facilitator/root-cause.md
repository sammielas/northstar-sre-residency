# Facilitator Solution — INC-003

The injector deploys `0.4.0-bad`, an intentionally degraded Checkout revision.

It passes `/health` and `/ready`, exposes the NorthStar Prometheus metric names, delays `/checkout` by about 700 ms, and intermittently returns HTTP 500.

Expected evidence:
- rollout completes successfully,
- dependency health stays healthy,
- P95 exceeds 250 ms,
- error ratio may rise,
- alerts become Pending/Firing,
- rollout history shows a new revision immediately before degradation.

Correct mitigation: restore the previous known-good image / rollback the Deployment.

Key lesson: **readiness is not the same as release quality**.
