# AWS VPC Terraform Module

A production-grade, highly customizable Terraform module for creating AWS VPC infrastructure with public/private subnets, NAT Gateways, and Internet Gateway.

## Features

- ✅ **Customizable VPC CIDR**: Define your own VPC CIDR block
- ✅ **Dynamic Subnet Creation**: Control the number of public and private subnets via variables
- ✅ **Automatic CIDR Calculation**: Smart CIDR block calculation using `cidrsubnet()` function
- ✅ **Multi-AZ Support**: Automatically distributes subnets across available AZs
- ✅ **NAT Gateway Options**: Choose between single NAT Gateway (cost-effective) or one per AZ (high availability)
- ✅ **Internet Gateway**: Optional IGW for public subnet internet access
- ✅ **VPC Flow Logs**: Optional flow logs for monitoring and troubleshooting
- ✅ **Production-Ready**: Includes tags, validation, and best practices
- ✅ **Easy to Extend**: Add more subnets in the future without CIDR conflicts

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                           VPC (10.0.0.0/16)                      │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Internet Gateway                        │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                           │                                      │
│  ┌────────────────────────┴─────────────────────────────────┐  │
│  │              Public Route Table (0.0.0.0/0 → IGW)         │  │
│  └─┬─────────────────┬─────────────────┬────────────────────┘  │
│    │                 │                 │                        │
│  ┌─▼──────────┐   ┌─▼──────────┐   ┌─▼──────────┐            │
│  │  Public     │   │  Public     │   │  Public     │            │
│  │  Subnet 1   │   │  Subnet 2   │   │  Subnet 3   │            │
│  │  10.0.0/20  │   │  10.0.16/20 │   │  10.0.32/20 │            │
│  │  AZ-a       │   │  AZ-b       │   │  AZ-c       │            │
│  └─────┬───────┘   └─────┬───────┘   └─────┬───────┘            │
│        │                 │                 │                    │
│   ┌────▼────┐       ┌────▼────┐       ┌────▼────┐              │
│   │   NAT   │       │   NAT   │       │   NAT   │              │
│   │ Gateway │       │ Gateway │       │ Gateway │              │
│   └────┬────┘       └────┬────┘       └────┬────┘              │
│        │                 │                 │                    │
│  ┌─────▼───────┐   ┌─────▼───────┐   ┌─────▼───────┐          │
│  │  Private RT │   │  Private RT │   │  Private RT │          │
│  └─────┬───────┘   └─────┬───────┘   └─────┬───────┘          │
│        │                 │                 │                    │
│  ┌─────▼────────┐  ┌─────▼────────┐  ┌─────▼────────┐         │
│  │   Private    │  │   Private    │  │   Private    │         │
│  │   Subnet 1   │  │   Subnet 2   │  │   Subnet 3   │         │
│  │  10.0.48/20  │  │  10.0.64/20  │  │  10.0.80/20  │         │
│  │  AZ-a        │  │  AZ-b        │  │  AZ-c        │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "path/to/module"

  name_prefix = "my-app"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### High Availability Setup (NAT Gateway per AZ)

```hcl
module "vpc" {
  source = "path/to/module"

  name_prefix = "my-app-ha"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  # One NAT Gateway per AZ for high availability
  enable_nat_gateway = true
  nat_gateway_count  = 3

  tags = {
    Environment = "production"
  }
}
```

### Cost-Optimized Setup (Single NAT Gateway)

```hcl
module "vpc" {
  source = "path/to/module"

  name_prefix = "my-app-dev"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_count  = 2
  private_subnet_count = 2

  # Single NAT Gateway to reduce costs
  enable_nat_gateway = true
  nat_gateway_count  = 1

  tags = {
    Environment = "development"
  }
}
```

### With VPC Flow Logs

```hcl
module "vpc" {
  source = "path/to/module"

  name_prefix = "my-app"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  enable_flow_logs            = true
  flow_logs_destination_type  = "cloud-watch-logs"
  flow_logs_destination_arn   = aws_cloudwatch_log_group.vpc_logs.arn
  flow_logs_iam_role_arn      = aws_iam_role.vpc_flow_logs.arn

  tags = {
    Environment = "production"
  }
}
```

## CIDR Block Planning

The module uses the `cidrsubnet()` function to automatically calculate subnet CIDR blocks:

### Default Configuration (VPC: 10.0.0.0/16)

