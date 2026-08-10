# Answer Key
The fault is an unbounded in-memory cache. Each `/profile` request retains ~1 MiB and adds latency.

Expected diagnosis:
- Kubernetes healthy
- no restart/OOM initially
- heap rising
- cache entries rising
- GC increasing
- P95 increasing

Root cause: cache eviction disabled.

Mitigation: disable leak / rollback. Restarting alone temporarily clears heap but does not fix the release.
