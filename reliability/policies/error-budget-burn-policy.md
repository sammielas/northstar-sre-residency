# NorthStar Error Budget Burn Policy

## Purpose

This policy converts error-budget consumption into an operational change state.

## Burn Rate States

### NORMAL

Burn rate: less than 1x

Meaning:

The service is consuming error budget slower than the sustainable rate.

Change policy:

- normal feature releases allowed
- standard infrastructure changes allowed
- normal PR and change approval process

---

### RESTRICTED

Burn rate: 1x to less than 2x

Meaning:

The service is consuming error budget faster than desired.

Change policy:

- increased review required
- canary deployment required
- rollback plan required
- SLO observation required during release

---

### COLD FREEZE

Burn rate: 2x to less than 6x

Meaning:

Reliability degradation is significant.

Change policy:

Allowed:

- reliability fixes
- capacity improvements
- critical security changes

Blocked:

- normal feature releases
- non-essential production changes

---

### HARD FREEZE

Burn rate: 6x or greater

Meaning:

The service is burning reliability budget at an unacceptable rate.

Change policy:

- normal production changes prohibited
- emergency remediation only
- incident/problem management takes priority
- leadership/change authority approval required for exceptions

## Principle

A remaining error budget does not automatically mean a release is safe.

The speed of budget consumption matters.
