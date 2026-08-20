# NorthStar Reliability Change Policy

## Purpose

Production change velocity must be governed by current service reliability.

A service consuming its error budget too quickly must prioritise reliability
work over feature delivery.

## Policy States

### NORMAL

Reliability is healthy.

Permitted:

- standard changes
- feature releases
- infrastructure changes
- canary releases

Requirements:

- normal PR approval
- normal CI/CD gates
- standard change record

---

### RESTRICTED

Reliability is degrading or error-budget consumption is elevated.

Permitted:

- essential changes
- reliability improvements
- capacity changes
- carefully controlled releases

Requirements:

- increased review
- canary deployment
- explicit rollback plan
- SLO observation during deployment

---

### COLD FREEZE

Reliability risk is high.

Permitted:

- critical security changes
- incident remediation
- urgent reliability changes

Blocked:

- normal feature releases
- non-essential infrastructure changes

---

### HARD FREEZE

Reliability risk is unacceptable.

Normal production changes are prohibited.

Only explicitly approved emergency remediation may proceed.

## Principle

Error budgets are not merely dashboard metrics.

They influence production change decisions.
