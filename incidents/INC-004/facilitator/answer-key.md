# INC-004 Facilitator Answer Key

Do not read until the investigation is complete.

The injected sidecar retains roughly 20 MiB every five seconds and has a 160 MiB memory limit. The intended evidence is an increasing restart count with `lastState.terminated.reason=OOMKilled`.

If the container is OOMKilled while the node reports `MemoryPressure=False`, the immediate failure is container-level memory-limit exhaustion, not node-wide exhaustion.

Key lesson:
- requests influence scheduling;
- limits constrain consumption;
- increasing a memory limit can delay an OOM without fixing an unbounded leak.

Recovery requires the faulty behaviour to be removed and telemetry to demonstrate stable memory, healthy pods, healthy node, recovered SLIs and resolved alerts.
