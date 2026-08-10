# INC-004 — START HERE
## Memory Leak → OOMKill → Availability Degradation

You are the on-call SRE. Checkout begins healthy, then memory consumption grows until a container exceeds its memory limit.

### Objectives
1. Capture the healthy baseline.
2. Inject the incident.
3. Observe memory and restart behaviour.
4. Prove whether the failure is container OOM or node memory pressure.
5. Assess SLI/SLO impact.
6. Mitigate and verify recovery.
7. Complete the postmortem.

### Before injection
```bash
kubectl get deployment checkout -n northstar-dev
kubectl get pods -n northstar-dev -l app.kubernetes.io/name=checkout
kubectl top pods -n northstar-dev -l app.kubernetes.io/name=checkout
kubectl top node
```

Then, from the repository root:
```bash
./incidents/INC-004/inject.sh
```

Do not read `facilitator/answer-key.md` until the investigation is complete.
