
# Runbook — JVM Memory Pressure

## Purpose

Use this runbook when a JVM-based application shows signs of memory pressure,
such as:

- high JVM heap usage
- increasing garbage collection
- increasing latency
- intermittent readiness failures
- possible memory exhaustion

The goal is to help the on-call SRE quickly:

1. Understand how serious the incident is.
2. Determine what is affected.
3. Investigate the JVM.
4. Identify likely causes.
5. Restore service.
6. Verify recovery.
7. Capture evidence for the postmortem.

---

# When To Use This Runbook

Use this runbook when one or more of these conditions occur:

- `JVMHeapUsageHigh` alert fires
- JVM heap remains above 75%
- garbage collection activity increases significantly
- P95/P99 latency increases
- readiness probes begin failing
- container memory approaches its limit
- users report that the application is slow

---

# First 5 Minutes

Do NOT immediately start deep root-cause analysis.

First answer these questions:

1. Are customers affected?
2. How much of the service is affected?
3. How severe is the incident?
4. Was there a recent deployment or configuration change?
5. Do we need immediate mitigation?

This is the **triage** phase.

---

# 1. Triage

## 1.1 Check the application

```bash
kubectl get pods \
  -n northstar-dev \
  -l app.kubernetes.io/name=<APPLICATION>
```

Check:

- Is the pod `Running`?
- Is it `Ready`?
- Has it restarted?
- Are all replicas affected?

Important:

`Running` does NOT automatically mean the application is healthy.

A JVM application can be:

```text
Running
Ready
0 Restarts
```

while customers are still experiencing high latency.

---

## 1.2 Check customer impact

Look at Grafana/Prometheus.

Check:

- P95 latency
- P99 latency
- error rate
- availability
- active alerts
- SLO status

Ask:

> Are customers experiencing degradation or a complete outage?

---

## 1.3 Establish the blast radius

Determine whether the problem affects:

- one pod
- multiple replicas
- the entire application
- multiple applications
- the Kubernetes node

Run:

```bash
kubectl get pods -n northstar-dev -o wide
```

The larger the blast radius, the more serious the incident may be.

---

## 1.4 Record the time

Record:

```bash
date -Is
```

Capture:

- when the problem started, if known
- when monitoring detected it
- when the alert fired
- when the engineer acknowledged it

These timestamps will later help calculate:

- TTD — Time To Detect
- TTA — Time To Acknowledge
- TTR — Time To Restore

---

# 2. Check Container Memory

Run:

```bash
kubectl top pods \
  -n northstar-dev \
  -l app.kubernetes.io/name=<APPLICATION> \
  --containers
```

Look at:

- CPU
- memory

Ask:

> Is the container consuming significantly more memory than normal?

Remember:

Container memory and JVM heap are related but are NOT the same thing.

The container includes:

```text
Container Memory
│
├── JVM Heap
├── Metaspace
├── Thread stacks
├── JVM native memory
├── Direct buffers
└── Other process memory
```

Therefore:

```text
JVM Heap < Total Container Memory
```

is completely normal.

---

# 3. Check Node Memory

Run:

```bash
kubectl top node
```

Then:

```bash
kubectl get node \
  -o custom-columns='NAME:.metadata.name,MEMORY_PRESSURE:.status.conditions[?(@.type=="MemoryPressure")].status'
```

Interpretation:

```text
MemoryPressure=False
```

means:

> The Kubernetes node itself is not currently experiencing memory pressure.

Continue investigating the application/container/JVM.

If:

```text
MemoryPressure=True
```

the problem may be affecting the node itself.

Check other workloads and consider escalation.

---

# 4. Investigate JVM Heap

Check:

```promql
jvm_memory_used_bytes{area="heap"}
```

Then check maximum heap:

```promql
jvm_memory_max_bytes{area="heap"}
```

Calculate heap percentage:

```promql
100 *
jvm_memory_used_bytes{area="heap"}
/
jvm_memory_max_bytes{area="heap"}
```

Ask:

- Is heap continuously increasing?
- Is heap approaching maximum capacity?
- Does heap decrease significantly after garbage collection?
- Does it immediately begin increasing again?

A pattern like:

```text
Heap
20%
 ↓
40%
 ↓
60%
 ↓
80%
 ↓
95%
```

without returning to normal can indicate that the JVM is retaining objects.

---

# 5. Investigate Garbage Collection

Check:

```promql
jvm_gc_collection_seconds_count
```

Then:

```promql
jvm_gc_collection_seconds_sum
```

Look for:

