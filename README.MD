# Terraform Modules

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-purple?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Provider%20%3E%3D5.0-orange?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)

Production-grade, reusable Terraform modules for AWS — structured for multi-region, multi-environment deployments.

---

## Repository Structure

```
terraform-modules/
├── modules/                    # Reusable infrastructure building blocks
│   ├── vpc/                    # VPC, subnets, NAT gateways, flow logs
│   ├── eks/                    # EKS cluster, node groups, IRSA, add-ons
│   ├── rds/                    # Aurora PostgreSQL, Secrets Manager, KMS
│   ├── alb/                    # Application Load Balancer, listeners
│   ├── autoscaling/            # EC2 Auto Scaling Group, launch template
│   └── s3/                     # S3 buckets, encryption, lifecycle, replication
│
└── resources/                  # Environment root modules (real deployments)
    ├── us-east-1/
    │   ├── staging/            # VPC + EKS  (SPOT nodes, 1 NAT)
    │   └── production/         # VPC + EKS + RDS  (ON_DEMAND, 3 NAT, deletion protection)
    └── eu-west-1/
        ├── staging/
        └── production/
```

Each `resources/<region>/<env>/` is an independent Terraform root module with its own remote state, provider config, and `.tfvars`.

---

## Available Modules

| Module | Description |
|--------|-------------|
| [`modules/vpc`](./modules/vpc) | Multi-AZ VPC with configurable subnets and NAT strategy |
| [`modules/eks`](./modules/eks) | EKS cluster with managed node groups, OIDC/IRSA, KMS encryption |
| [`modules/rds`](./modules/rds) | Aurora PostgreSQL with auto-rotating credentials via Secrets Manager |
| [`modules/alb`](./modules/alb) | Application Load Balancer with HTTPS and access logging |
| [`modules/autoscaling`](./modules/autoscaling) | EC2 Auto Scaling Group with launch template |
| [`modules/s3`](./modules/s3) | S3 buckets with encryption, versioning, lifecycle, and replication |

---

## CIDR Allocation

Non-overlapping CIDRs across all regions and environments — essential for future VPC peering or Transit Gateway:

| Environment | us-east-1 | eu-west-1 |
|-------------|-----------|-----------|
| staging | `10.1.0.0/16` | `10.11.0.0/16` |
| production | `10.2.0.0/16` | `10.12.0.0/16` |

---

## Deploying an Environment

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured (`aws configure` or `AWS_*` environment variables)
- An S3 bucket and DynamoDB table for remote state (see [State Management](#state-management))

### Steps

```bash
# 1. Navigate to the target environment
cd resources/us-east-1/production

# 2. Fill in your state bucket/table in providers.tf

# 3. Set your project name, VPN CIDR, etc. in terraform.tfvars

# 4. Initialise
terraform init

# 5. Preview
terraform plan

# 6. Apply
terraform apply
```

### Post-deploy: update kubeconfig

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name myapp-production
```

### Retrieve database credentials

```bash
aws secretsmanager get-secret-value \
  --secret-id myapp-production-db-credentials \
  --query SecretString --output text | jq .
```

---

## State Management

Each environment writes to a separate S3 key, with DynamoDB for locking. Create these once:

```bash
# State bucket
aws s3api create-bucket --bucket my-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket my-terraform-state \
  --versioning-configuration Status=Enabled

# Lock table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

State layout:
```
s3://my-terraform-state/
├── us-east-1/staging/terraform.tfstate
├── us-east-1/production/terraform.tfstate
├── eu-west-1/staging/terraform.tfstate
└── eu-west-1/production/terraform.tfstate
```

---

## Terraform Best Practices

### Module design

- **Modules own resources, not providers.** Provider and backend config lives in `resources/<region>/<env>/providers.tf` only — never inside a module.
- **One concern per module.** VPC doesn't know about EKS; EKS doesn't manage DNS.
- **Pass values via outputs, not data sources.** Don't re-query what Terraform already knows.
- **Every module has a `versions.tf`** that pins the minimum Terraform and provider versions.

### Variables and state

- **Never commit `.tfstate` or `.tfplan` files** — they can contain plaintext secrets.
- **Use `terraform.tfvars` for non-secret values.** Inject secrets via `TF_VAR_*` env vars or a secrets manager.
- **Separate state per environment** so a broken staging apply can never corrupt production state.
- **Use `prevent_destroy = true`** on critical resources: RDS clusters, KMS keys, S3 buckets with data.

### Security

- **KMS-encrypt everything at rest** — EKS secrets, EBS volumes, RDS storage, Secrets Manager secrets all use a customer-managed KMS key.
- **Enforce IMDSv2** on all EC2/EKS nodes (`http_tokens = "required"` in the launch template).
- **Never use `0.0.0.0/0` on the EKS public API endpoint** — restrict `public_access_cidrs` to your VPN or office CIDR.
- **Enable VPC Flow Logs** in production for security auditing and incident response.
- **Rotate all secrets** — the RDS module rotates the DB password every 30 days via AWS-managed rotation.

### Tagging

All root modules apply a `default_tags` block on the provider, so every resource is tagged automatically:

```hcl
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "production"
      Region      = "us-east-1"
      Project     = "myapp"
      ManagedBy   = "terraform"
      Repository  = "SyedaMasarath/terraform-modules"
    }
  }
}
```

### Linting and validation

```bash
terraform fmt -recursive        # format all files
terraform validate              # syntax + type check
tflint --recursive              # lint rules
trivy config .                  # security misconfig scan
```

---

## Environment Comparison

| Setting | staging | production |
|---------|---------|------------|
| NAT Gateways | 1 (cost-optimized) | 3 (one per AZ, HA) |
| EKS capacity type | SPOT | ON_DEMAND |
| App node count | 2–6 | 3–10 |
| Node instance type | m5.large (mixed) | m5.xlarge |
| RDS | — | 2 instances (writer + reader) |
| RDS instance class | — | db.r7g.large |
| Deletion protection | disabled | enabled |

---

## Blog Posts

- [How to make AWS EKS auto production-ready](https://syedamasarath.substack.com/p/how-to-make-aws-eks-auto-production)
- [Git branching strategies for DevOps](https://syedamasarath.substack.com/p/git-branching-strategies-for-devops)

## Connect

- **GitHub**: https://github.com/SyedaMasarath
- **LinkedIn**: https://www.linkedin.com/in/syeda-masarath-zaidi/
- **Blog**: https://syedamasarath.substack.com/

---

*Built with ❤️ and ☕ by Masarath*

