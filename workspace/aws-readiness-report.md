AWS environment: Floci local AWS emulator
Endpoint: http://localhost:4566
Account ID: 000000000000
Principal: arn:aws:iam::000000000000:root
Region: us-east-1

Availability Zones:
- us-east-1a
- us-east-1b
- us-east-1c

Existing VPC:
- ID: vpc-default
- CIDR: 172.31.0.0/16
- Default: true

Existing subnets:
- subnet-default-a — 172.31.0.0/20 — us-east-1a
- subnet-default-b — 172.31.16.0/20 — us-east-1b
- subnet-default-c — 172.31.32.0/20 — us-east-1c

Existing S3 buckets: none
Existing EKS clusters: none

Decision:
GO — Floci is ready for Terraform compatibility testing.