# Grafana queries

Heap MiB:
```promql
sum(jvm_memory_used_bytes{area="heap"}) / 1024 / 1024
```

Heap %:
```promql
100 * sum(jvm_memory_used_bytes{area="heap"}) / sum(jvm_memory_max_bytes{area="heap"})
```

GC collections/sec:
```promql
rate(jvm_gc_collection_seconds_count[2m])
```

GC time/sec:
```promql
rate(jvm_gc_collection_seconds_sum[2m])
```

P95:
```promql
northstar_profile_p95_seconds
```

Cache entries:
```promql
northstar_cache_entries
```

Expected signature: heap ↑, cache entries ↑, GC ↑, P95 ↑, while restarts remain 0.