- increasing GC count
- increasing time spent performing GC
- heap remaining high even after GC

Remember:

GC is usually not the root cause.

GC may simply be reacting to another problem.

For example:

```text
Cache keeps growing
        ↓
Heap fills
        ↓
JVM needs memory
        ↓
GC runs more often
        ↓
GC cannot reclaim enough memory
        ↓
Application spends more time doing GC
        ↓
Latency increases
```

So don't stop at:

> "GC is high."

Ask:

> "Why is GC having to work so hard?"

---

# 6. Check Application-Specific Memory

Look at application-specific metrics.

For our NorthStar JVM application:

```promql
northstar_cache_entries
```

Look for continuously growing:

- caches
- queues
- sessions
- buffers
- connection pools
- retained objects

For example:

```text
Cache Entries ↑
       ↓
JVM Heap ↑
       ↓
GC Activity ↑
       ↓
P95 Latency ↑
```

This is useful correlation.

But remember:

**Correlation is evidence, not automatically proof of root cause.**

Continue investigating.

---

# 7. Check Application Latency

Check:

```promql
northstar_profile_p95_seconds
```

Ask:

- Did latency increase at the same time as heap?
- Did latency increase when GC became more active?
- Is customer-facing performance degrading?

This helps connect infrastructure/JVM symptoms to customer impact.

---

# 8. Check Kubernetes Readiness and Events

Get the pod:

```bash
POD=$(kubectl get pods \
  -n northstar-dev \
  -l app.kubernetes.io/name=<APPLICATION> \
  -o jsonpath='{.items[0].metadata.name}')
```

Check current readiness:

```bash
kubectl get pod "$POD" \
  -n northstar-dev \
  -o jsonpath='Ready={.status.conditions[?(@.type=="Ready")].status}{"\n"}'
```

Then check historical events:

```bash
kubectl get events \
  -n northstar-dev \
  --field-selector involvedObject.name="$POD" \
  --sort-by='.lastTimestamp'
```

Look for:

```text
Readiness probe failed
Liveness probe failed
OOMKilled
BackOff
Restarted
context deadline exceeded
```

Important distinction:

```text
kubectl get pod
```

shows you what is happening **now**.

Kubernetes events can show you what happened **earlier**.

Therefore a pod may currently say:

```text
Ready=True
```

while events show:

```text
Readiness probe failed
context deadline exceeded
```

That means the application experienced temporary degradation and later recovered.

---

# 9. Check Recent Changes

This is extremely important during an incident.

Ask:

> What changed shortly before the problem started?

Check deployment history:

```bash
kubectl rollout history \
  deployment/<APPLICATION> \
  -n northstar-dev
```

Check the current image:

```bash
kubectl get deployment <APPLICATION> \
  -n northstar-dev \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Also investigate:

- Git commits
- application deployments
- configuration changes
- feature flags
- dependency upgrades
- shared library upgrades
- JVM configuration changes
- resource limit changes

Look for correlation between:

```text
Change deployed
       ↓
Metrics begin degrading
       ↓
Alert fires
```

But remember:

A recent deployment is a strong clue.

It is not automatically proof.

---

# 10. Form a Hypothesis

At this stage, summarize what the evidence suggests.

Example:

```text
Observation 1:
JVM heap is continuously increasing.

Observation 2:
GC activity is increasing.

Observation 3:
Cache entries are continuously increasing.

Observation 4:
P95 latency is increasing.

Observation 5:
The behaviour started after a recent release.

Hypothesis:
The recent release may have changed cache behaviour,
causing objects to remain in memory.
```

Now investigate whether the evidence supports or disproves that hypothesis.

---

# 11. Mitigation Decision

Remember:

During an incident, restoring customer service normally comes before performing
a lengthy RCA.

Possible mitigations include:

- rollback the recent release
- disable a problematic feature flag
- restart the workload
- temporarily scale replicas
- temporarily increase resources
- isolate unhealthy replicas

---

## Consider rollback when

- customer-facing SLOs are breached
- degradation strongly correlates with a recent release
- heap continues increasing
- GC cannot reclaim enough memory
- readiness begins failing
- latency continues increasing
- a known-good version exists

---

## Important

Restarting a pod may temporarily clear JVM memory.

But:

```text
Restart
   ↓
Heap clears
   ↓
Application starts again
   ↓
Broken behaviour remains
   ↓
Heap grows again
```

Therefore:

> A restart is not a permanent fix when the underlying problem remains.

---

# 12. Verify Recovery

Never declare an incident resolved simply because:

```text
deployment successfully rolled out
```

Verify the actual service.

---

## Kubernetes

```bash
kubectl get pods \
  -n northstar-dev \
  -l app.kubernetes.io/name=<APPLICATION>
