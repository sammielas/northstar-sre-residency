# INC-001 Investigation Hypotheses

| ID | Hypothesis | Status | Evidence |
|---|---|---|---|
| H1 | Checkout pods crashed | Rejected | Checkout containers remained Running |
| H2 | Checkout application unhealthy | Confirmed symptom | Readiness failed and checkout returned HTTP 503 |
| H3 | PostgreSQL unavailable | Rejected | PostgreSQL pod/service/TCP connectivity healthy |
| H4 | Redis unavailable | Leading hypothesis | Redis has no running replica/endpoints and connectivity fails |
| H5 | General Kubernetes DNS/network failure | Rejected | Service DNS resolves and PostgreSQL connectivity works |
| H6 | CPU or memory saturation | Rejected | Resource usage does not indicate exhaustion |
| H7 | Checkout application release caused outage | Not supported | Current evidence points toward dependency availability |
