# INC-004B Postmortem
## Incident
INC-004B — JVM Cache Leak / Latency Degradation

## Severity
## Executive summary
## Detection
## Customer impact
## Timeline
## Root cause
## Why Kubernetes health checks did not detect it
## Why there was no OOMKilled initially
## GC behaviour
## Contributing factors
## What went well
## What went poorly
## Mitigation
## Recovery verification
## Error-budget impact
## Five Whys
## Preventive actions
- cache eviction tests
- JVM heap alerting
- GC alerting
- latency SLO alerting
- memory profiling
- load testing
- release annotations
- canary deployment
- automated rollback
## Interview STAR summary
