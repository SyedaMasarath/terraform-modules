# AWS RDS Aurora PostgreSQL Module

Production-grade Aurora PostgreSQL cluster with KMS encryption, enhanced monitoring, Performance Insights, automatic password rotation via Secrets Manager, and deletion protection.

## Features

- Aurora PostgreSQL cluster (multi-AZ by default)
- KMS-encrypted storage and Secrets Manager secret
- Auto-generated password stored in Secrets Manager with 30-day rotation
- Enhanced monitoring via CloudWatch
- Performance Insights enabled by default
- Deletion protection enabled by default
- Final snapshot on destroy

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  identifier    = "myapp-prod"
  database_name = "myapp"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.eks.kms_key_arn

  allowed_sg_ids = [module.eks.node_security_group_id]

  instance_class      = "db.r7g.large"
  instances           = 2
  deletion_protection = true

  tags = {
    Environment = "production"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

### Staging example (smaller, no deletion protection)

```hcl
module "rds" {
  source = "../../modules/rds"

  identifier    = "myapp-staging"
  database_name = "myapp"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.eks.kms_key_arn

  allowed_sg_ids = [module.eks.node_security_group_id]

  instance_class      = "db.t3.medium"
  instances           = 1
  deletion_protection = false

  tags = {
    Environment = "staging"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

## Accessing Credentials

The database password is never stored in plain Terraform state. Retrieve it from Secrets Manager:

```bash
aws secretsmanager get-secret-value \
  --secret-id myapp-prod-db-credentials \
  --query SecretString \
  --output text | jq .
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | string | required | Resource name prefix |
| `database_name` | string | required | Initial database name |
| `vpc_id` | string | required | VPC ID |
| `subnet_ids` | list(string) | required | Private subnets for the DB subnet group |
| `kms_key_arn` | string | required | KMS key ARN for Secrets Manager encryption |
| `allowed_sg_ids` | list(string) | `[]` | Security groups allowed to reach the DB |
| `engine_version` | string | `"15.4"` | Aurora PostgreSQL engine version |
| `instance_class` | string | `"db.r7g.large"` | DB instance class |
| `instances` | number | `2` | Number of Aurora instances |
| `deletion_protection` | bool | `true` | Enable deletion protection |
| `backup_retention_period` | number | `14` | Days to retain automated backups |
| `performance_insights_enabled` | bool | `true` | Enable Performance Insights |
| `monitoring_interval` | number | `60` | Enhanced monitoring interval (seconds) |
| `secret_rotation_days` | number | `30` | Password rotation frequency |
| `tags` | map(string) | `{}` | Tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `db_cluster_endpoint` | Primary writer endpoint |
| `db_reader_endpoint` | Reader endpoint for read replicas |
| `db_name` | Database name |
| `db_security_group_id` | Database security group ID |
| `db_credentials_secret_arn` | Secrets Manager ARN for credentials |
| `db_kms_key_id` | KMS key ID used for encryption |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
| random | >= 3.0 |
