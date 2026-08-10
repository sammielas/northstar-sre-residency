# INC-004 Postmortem

## Incident
INC-004 — Memory Exhaustion / OOMKill

## Severity

## Executive summary

## Detection

## Customer impact

## Timeline
| Time | Event |
|---|---|
| | Healthy baseline confirmed |
| | Fault introduced |
| | Memory growth observed |
| | First OOMKill |
| | Alert/symptom detected |
| | Investigation began |
| | Root cause identified |
| | Mitigation decision |
| | Rollback completed |
| | SLI/SLO recovered |
| | Incident resolved |

## Technical symptoms

## Root cause

## Evidence supporting root cause

## Why this was container OOM and not node memory pressure

## Contributing factors

## What went well

## What went poorly

## Kubernetes behaviour
Explain memory requests, memory limits, OOMKilled/exit 137, restart behaviour, and why Running does not necessarily mean reliable.

## Mitigation

## Recovery verification

## Customer/SLO impact

## Error-budget impact

## Five whys
1. Why did the container restart?
2. Why was its memory limit reached?
3. Why did memory continue increasing?
4. Why was this not prevented/detected earlier?
5. What systemic control would prevent recurrence?

## Preventive actions
| Action | Owner | Priority | Due date | Status |
|---|---|---|---|---|
| Add memory-growth alerting | | | | |
| Add OOM/restart alerting | | | | |
| Add memory profiling to release testing | | | | |
| Review resource requests/limits | | | | |
| Add post-deployment SLO verification | | | | |
| Evaluate automated rollback | | | | |

## Lessons learned

## Interview STAR summary
### Situation
### Task
### Action
### Result
