# Northstar SRE Residency

A production-style Site Reliability Engineering residency built around one evolving retail platform, one Git history, and 100 reproducible production incidents.

## Overview

Northstar SRE Residency develops Mid-level and Senior SRE skills through real operational work rather than isolated tool tutorials.

## Current status

- Phase: Sprint 0 — Platform Foundation
- Current milestone: Floci and Terraform bootstrap
- Current environment: Local Floci AWS emulator
- Current endpoint: `http://localhost:4566`

## Architecture

```text
Developer
   |
GitHub
   |
GitHub Actions
   |
Terraform / Helm / Kubernetes
   |
Floci local AWS-compatible environment
   |
Northstar platform services
   |
Prometheus / Grafana / Loki / Tempo
```

## Technology stack

| Layer | Technology |
|---|---|
| Application | Python, FastAPI |
| Containers | Docker |
| Local orchestration | Docker Compose |
| AWS emulation | Floci |
| Infrastructure as Code | Terraform |
| Orchestration | Kubernetes |
| Packaging | Helm |
| GitOps | Argo CD |
| CI/CD | GitHub Actions |
| Database | PostgreSQL |
| Cache | Redis |
| Messaging | RabbitMQ |
| Metrics | Prometheus |
| Dashboards | Grafana |
| Logging | Loki |
| Tracing | Tempo |
| Instrumentation | OpenTelemetry |

## Quick start

```bash
git clone https://github.com/sammielas/northstar-sre-residency.git
cd northstar-sre-residency
./scripts/check-required-tools.sh
docker start floci
./platform/floci/scripts/validate-aws-session.sh
./platform/floci/scripts/preflight.sh
```

## Commit convention

This repository uses Conventional Commits:

```text
feat:
fix:
docs:
refactor:
test:
ci:
chore:
```

## Security

Never commit AWS credentials, `.env` files, Terraform state, `terraform.tfvars`, saved Terraform plans, local secrets, or private keys.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Roadmap

See [docs/roadmap.md](docs/roadmap.md).

## License

See [LICENSE](LICENSE).
