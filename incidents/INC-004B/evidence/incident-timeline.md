# INC-004B — Incident Timeline

## Attempt 1 — Automatic Recovery

The first simulation demonstrated an unexpected automatic recovery path.

- Cache leak was enabled.
- Cache entries continuously increased.
- JVM heap approached its maximum.
- Garbage collection activity increased.
- P95 latency degraded to approximately 455 ms.
- Readiness probes began timing out.
- Liveness probes eventually failed.
- Kubernetes terminated and restarted the JVM.
- The restart cleared process-local heap/cache state.
- P95 latency recovered.
- Alertmanager sent RESOLVED before human mitigation.

### Lesson

The service recovered because Kubernetes restarted the JVM, not because the
underlying cache defect had been remediated.

The original liveness configuration interfered with the human incident-response
exercise, so it was relaxed before Attempt 2.

---

## Attempt 2 — Runbook-Driven Response

The second attempt exercised the intended operational workflow:

Prometheus detection
→ Slack notification
→ acknowledgement
→ runbook-driven triage
→ investigation
→ mitigation
→ recovery verification
→ Alertmanager RESOLVED

### Captured timestamps

| Event | Timestamp |
|---|---|
| Acknowledged | 2026-08-10T10:51:01+01:00 |
| Mitigation started | 2026-08-10T11:10:18+01:00 |
| Recovery verified | 2026-08-10T11:12:17+01:00 |

## Measured Durations

- Acknowledgement → mitigation: **19m 17s**
- Mitigation → verified recovery: **1m 59s**
- Acknowledgement → verified recovery: **21m 16s**

## Metrics We Cannot Honestly Calculate

We did not capture enough timestamps to calculate:

- TTD — exact customer-impact start/detection timestamps were not recorded.
- TTA — exact alert notification timestamp was not recorded programmatically.
- True TTR — exact customer-impact start timestamp was not recorded.

These values will not be reconstructed or invented retrospectively.

## Timing Improvements for Future Incidents

Future incidents should capture:

- `FAULT_AT`
- `IMPACT_STARTED_AT`
- `DETECTED_AT`
- `ALERT_FIRED_AT`
- `NOTIFIED_AT`
- `ACKNOWLEDGED_AT`
- `TRIAGE_COMPLETED_AT`
- `MITIGATION_STARTED_AT`
- `RECOVERED_AT`
- `ALERT_RESOLVED_AT`

This will allow TTD, TTA and TTR to be calculated from evidence rather than
memory.
