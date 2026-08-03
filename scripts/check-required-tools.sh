#!/usr/bin/env bash
set -euo pipefail
missing=0
for command in aws terraform kubectl docker git jq; do
  if command -v "$command" >/dev/null 2>&1; then
    printf '%-12s FOUND
' "$command"
  else
    printf '%-12s MISSING
' "$command"
    missing=1
  fi
done
[[ "$missing" -eq 0 ]] || { echo 'Install missing tools before continuing.'; exit 1; }
echo 'All required tools were found.'
