#!/usr/bin/env bash
set -uo pipefail

REPO_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/../../.." &&
  pwd
)"

REPORT="${1:-${REPO_ROOT}/workspace/aws-preflight-report.txt}"

mkdir -p "$(dirname "$REPORT")"

# Default Floci endpoint
FLOCI_ENDPOINT="${FLOCI_ENDPOINT:-http://localhost:4566}"

# Default region
AWS_REGION="${AWS_REGION:-us-east-1}"

section() {
    printf "\n============================================================\n"
    printf "%s\n" "$1"
    printf "============================================================\n"
}

run() {
    printf "\n$ %s\n" "$*"
    "$@" 2>&1 || printf "[failed: %s]\n" "$?"
}

{
    section "Northstar AWS Floci Preflight"
    date -u

    section "Local Tooling"

    run aws --version
    run terraform version
    run kubectl version --client
    run docker --version
    run git --version
    run jq --version

    section "AWS Configuration"

    run aws configure list
    run aws configure get region

    section "Floci Configuration"

    echo "Endpoint : $FLOCI_ENDPOINT"
    echo "Region   : $AWS_REGION"

    section "AWS Identity"

    run aws sts get-caller-identity \
        --region "$AWS_REGION" \
        --endpoint-url "$FLOCI_ENDPOINT"

    section "Availability Zones"

    run aws ec2 describe-availability-zones \
        --region "$AWS_REGION" \
        --endpoint-url "$FLOCI_ENDPOINT" \
        --filters Name=state,Values=available \
        --query 'AvailabilityZones[].{Name:ZoneName,ZoneId:ZoneId,State:State}' \
        --output table

    section "VPCs"

    run aws ec2 describe-vpcs \
        --region "$AWS_REGION" \
        --endpoint-url "$FLOCI_ENDPOINT" \
        --query 'Vpcs[].{VpcId:VpcId,Cidr:CidrBlock,Default:IsDefault,State:State}' \
        --output table

    section "Subnets"

    run aws ec2 describe-subnets \
        --region "$AWS_REGION" \
        --endpoint-url "$FLOCI_ENDPOINT" \
        --query 'Subnets[].{SubnetId:SubnetId,VpcId:VpcId,AZ:AvailabilityZone,Cidr:CidrBlock,AvailableIPs:AvailableIpAddressCount}' \
        --output table

    section "S3"

    run aws s3api list-buckets \
        --region "$AWS_REGION" \
        --endpoint-url "$FLOCI_ENDPOINT"

    section "EKS"

    run aws eks list-clusters \
        --region "$AWS_REGION" \
        --endpoint-url "$FLOCI_ENDPOINT"

    section "Floci Health Check"

    run curl -s "$FLOCI_ENDPOINT"

} | tee "$REPORT"

echo
echo "============================================================"
echo "Report written to $REPORT"
echo "============================================================"