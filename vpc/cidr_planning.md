# VPC CIDR Planning Guide

This guide helps you plan your VPC and subnet CIDR blocks for current and future needs.

## Understanding CIDR Notation

CIDR notation consists of an IP address and a prefix length:
- `10.0.0.0/16` means the first 16 bits are the network portion
- `/16` = 65,536 IP addresses
- `/20` = 4,096 IP addresses
- `/24` = 256 IP addresses

## Recommended VPC Sizes

### Small Environment (Development/Testing)
```
VPC CIDR: 10.0.0.0/16 (65,536 IPs)
├── Public Subnets: /24 (256 IPs each)
└── Private Subnets: /24 (256 IPs each)

Configuration:
  public_subnet_cidr_bits  = 8
  private_subnet_cidr_bits = 8
```

### Medium Environment (Production)
```
VPC CIDR: 10.0.0.0/16 (65,536 IPs)
├── Public Subnets: /20 (4,096 IPs each)
└── Private Subnets: /20 (4,096 IPs each)

Configuration:
  public_subnet_cidr_bits  = 4
  private_subnet_cidr_bits = 4
```

### Large Environment (Enterprise)
```
VPC CIDR: 10.0.0.0/16 (65,536 IPs)
├── Public Subnets: /22 (1,024 IPs each)
└── Private Subnets: /19 (8,192 IPs each)

Configuration:
  public_subnet_cidr_bits  = 6  # /22 subnets
  private_subnet_cidr_bits = 3  # /19 subnets
```

## CIDR Calculation Examples

### Example 1: VPC 10.0.0.0/16 with 3 Public + 3 Private Subnets

**Configuration:**
```hcl
vpc_cidr                 = "10.0.0.0/16"
public_subnet_count      = 3
private_subnet_count     = 3
public_subnet_cidr_bits  = 4  # Results in /20
private_subnet_cidr_bits = 4  # Results in /20
```

**Resulting Subnets:**
```
Public Subnets (4,096 IPs each):
├── 10.0.0.0/20    (10.0.0.0 - 10.0.15.255)    - AZ-a
├── 10.0.16.0/20   (10.0.16.0 - 10.0.31.255)   - AZ-b
└── 10.0.32.0/20   (10.0.32.0 - 10.0.47.255)   - AZ-c

Private Subnets (4,096 IPs each):
├── 10.0.48.0/20   (10.0.48.0 - 10.0.63.255)   - AZ-a
├── 10.0.64.0/20   (10.0.64.0 - 10.0.79.255)   - AZ-b
└── 10.0.80.0/20   (10.0.80.0 - 10.0.95.255)   - AZ-c

Available for expansion: 10.0.96.0/20 onwards
```

### Example 2: Adding More Subnets Later

**Initial Setup:**
```hcl
public_subnet_count  = 3
private_subnet_count = 3
```

**Expand Later (no CIDR conflicts!):**
```hcl
public_subnet_count  = 4
private_subnet_count = 5
```

**New Subnets:**
```
New Public Subnet 4:
└── 10.0.48.0/20   - AZ-a (reuses first private slot)

New Private Subnets 4-5:
├── 10.0.96.0/20   - AZ-a
└── 10.0.112.0/20  - AZ-b
```

## Multi-VPC Architecture

For organizations with multiple environments:

```
Production VPC:     10.0.0.0/16
Staging VPC:        10.1.0.0/16
Development VPC:    10.2.0.0/16
Shared Services:    10.3.0.0/16
```

Or using private address space:

```
Production VPC:     172.16.0.0/16
Staging VPC:        172.17.0.0/16
Development VPC:    172.18.0.0/16
Shared Services:    172.19.0.0/16
```

## AWS Reserved IPs

AWS reserves 5 IPs in each subnet:
- **.0** - Network address
- **.1** - VPC router
- **.2** - DNS server
- **.3** - Future use
- **.255** - Broadcast (not used in VPC but reserved)

**Example:** 10.0.0.0/24 (256 IPs)
- Total: 256 IPs
- Reserved: 5 IPs
- **Usable: 251 IPs**

## CIDR Calculator Reference

| CIDR | Total IPs | Usable IPs | Use Case |
|------|-----------|------------|----------|
| /16  | 65,536    | 65,531     | Large VPC |
| /17  | 32,768    | 32,763     | Medium-Large VPC |
| /18  | 16,384    | 16,379     | Medium VPC |
| /19  | 8,192     | 8,187      | Small-Medium VPC |
| /20  | 4,096     | 4,091      | Large subnet |
| /21  | 2,048     | 2,043      | Medium subnet |
| /22  | 1,024     | 1,019      | Small subnet |
| /23  | 512       | 507        | Micro subnet |
| /24  | 256       | 251        | Tiny subnet |

## Planning Checklist

- [ ] Determine total number of environments (prod, staging, dev)
- [ ] Estimate maximum number of resources per environment
- [ ] Plan for growth (2-3x current needs)
- [ ] Avoid overlapping CIDR blocks between VPCs
- [ ] Consider VPC peering requirements
- [ ] Account for AWS reserved IPs (5 per subnet)
- [ ] Plan for future VPN or Direct Connect integration

## Common Patterns

### Pattern 1: Kubernetes/EKS Cluster
```hcl
# Large private subnets for pods
vpc_cidr                 = "10.0.0.0/16"
public_subnet_count      = 3
private_subnet_count     = 3
public_subnet_cidr_bits  = 6   # /22 = 1,024 IPs (load balancers)
private_subnet_cidr_bits = 3   # /19 = 8,192 IPs (pods + nodes)
```

### Pattern 2: Traditional Three-Tier App
```hcl
# Balanced subnets
vpc_cidr                 = "10.0.0.0/16"
public_subnet_count      = 3   # Load balancers
private_subnet_count     = 6   # 3 for app tier, 3 for DB tier
public_subnet_cidr_bits  = 8   # /24 = 256 IPs
private_subnet_cidr_bits = 8   # /24 = 256 IPs
```

### Pattern 3: Microservices Architecture
```hcl
# Many smaller subnets
vpc_cidr                 = "10.0.0.0/16"
public_subnet_count      = 3
private_subnet_count     = 12  # Multiple app layers
public_subnet_cidr_bits  = 8   # /24 = 256 IPs
private_subnet_cidr_bits = 8   # /24 = 256 IPs
```

## Tools

Use these online calculators to validate your CIDR planning:
- https://www.ipaddressguide.com/cidr
- https://cidr.xyz/
- https://www.subnet-calculator.com/

## Formula

The module uses this formula for subnet CIDR calculation:

```
Subnet CIDR = cidrsubnet(vpc_cidr, newbits, netnum)

Where:
- vpc_cidr: Your VPC CIDR block
- newbits: public_subnet_cidr_bits or private_subnet_cidr_bits
- netnum: Sequential number (0, 1, 2, 3...)

Example:
cidrsubnet("10.0.0.0/16", 4, 0) = "10.0.0.0/20"
cidrsubnet("10.0.0.0/16", 4, 1) = "10.0.16.0/20"
cidrsubnet("10.0.0.0/16", 4, 2) = "10.0.32.0/20"
```
