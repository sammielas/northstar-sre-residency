# INC-004 — Memory Leak / OOMKill

NorthStar SRE Residency incident simulation.

```text
INC-004/
├── START-HERE.md
├── README.md
├── inject.sh
├── rollback.sh
├── expected-alerts.md
├── runbook.md
├── postmortem.md
├── evidence/
└── facilitator/
    └── answer-key.md
```

The simulation adds a bounded memory-consuming sidecar to Checkout. It preserves the existing Checkout image, probes and security configuration while giving you repeatable OOMKill evidence.
