# INC-004 Runbook

## Triage
```bash
kubectl get pods -n northstar-dev -l app.kubernetes.io/name=checkout -o wide
kubectl top pods -n northstar-dev
kubectl top node
```

## Establish restart reason
```bash
kubectl describe pod <pod> -n northstar-dev
kubectl get pod <pod> -n northstar-dev -o jsonpath='{range .status.containerStatuses[*]}container={.name}{"\n"}restarts={.restartCount}{"\n"}lastReason={.lastState.terminated.reason}{"\n"}exitCode={.lastState.terminated.exitCode}{"\n\n"}{end}'
```

## Previous logs
```bash
kubectl logs <pod> -n northstar-dev -c memory-leak-simulator --previous
```

## Check node pressure
```bash
kubectl get node -o custom-columns='NAME:.metadata.name,MEMORY_PRESSURE:.status.conditions[?(@.type=="MemoryPressure")].status'
kubectl describe node
```

`OOMKilled` on the container together with `MemoryPressure=False` strongly supports container-limit exhaustion rather than node-wide exhaustion.

## Customer impact
Correlate restart/OOM timestamps with Grafana/Prometheus request rate, errors, latency and availability.

## Mitigation
```bash
./incidents/INC-004/rollback.sh
```

Do not close the incident just because pods are Running. Verify stable memory, no continuing restart growth, healthy SLIs and resolved alerts.