```

Confirm:

- pods are Running
- pods are Ready
- restart count is stable

---

## JVM Heap

Confirm:

- heap returned to normal
- heap growth stopped

---

## Garbage Collection

Confirm:

- GC activity normalised
- GC time is no longer rapidly increasing

---

## Application

Confirm:

- P95 latency recovered
- P99 latency recovered
- error rate recovered
- application-specific growth stopped

---

## Monitoring

Confirm:

- Prometheus alert resolved
- Grafana metrics returned to baseline
- SLO recovered

Only then should the incident be considered recovered.

---

# 13. Capture Evidence

Capture evidence while investigating.

Useful evidence includes:

- Grafana screenshots
- Prometheus queries
- alert firing time
- alert resolution time
- pod state
- container memory
- JVM heap
- GC metrics
- latency
- application-specific metrics
- Kubernetes events
- deployment history
- current image version
- rollback output
- recovery metrics

Do not rely only on memory when writing the postmortem.

---

# 14. Record Incident Timings

Record:

| Event | Timestamp |
|---|---|
| Customer impact begins | |
| Monitoring detects issue | |
| Alert fires | |
| SRE acknowledges | |
| Triage starts | |
| Triage completed | |
| Investigation starts | |
| Hypothesis formed | |
| Mitigation decision | |
| Mitigation starts | |
| Service restored | |
| SLO recovered | |
| Alert resolved | |

Use these timestamps to calculate:

### TTD

Time To Detect:

```text
Problem begins → Detection
```

### TTA

Time To Acknowledge:

```text
Alert fires → Engineer acknowledges
```

### TTR

Time To Restore:

```text
Problem begins → Service restored
```

Across multiple comparable incidents, these measurements can contribute to:

- MTTD
- MTTA
- MTTR

Do not claim percentage improvements without measured historical evidence.

---

# 15. Escalation

Escalate when:

- customer impact continues after mitigation
- rollback does not recover the service
- heap immediately begins growing again
- multiple applications are affected
- node memory pressure develops
- a shared library/platform component may be involved
- rollback is considered unsafe
- the blast radius is increasing

---

# 16. After the Incident

Once customer service is restored:

1. Complete the RCA.
2. Complete the postmortem.
3. Review the incident timeline.
4. Calculate response timings.
5. Identify what delayed detection.
6. Identify what delayed recovery.
7. Identify missing monitoring.
8. Identify automation opportunities.
9. Update this runbook.

Ask:

> What would allow us to detect this faster next time?

and:

> What would allow us to restore service faster next time?

The answers should become corrective actions.

---

# Runbook Improvement

This runbook is not static.

After every relevant incident ask:

- Which step helped?
- Which step was confusing?
- Which command was missing?
- Which dashboard was missing?
- Which step took too long?
- Could a manual check become a script?
- Could detection become an alert?
- Could mitigation safely become automated?

Update the runbook with what was learned.
````

Save with:

```text
Ctrl+O
Enter
Ctrl+X
```

Then verify:

```bash
head -30 runbooks/applications/jvm-memory-pressure.md
```

## That's all we're doing right now

The relationship is simply:

```text
RUNBOOK
   │
   │ used DURING an incident
   ▼
"How do I investigate and respond?"
   
POSTMORTEM
   │
   │ written AFTER an incident
   ▼
"What happened and what did we learn?"

RCA
   │
   │ part of the investigation/postmortem
   ▼
"Why did it happen?"

MTTD / MTTR
   │
   │ measurements
   ▼
"How quickly did we detect and recover?"
```

## Lessons from INC-004B

### Readiness vs Liveness

A readiness failure and liveness failure have different consequences.

Readiness failure:

`Stop routing traffic to this pod.`

Liveness failure:

`Terminate and restart this container.`

During INC-004B, aggressive liveness settings caused Kubernetes to restart the
JVM during severe memory/GC pressure.

The restart temporarily cleared process-local cache and heap state and caused
customer latency to recover.

Do not mistake this automatic recovery for permanent remediation of the
underlying application defect.

### Historical Events Matter

Current pod state may show:

`Running / Ready`

while Kubernetes events reveal previous:

- readiness failures
- liveness failures
- restarts

Always inspect event history during memory-pressure incidents.

### Incident Timing

Record timestamps while the incident is occurring.

Do not reconstruct TTD/TTA/TTR from memory after the incident.