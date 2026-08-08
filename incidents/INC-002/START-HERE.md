# NorthStar SRE Residency
# Incident Simulation Guide

## Incident

INC-002 — Checkout Returns 503

---

# Purpose

This incident package simulates a real production outage.

Your goal is **not** to follow instructions blindly.

Your goal is to investigate the incident exactly as a Site Reliability Engineer would while on call.

Treat this as if you have just been paged by Alertmanager at 2:00 AM.

---

# Before You Start

Ensure the following platform components are already working.

✅ Kubernetes Cluster

✅ Checkout application

✅ Prometheus

✅ Alertmanager

✅ Grafana

✅ Loki

✅ Grafana Alloy

All dashboards should be healthy before injecting the incident.

---

# Package Structure

```
INC-002/

README.md
inject.sh
rollback.sh
runbook.md
expected-alerts.md
postmortem.md

evidence/
```

Each file has a different purpose.

---

# Step 1

Read ONLY

```
README.md
```

Pretend this is the PagerDuty page you received.

Do NOT open any other files yet.

At this point you should only know:

• the alert

• customer symptoms

• severity

Nothing else.

---

# Step 2

Run the chaos script

```
chmod +x inject.sh

./inject.sh
```

This introduces a controlled production failure.

The script keeps running until you stop it.

Do NOT stop it immediately.

Leave the failure active while you investigate.

---

# Step 3

Investigate

Use ONLY the following tools.

✅ Alertmanager

✅ Grafana

✅ Prometheus

✅ Loki

Do NOT use

❌ kubectl logs

❌ kubectl exec

❌ kubectl describe

❌ rollback.sh

Pretend Kubernetes is your last resort.

---

# Step 4

Answer the following questions

Customer impact

What are customers experiencing?

---

Alert

Which alert fired?

Why?

---

Metrics

What changed?

Request rate?

Latency?

Error rate?

Dependencies?

---

Logs

What do the logs reveal?

Which component is failing?

---

Root Cause

What is the most likely cause?

Do NOT guess.

Support your answer using evidence.

---

Mitigation

What would you do to restore service?

---

# Step 5

Verify

After applying the mitigation, verify

Alerts resolve

Dashboard returns healthy

Customers recover

---

# Step 6

Stop the incident

Press

CTRL+C

or run

```
./rollback.sh
```

The environment should return to its original healthy state.

---

# Step 7

Complete the Postmortem

Only now open

```
postmortem.md
```

Complete

Timeline

Root Cause

Customer Impact

Detection

Resolution

Lessons Learned

Preventive Actions

---

# Step 8

Compare

Now read

```
runbook.md
```

Compare your investigation against the recommended workflow.

Do NOT compare before completing the incident.

---

# Step 9

Capture Evidence

Save the following into

```
evidence/
```

Alertmanager screenshots

Grafana dashboard

Prometheus alerts

Loki query

Commands executed

Timeline

Root cause

These become part of your engineering evidence.

---

# Step 10

Git Workflow

After successfully completing the incident

```
git add .

git commit

git push

Open Pull Request

Merge

git checkout main

git pull

Delete feature branch
```

Every completed incident should leave the repository in a clean state.

---

# Rules of the Residency

You are not trying to "finish a lab."

You are responding to an operational incident.

Every action should answer one question.

"What evidence justifies my next action?"

Never restart Pods because they "might be broken."

Never roll back because it "usually works."

Always investigate first.

Evidence

↓

Hypothesis

↓

Validation

↓

Mitigation

↓

Verification

↓

Recovery

That is the SRE workflow this residency is designed to teach.

---

Good luck.

PagerDuty is waiting.