With `public_subnet_cidr_bits = 4` and `private_subnet_cidr_bits = 4`:

- **Public Subnets**: /20 (4,096 IPs each)
  - Subnet 1: 10.0.0.0/20
  - Subnet 2: 10.0.16.0/20
  - Subnet 3: 10.0.32.0/20

- **Private Subnets**: /20 (4,096 IPs each)
  - Subnet 1: 10.0.48.0/20
  - Subnet 2: 10.0.64.0/20
  - Subnet 3: 10.0.80.0/20

### Adding More Subnets in the Future

To add more subnets, simply increase the count variables:

```hcl
# Initial setup
public_subnet_count  = 3
private_subnet_count = 3

# Later, expand to 4 subnets
public_subnet_count  = 4
private_subnet_count = 4
```

The CIDR blocks will automatically be calculated:
- Public Subnet 4: 10.0.48.0/20
- Private Subnet 4: 10.0.96.0/20

### Custom CIDR Sizing

For larger subnets (more IPs per subnet):

```hcl
# /22 subnets = 1,024 IPs each
public_subnet_cidr_bits  = 6
private_subnet_cidr_bits = 6
```

For smaller subnets (fewer IPs per subnet):

```hcl
# /24 subnets = 256 IPs each
public_subnet_cidr_bits  = 8
private_subnet_cidr_bits = 8
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Name prefix for all resources | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | - | yes |
| public_subnet_count | Number of public subnets | number | 3 | no |
| private_subnet_count | Number of private subnets | number | 3 | no |
| public_subnet_cidr_bits | Additional bits for public subnet CIDR | number | 4 | no |
| private_subnet_cidr_bits | Additional bits for private subnet CIDR | number | 4 | no |
| enable_dns_hostnames | Enable DNS hostnames | bool | true | no |
| enable_dns_support | Enable DNS support | bool | true | no |
| create_igw | Create Internet Gateway | bool | true | no |
| enable_nat_gateway | Enable NAT Gateway | bool | true | no |
| nat_gateway_count | Number of NAT Gateways | number | 1 | no |
| map_public_ip_on_launch | Auto-assign public IPs in public subnets | bool | true | no |
| enable_flow_logs | Enable VPC Flow Logs | bool | false | no |
| flow_logs_destination_type | Flow logs destination type | string | "cloud-watch-logs" | no |
| flow_logs_destination_arn | ARN for flow logs destination | string | "" | no |
| flow_logs_iam_role_arn | IAM role for flow logs | string | "" | no |
| flow_logs_traffic_type | Traffic type for flow logs | string | "ALL" | no |
| tags | Common tags for all resources | map(string) | {} | no |
| public_subnet_tags | Additional tags for public subnets | map(string) | {} | no |
| private_subnet_tags | Additional tags for private subnets | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| igw_id | The ID of the Internet Gateway |
| public_subnet_ids | List of public subnet IDs |
| public_subnet_cidr_blocks | List of public subnet CIDR blocks |
| private_subnet_ids | List of private subnet IDs |
| private_subnet_cidr_blocks | List of private subnet CIDR blocks |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_public_ips | List of NAT Gateway public IPs |
| public_route_table_id | ID of the public route table |
| private_route_table_ids | List of private route table IDs |
| availability_zones | List of AZs used |

## Cost Considerations

### NAT Gateway Costs

NAT Gateways are charged per hour and per GB processed:
- **Single NAT Gateway**: ~$32-45/month + data processing
- **One per AZ (3 AZs)**: ~$96-135/month + data processing

**Recommendations**:
- **Production/HA**: Use one NAT Gateway per AZ (`nat_gateway_count = 3`)
- **Development/Testing**: Use single NAT Gateway (`nat_gateway_count = 1`)
- **Cost-sensitive**: Consider NAT Instances or VPC Endpoints as alternatives

### Elastic IP Costs

- Each NAT Gateway requires an Elastic IP
- Elastic IPs are free when attached to running resources
- Unattached EIPs incur charges (~$0.005/hour)

## Security Best Practices

1. **Network ACLs**: Consider adding NACLs for additional security layer
2. **Security Groups**: Use security groups for instance-level firewalling
3. **VPC Flow Logs**: Enable for security monitoring and troubleshooting
4. **Private Subnets**: Keep databases and application servers in private subnets
5. **Public Subnets**: Only place load balancers and bastion hosts in public subnets


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |


