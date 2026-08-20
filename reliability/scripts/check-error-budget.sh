#!/usr/bin/env bash
set -euo pipefail

BURN_RATE="${1:-}"

if [[ -z "$BURN_RATE" ]]; then
  echo "Usage: $0 <burn-rate>"
  exit 1
fi

awk -v burn="$BURN_RATE" '
BEGIN {
  printf "Burn Rate: %.2fx\n", burn

  if (burn < 1) {
    print "State: NORMAL"
    print "Decision: Standard changes permitted."
  }
  else if (burn < 2) {
    print "State: RESTRICTED"
    print "Decision: Canary + increased review required."
  }
  else if (burn < 6) {
    print "State: COLD FREEZE"
    print "Decision: Block normal feature releases."
  }
  else {
    print "State: HARD FREEZE"
    print "Decision: Emergency remediation changes only."
  }
}'
