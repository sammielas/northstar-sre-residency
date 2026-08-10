# INC-004 Expected Signals

Exact alert names depend on the rules currently installed.

Expected Kubernetes evidence:
- `restartCount` increases for `memory-leak-simulator`
- `lastState.terminated.reason = OOMKilled`
- commonly `exitCode = 137`

Check:
```bash
kubectl get pods -n northstar-dev -l app.kubernetes.io/name=checkout
kubectl describe pod <pod> -n northstar-dev
kubectl top pods -n northstar-dev
kubectl top node
```

Diagnostic goal: distinguish a container exceeding its own memory limit from node-wide memory pressure.
