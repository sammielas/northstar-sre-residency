# Repository Security

Before every push, verify that the repository does not track sensitive or generated files:

```bash
git ls-files | grep -E 'tfstate|tfvars|tfplan|\.env$|credentials|secret'
```

Review staged changes:

```bash
git diff --cached
```

Search for accidental key patterns:

```bash
git grep -nE 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|PRIVATE KEY'
```
