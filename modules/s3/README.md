# AWS S3 Bucket Module

Create one or more production-ready S3 buckets from a single module invocation. Supports encryption, versioning, lifecycle rules, public access blocking, and cross-region replication.

## Features

- Multiple buckets from a single call
- AES256 or KMS encryption per bucket
- Versioning enabled by default
- Public access block enforced on private buckets
- Lifecycle rules for tiered storage and cost optimization
- Optional cross-region replication

## Usage

```hcl
module "s3" {
  source      = "../../modules/s3"
  name_prefix = "myapp-prod"

  tags = {
    Environment = "production"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }

  buckets = [
    {
      name      = "myapp-prod-assets"
      is_public = false
      advanced = {
        versioning_enabled  = true
        force_destroy       = false
        block_public_access = true
        lifecycle_rules = [
          {
            id      = "transition-to-ia"
            enabled = true
            transitions = [
              { days = 90,  storage_class = "STANDARD_IA" },
              { days = 365, storage_class = "GLACIER" }
            ]
          }
        ]
      }
    },
    {
      name_suffix = "logs"
      is_public   = false
      advanced = {
        versioning_enabled = false
        lifecycle_rules = [
          {
            id         = "expire-logs"
            enabled    = true
            expiration = { days = 90 }
          }
        ]
      }
    }
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name_prefix` | string | required | Prefix for auto-generated bucket names |
| `buckets` | list(object) | required | List of bucket definitions (see schema below) |
| `tags` | map(string) | {} | Tags applied to all buckets |

### Bucket object schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | `""` | Explicit bucket name (overrides name_suffix) |
| `name_suffix` | string | `"bucket"` | Suffix for auto-generated name |
| `is_public` | bool | `false` | Allow public read access |
| `tags` | map(string) | `{}` | Bucket-specific tags |
| `advanced.versioning_enabled` | bool | `true` | Enable versioning |
| `advanced.force_destroy` | bool | `false` | Destroy non-empty bucket |
| `advanced.enable_default_encryption` | bool | `true` | Enable SSE |
| `advanced.kms_key_id` | string | `""` | KMS key ARN for SSE-KMS |
| `advanced.block_public_access` | bool | auto | Override public access block |
| `advanced.lifecycle_rules` | list | `[]` | Lifecycle rules |
| `advanced.replication` | object | disabled | Cross-region replication config |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_ids` | Bucket IDs |
| `bucket_arns` | Bucket ARNs |
| `bucket_names` | Bucket names |
| `bucket_regional_domain_names` | Regional domain names |
| `public_access_blocked` | Public access block status per bucket |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
| random | >= 3.0 |
