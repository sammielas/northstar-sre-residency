#!/usr/bin/env bash
set -euo pipefail

PROMETHEUS_URL="${PROMETHEUS_URL:-http://127.0.0.1:9090}"

query() {
  curl -sfG \
    --connect-timeout 3 \
    --max-time 10 \
    "$PROMETHEUS_URL/api/v1/query" \
    --data-urlencode "query=$1" |
  jq -r '
    if (.data.result | length) == 0 then
      "NO_DATA"
    else
      .data.result[0].value[1]
    end
  '
}

echo "=== NORTHSTAR PRE-CHANGE RELIABILITY CHECK ==="
echo

TRAFFIC=$(query '
sum(rate(northstar_checkout_attempts_total[5m]))
')

AVAILABILITY=$(query '
(
  sum(rate(northstar_checkout_attempts_total{result="accepted"}[5m]))
  or vector(0)
)
/
sum(rate(northstar_checkout_attempts_total[5m]))
')

ERROR_RATE=$(query '
(
  sum(rate(northstar_checkout_attempts_total{result="failed"}[5m]))
  or vector(0)
)
/
sum(rate(northstar_checkout_attempts_total[5m]))
')

SLO_TARGET=$(query '
slo:objective:ratio{sloth_service="checkout"}
')

echo "Traffic      : $TRAFFIC"
echo "Availability : $AVAILABILITY"
echo "Error Rate   : $ERROR_RATE"
echo "SLO Target   : $SLO_TARGET"

# ---------------------------------------------------------
# Telemetry confidence gate
# ---------------------------------------------------------

if [[ "$TRAFFIC" == "NO_DATA" ||
      "$SLO_TARGET" == "NO_DATA" ]]; then

  echo "Burn Rate    : NO_DATA"
  echo
  echo "DECISION: RESTRICT"
  echo "Reason: Required reliability telemetry is unavailable."
  exit 2
fi

if [[ "$TRAFFIC" == "0" || "$TRAFFIC" == "NaN" ]]; then
  echo "Burn Rate    : NO_DATA"
  echo
  echo "DECISION: RESTRICT"
  echo "Reason: Insufficient recent Checkout traffic to validate reliability."
  exit 2
fi

if [[ "$AVAILABILITY" == "NO_DATA" ||
      "$AVAILABILITY" == "NaN" ||
      "$ERROR_RATE" == "NO_DATA" ||
      "$ERROR_RATE" == "NaN" ]]; then

  echo "Burn Rate    : NO_DATA"
  echo
  echo "DECISION: RESTRICT"
  echo "Reason: Reliability telemetry is incomplete."
  exit 2
fi

# ---------------------------------------------------------
# Calculate burn rate directly:
#
# error budget = 1 - SLO
# burn rate    = error rate / error budget
# ---------------------------------------------------------

BURN_RATE=$(
  awk \
    -v error_rate="$ERROR_RATE" \
    -v slo="$SLO_TARGET" '
BEGIN {
    error_budget = 1 - slo

    if (error_budget <= 0) {
        print "NaN"
        exit
    }

    printf "%.2f", error_rate / error_budget
}'
)

echo "Burn Rate    : ${BURN_RATE}x"
echo

# ---------------------------------------------------------
# Change decision
# ---------------------------------------------------------

DECISION=$(
  awk \
    -v availability="$AVAILABILITY" \
    -v target="$SLO_TARGET" \
    -v burn="$BURN_RATE" '
BEGIN {
    if (availability < target || burn >= 6) {
        print "FREEZE"
    } else if (burn >= 1) {
        print "RESTRICT"
    } else {
        print "GO"
    }
}'
)

echo "DECISION: $DECISION"

case "$DECISION" in
  GO)
    echo "Reason: Reliability telemetry is healthy and supports a normal change."
    ;;

  RESTRICT)
    echo "Reason: Reliability risk is elevated; limit production changes."
    ;;

  FREEZE)
    echo "Reason: Measured customer reliability is outside the normal-change threshold."
    ;;
esac
