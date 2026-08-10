# INC-004B — JVM Heap Leak / Cache Eviction Failure

Scenario: a cache optimisation release disables eviction. Pods remain healthy, but JVM heap, GC activity and P95 latency rise.

Workflow:
1. Capture baseline.
2. Deploy lab workload.
3. Verify Prometheus scraping.
4. Add Grafana JVM panels.
5. Run `inject.sh`.
6. Investigate heap, GC, CPU, latency and recent changes.
7. Capture evidence.
8. Run `rollback.sh`.
9. Verify recovery.
10. Complete `postmortem.md`.
11. Read `facilitator/answer-key.md` last.
