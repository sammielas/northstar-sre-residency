# INC-004B Postmortem

## Incident

INC-004B — JVM Cache Leak / Memory Pressure / Latency Degradation

## Severity

SEV-2 — Customer-facing performance degradation with risk of service
availability impact.

## Executive Summary

A JVM-based NorthStar service experienced progressive memory pressure after
cache eviction was disabled during the incident simulation.

Cache entries accumulated in JVM heap and could not be reclaimed by garbage
collection because they remained referenced by the application.

Heap utilisation eventually approached 100%. Garbage collection activity
increased and the Profile API P95 latency degraded from approximately 17 ms
to approximately 455 ms.

For much of the incident Kubernetes continued to report the application as
Running and Ready with no OOMKill.

As JVM pressure increased, readiness probes intermittently timed out.

During the first simulation attempt, liveness probes also failed repeatedly
and Kubernetes automatically restarted the JVM. The restart cleared
process-local memory and caused the monitoring alert to resolve before human
mitigation.

The liveness configuration was relaxed and the scenario was repeated.

During Attempt 2, Prometheus detected elevated latency, Alertmanager routed
the alert to Slack, the engineer acknowledged it, opened the JVM memory
pressure runbook, performed triage, and manually mitigated the incident.

Recovery was verified through JVM, application and monitoring telemetry.

---

## Detection

Prometheus detected the customer-facing latency degradation through:

`JVMProfileHighP95Latency`

A second resource-oriented alert was also available:

`JVMHeapUsageHigh`

Alertmanager routed notifications to the NorthStar Slack channel.

The alert payload included:

- service
- severity
- namespace
- summary
- description
- runbook URL
- Grafana dashboard URL

This changed the response path from ad-hoc investigation to:

Alert → acknowledgement → runbook → triage → mitigation → recovery.

---

## Customer Impact

The Profile API experienced significant latency degradation.

Healthy baseline:

- P95 approximately 17–22 ms

Incident:

- P95 approximately 455 ms

The application remained available for much of the incident, meaning simple
process and Kubernetes health checks did not fully represent customer
experience.

Intermittent readiness failures later appeared as JVM pressure increased.

---

## Technical Symptoms

Observed incident signals included:

- JVM heap approaching ~247 MiB
- JVM heap utilisation approaching 100%
- cache entries increasing to approximately 244
- increased garbage collection count
- increased total GC time
- P95 latency increasing to approximately 455 ms
- intermittent readiness timeouts
- liveness failures during Attempt 1
- no initial OOMKilled event

---

## Root Cause

The immediate root cause was unbounded application cache retention.

The cache continued retaining objects rather than evicting them.

Because those objects remained referenced, the JVM garbage collector could
not reclaim them.

The resulting sequence was:

cache growth
→ retained objects
→ JVM heap growth
→ increased GC pressure
→ increased application latency
→ readiness degradation

---

## Why Kubernetes Initially Considered the Application Healthy

The application process remained alive and its health endpoints continued
responding successfully for much of the incident.

Kubernetes therefore reported:

- Running
- Ready
- initially zero restarts

However, Kubernetes process health does not guarantee acceptable customer
latency.

This incident demonstrated the difference between:

application availability

and

application reliability/performance.

---

## Why There Was No OOMKilled Initially

The JVM had not yet exceeded the container's enforced memory limit.

The service was already experiencing severe heap and GC pressure before the
kernel needed to terminate the process.

This demonstrates why SREs should detect JVM memory pressure before it
progresses into an OOM event.

---

## Garbage Collection Behaviour

Garbage collection increased as JVM heap pressure increased.

GC was not the root cause.

It was reacting to memory pressure.

Because the cache still referenced the retained objects, GC could not reclaim
enough memory to return the heap to a healthy baseline.

---

## Attempt 1 — Unexpected Automatic Recovery

During the first simulation attempt, the liveness probe was configured with a
short timeout.

As JVM pressure worsened:

- `/health` responded too slowly
- liveness probes failed
- Kubernetes terminated the JVM
- exit code 143 was recorded
- Kubernetes restarted the container

The new JVM began with empty process-local cache and heap state.

Latency therefore recovered and Alertmanager emitted a RESOLVED notification
before manual mitigation occurred.

### Lesson

A Kubernetes restart can temporarily recover a memory-related incident while
leaving the underlying application defect unresolved.

Readiness and liveness have very different operational consequences:

Readiness failure:
stop routing traffic.

Liveness failure:
terminate and restart the container.

The liveness configuration was relaxed before Attempt 2.

---

## Attempt 2 — Human Incident Response

The second attempt followed the intended operational workflow:

Prometheus detection
→ Slack notification
→ engineer acknowledgement
→ JVM memory pressure runbook
→ triage
→ investigation
→ mitigation decision
→ rollback
→ recovery verification
→ Alertmanager RESOLVED

---

## Triage

Triage established that:

- customer-facing latency was degraded
- Kubernetes workload remained largely operational
- JVM memory usage was abnormal
- cache entries were increasing
- GC activity was increasing
- node failure was not the primary symptom
- the incident was application/JVM scoped

The triage process prevented an immediate assumption that the Kubernetes node
or container runtime was the root cause.

---

## Correlation

The following signals moved together:

cache entries ↑
JVM heap ↑
GC activity ↑
P95 latency ↑

This correlation formed the working hypothesis that retained cache objects
were driving JVM memory pressure and customer latency.

---

## Mitigation

The faulty cache behaviour was disabled and the application was restarted
through the incident rollback procedure.

The restart cleared JVM process-local state.

Unlike Attempt 1, this restart was intentional mitigation performed after
triage.

