# INC-003 Runbook

1. Establish customer impact from request rate, errors, P50/P95/P99, SLO status and dependency health.
2. Check whether dependency signals remain healthy.
3. Form an initial hypothesis.
4. Correlate with rollout history:

```bash
kubectl rollout history deployment/checkout -n northstar-dev
kubectl get rs -n northstar-dev -l app.kubernetes.io/name=checkout --sort-by=.metadata.creationTimestamp
kubectl get deployment checkout -n northstar-dev -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

5. Inspect centralized logs in Loki:

```logql
{namespace="northstar-dev",app="checkout"}
```

6. Roll back only when evidence supports it.
7. Verify P95 < 250 ms, error ratio baseline, SLO recovery, alert resolution and successful customer requests.
