# Contributing

## Branching

Create focused branches from `main`.

Examples:

```text
feat/floci-network
feat/checkout-kubernetes
fix/terraform-bootstrap
docs/oncall-runbook
incident/001-crashloopbackoff
```

## Local validation

Before opening a pull request:

```bash
terraform fmt -check -recursive
bash -n path/to/script.sh
pytest
```

## Commit messages

Use Conventional Commits.

## Pull requests

Every pull request should explain the problem, change, validation, operational risk, and rollback plan.

## Security

Do not commit credentials, state files, local environment files, private keys, or sensitive outputs.
