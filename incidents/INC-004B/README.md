# INC-004B — JVM Heap Leak Before OOM

INC-004 taught cgroup/container OOM.
INC-004B teaches pre-OOM JVM degradation:

heap ↑ → GC ↑ → latency ↑ while Pods stay healthy and restart count stays 0.
