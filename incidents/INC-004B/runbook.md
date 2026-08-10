# INC-004B Runbook
1. Confirm customer latency symptom.
2. Confirm Pods/nodes are healthy.
3. Check P95.
4. Check JVM heap and heap %.
5. Check GC activity.
6. Check cache entries.
7. Check CPU/restarts.
8. Correlate with recent deployment.
9. Mitigate by rolling back/disabling leak.
10. Verify heap drops, GC normalises, latency recovers, alerts resolve.

Do not restart Pods first; that clears heap and can hide the evidence.
