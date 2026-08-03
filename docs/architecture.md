# Proposed Northstar Development EKS Architecture

```text
AWS Floci account
       |
Selected AWS Region
       |
Northstar VPC across at least two Availability Zones
       |
Amazon EKS control plane
       |
Managed node group
       |
EKS add-ons: VPC CNI, CoreDNS, kube-proxy, EBS CSI
```

## Decisions to record

- AWS Region:
- Availability Zones:
- Existing or new VPC:
- Cluster name:
- Node instance type:
- Minimum/desired/maximum nodes:
- Public or private API endpoint:
- Storage class strategy:
- Load balancer strategy:
