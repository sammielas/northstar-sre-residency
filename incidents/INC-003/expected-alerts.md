# Expected Alerts

## Primary
- CheckoutHighP95Latency

## Possible
- CheckoutHighErrorRate

## Not expected as primary cause
- CheckoutDependencyDown
- node pressure
- memory pressure

A successful rollout plus an SLO breach should trigger change correlation, but deployment correlation is still a hypothesis until supported by evidence.
