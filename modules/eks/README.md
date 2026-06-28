# AWS EKS Module

Production-grade EKS cluster with managed node groups, IRSA, OIDC, KMS secrets encryption, control plane logging, and core add-ons.

## Features

- EKS cluster with KMS-encrypted secrets
- OIDC provider for IAM Roles for Service Accounts (IRSA)
- Three managed node groups: `system`, `application`, `monitoring`
- IMDSv2 enforced on all nodes via launch template
- Encrypted EBS volumes (gp3) on all nodes
- VPC CNI, CoreDNS, kube-proxy, EBS CSI add-ons with IRSA
- All control plane logs shipped to CloudWatch

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name       = "myapp-prod"
  kubernetes_version = "1.29"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  endpoint_public_access = true
  public_access_cidrs    = ["10.8.0.0/16"]  # restrict to VPN CIDR

  app_node_instance_types = ["m5.xlarge"]
  app_node_capacity_type  = "ON_DEMAND"
  app_node_desired        = 3
  app_node_min            = 3
  app_node_max            = 10

  tags = {
    Environment = "production"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

### Cost-optimized staging example (SPOT nodes)

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name       = "myapp-staging"
  kubernetes_version = "1.29"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  app_node_instance_types = ["m5.large", "m5a.large", "m4.large"]
  app_node_capacity_type  = "SPOT"
  app_node_desired        = 2
  app_node_min            = 2
  app_node_max            = 6

  tags = {
    Environment = "staging"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

## Node Groups

| Group | Purpose | Taint | Default size |
|-------|---------|-------|--------------|
| `system` | CoreDNS, kube-proxy, cluster-autoscaler | `CriticalAddonsOnly=true:NoSchedule` | 3–6 × t3.medium |
| `application` | Workloads | none | configurable |
| `monitoring` | Prometheus, Grafana | `monitoring=true:NoSchedule` | 2–4 × m5.large |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `cluster_name` | string | required | EKS cluster name |
| `kubernetes_version` | string | `"1.29"` | Kubernetes version (MAJOR.MINOR) |
| `vpc_id` | string | required | VPC ID |
| `private_subnet_ids` | list(string) | required | Private subnets for node groups |
| `public_subnet_ids` | list(string) | required | Public subnets for API endpoint |
| `endpoint_public_access` | bool | `true` | Expose API server publicly |
| `public_access_cidrs` | list(string) | `["10.8.0.0/16"]` | CIDRs allowed to reach the API (never `0.0.0.0/0`) |
| `service_cidr` | string | `"172.20.0.0/16"` | Kubernetes service IP range |
| `app_node_instance_types` | list(string) | `["m5.xlarge"]` | Instance types for the app node group |
| `app_node_capacity_type` | string | `"ON_DEMAND"` | `ON_DEMAND` or `SPOT` |
| `app_node_desired` | number | `3` | Desired app node count |
| `app_node_min` | number | `3` | Minimum app node count |
| `app_node_max` | number | `10` | Maximum app node count |
| `tags` | map(string) | `{}` | Tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | EKS cluster ID |
| `cluster_endpoint` | API server endpoint |
| `cluster_certificate_authority` | Cluster CA data |
| `oidc_provider_arn` | OIDC provider ARN (for IRSA) |
| `oidc_provider_url` | OIDC provider URL |
| `node_group_role_arn` | Node group IAM role ARN |
| `kms_key_arn` | KMS key ARN used for secrets encryption |
| `cluster_security_group_id` | Cluster security group ID |
| `node_security_group_id` | Node security group ID |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
| tls | >= 4.0 |
