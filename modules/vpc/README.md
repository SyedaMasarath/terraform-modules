# AWS VPC Module

Production-grade VPC with public/private subnets, NAT Gateways, and optional VPC Flow Logs.

## Features

- Configurable public and private subnet counts across all AZs
- Single or per-AZ NAT Gateways (cost-optimized vs. HA)
- Automatic CIDR block calculation via `cidrsubnet()`
- Optional VPC Flow Logs (CloudWatch or S3)
- EKS-ready subnet tagging support

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = "myapp-prod"
  vpc_cidr             = "10.2.0.0/16"
  public_subnet_count  = 3
  private_subnet_count = 3
  enable_nat_gateway   = true
  nat_gateway_count    = 3  # one per AZ for HA

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = "production"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

## CIDR Planning

With `vpc_cidr = "10.0.0.0/16"` and `*_subnet_cidr_bits = 4`:

| Subnet | CIDR | IPs |
|--------|------|-----|
| Public 1 (AZ-a) | 10.0.0.0/20 | 4,091 |
| Public 2 (AZ-b) | 10.0.16.0/20 | 4,091 |
| Public 3 (AZ-c) | 10.0.32.0/20 | 4,091 |
| Private 1 (AZ-a) | 10.0.48.0/20 | 4,091 |
| Private 2 (AZ-b) | 10.0.64.0/20 | 4,091 |
| Private 3 (AZ-c) | 10.0.80.0/20 | 4,091 |

Recommended non-overlapping CIDR allocation across regions and environments:

```
us-east-1/dev        10.0.0.0/16
us-east-1/staging    10.1.0.0/16
us-east-1/production 10.2.0.0/16
eu-west-1/dev        10.10.0.0/16
eu-west-1/staging    10.11.0.0/16
eu-west-1/production 10.12.0.0/16
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name_prefix` | string | required | Prefix for all resource names |
| `vpc_cidr` | string | required | VPC CIDR block |
| `public_subnet_count` | number | 3 | Number of public subnets |
| `private_subnet_count` | number | 3 | Number of private subnets |
| `public_subnet_cidr_bits` | number | 4 | Bits to extend VPC CIDR for public subnets |
| `private_subnet_cidr_bits` | number | 4 | Bits to extend VPC CIDR for private subnets |
| `enable_nat_gateway` | bool | true | Create NAT Gateways |
| `nat_gateway_count` | number | 1 | Number of NAT Gateways (1 = cost-optimized, 3 = HA) |
| `enable_flow_logs` | bool | false | Enable VPC Flow Logs |
| `tags` | map(string) | {} | Tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_public_ips` | NAT Gateway public IPs |
| `availability_zones` | AZs used |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