---

## Recovery Verification

Recovery was not declared solely because the Kubernetes rollout completed.

Post-mitigation evidence showed:

- JVM heap: ~13.69 MiB
- JVM maximum heap: ~247.50 MiB
- GC count: 0
- GC time: 0 seconds
- P95 latency: ~17 ms
- cache entries: 0
- leak active: NO

Prometheus subsequently considered the alert condition healthy and
Alertmanager delivered a RESOLVED Slack notification.

---

## Incident Response Measurements

Available timestamps:

- ACKNOWLEDGED_AT: 2026-08-10T10:51:01+01:00
- MITIGATION_STARTED_AT: 2026-08-10T11:10:18+01:00
- RECOVERED_AT: 2026-08-10T11:12:17+01:00

Measured:

- acknowledgement → mitigation: 19m17s
- mitigation → recovery: 1m59s
- acknowledgement → recovery: 21m16s

TTD, TTA and true TTR cannot be reliably calculated because the necessary
start/detection timestamps were not captured programmatically.

No retrospective values were invented.

---

## MTTD Improvement Opportunity

Future incidents should capture the fault/customer-impact timestamp
automatically.

Prometheus alert timestamps and Slack delivery timestamps should also be
recorded.

Improvements include:

- customer SLI alerts
- JVM heap alerts
- GC alerts
- application-specific metrics
- actionable Slack payloads
- runbook links embedded directly in alerts

---

## MTTR Improvement Opportunity

A reusable runbook now exists at:

`runbooks/applications/jvm-memory-pressure.md`

The runbook standardises:

- triage
- blast-radius assessment
- container/node distinction
- JVM heap analysis
- GC analysis
- application-specific memory analysis
- Kubernetes event investigation
- recent-change correlation
- mitigation criteria
- recovery verification

Future JVM incidents should require less ad-hoc discovery.

Actual MTTR improvement must be measured across future comparable incidents
before claiming a percentage reduction.

---

## What Went Well

- JVM metrics exposed the failure before OOM.
- Customer latency provided a meaningful SLI.
- Prometheus alerts fired.
- Alertmanager successfully routed alerts to Slack.
- Slack alerts contained a runbook and dashboard link.
- The on-call workflow included explicit acknowledgement.
- The reusable JVM runbook guided triage.
- Recovery was verified through telemetry rather than rollout status alone.
- Kubernetes events preserved evidence of historical readiness/liveness
  failures.

---

## What Went Poorly

- Initial incident timing instrumentation was incomplete.
- Attempt 1's liveness probe automatically restarted the JVM before manual
  response completed.
- TTD and TTA could not be calculated reliably.
- Some early troubleshooting was performed ad-hoc before the reusable runbook
  existed.
- The initial Grafana panels required unit/query corrections.
- Runbook links were initially incomplete.
- Slack Alertmanager namespace routing required correction.

---

## Corrective Actions

| Action | Priority |
|---|---|
| Capture incident lifecycle timestamps automatically | High |
| Keep runbook URL in actionable alerts | High |
| Keep Grafana dashboard URL in actionable alerts | High |
| Record acknowledgement timestamp | High |
| Add JVM heap alerting | High |
| Add customer latency SLO alerts | High |
| Review readiness/liveness probe semantics | High |
| Add GC pressure monitoring | Medium |
| Add cache-growth monitoring | Medium |
| Add deployment/change annotations | Medium |
| Add memory behaviour to release testing | Medium |
| Evaluate safe automated rollback later | Medium |

---

## Runbook Improvement

The following lessons should be retained in the JVM memory pressure runbook:

1. Check customer SLI before assuming infrastructure failure.
2. Check historical Kubernetes events, not only current pod status.
3. Distinguish readiness failures from liveness failures.
4. Treat unexpected automatic restarts as mitigation evidence.
5. Do not assume restart equals root-cause remediation.
6. Capture response timestamps during the incident, not afterward.
7. Verify recovery using the same SLIs that detected the incident.

---

## Five Whys

### 1. Why did customer latency increase?

The JVM experienced increasing memory and GC pressure.

### 2. Why did JVM memory pressure increase?

Application objects accumulated in heap.

### 3. Why were those objects not reclaimed?

The application cache retained references to them.

### 4. Why did GC not fix the problem?

GC cannot reclaim objects that remain reachable from application references.

### 5. Why did the incident require operational improvements?

Existing Kubernetes health checks did not fully represent customer
performance, and the original incident workflow lacked complete timing and a
standardised runbook-driven response.

---

## Interview STAR Summary

### Situation

A JVM-based service experienced rapidly increasing heap utilisation and
customer latency while Kubernetes continued to report the workload as largely
healthy.

### Task

Determine whether the issue was node pressure, container exhaustion, JVM
behaviour, or application-level memory retention, and restore customer
performance.

### Action

I used Prometheus, Grafana, Kubernetes events and JVM metrics to correlate
cache growth with heap utilisation, GC activity and increasing P95 latency.

The alert was routed through Alertmanager to Slack with direct links to the
dashboard and JVM memory-pressure runbook.

After acknowledgement, I followed a structured triage process, identified the
application/JVM scope, and mitigated by disabling the faulty cache behaviour
and restarting the workload.

I then verified recovery using JVM heap, GC, cache and customer latency
metrics rather than relying only on Kubernetes rollout status.

### Result

Heap usage returned from approximately 100% to normal levels, cache entries
returned to zero, P95 latency recovered from approximately 455 ms to
approximately 17 ms, and Alertmanager independently reported the alert as
resolved.

The incident also produced a reusable JVM runbook and identified improvements
for future TTD/TTR measurement.

