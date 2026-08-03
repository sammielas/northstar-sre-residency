#!/usr/bin/env bash

set -euo pipefail

FLOCI_ENDPOINT="${FLOCI_ENDPOINT:-http://localhost:4566}"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_REGION
export AWS_DEFAULT_REGION="$AWS_REGION"

if ! docker inspect floci >/dev/null 2>&1; then
  echo "The Floci container does not exist."
  echo "Create it with:"
  echo "docker run -d --name floci -p 4566:4566 floci/floci:latest"
  exit 1
fi

container_status="$(
  docker inspect floci --format '{{.State.Status}}'
)"

if [[ "$container_status" != "running" ]]; then
  echo "The Floci container is not running."
  echo "Start it with:"
  echo "docker start floci"
  exit 1
fi

identity="$(
  aws sts get-caller-identity \
    --region "$AWS_REGION" \
    --endpoint-url "$FLOCI_ENDPOINT" \
    --output json
)"

echo "Floci AWS session is valid."
echo "$identity" | jq
echo "Endpoint: $FLOCI_ENDPOINT"
echo "Region:   $AWS_REGION"
