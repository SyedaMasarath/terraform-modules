# AWS S3 Bucket Module

This module creates one or more production-ready Amazon S3 buckets using a bucket list definition.
It supports private and public bucket creation, encryption, versioning, lifecycle rules, and optional replication.

## Features

- Create multiple S3 buckets from a single module invocation
- Support for public or private buckets using explicit bucket mapping
- Default encryption and optional KMS encryption
- Versioning enabled by default
- Configurable public access block on a per-bucket basis
- Lifecycle rules for cost optimization
- Optional bucket replication support
- Shared and bucket-specific tags

## Usage

```hcl
module "s3_buckets" {
  source      = "../terraform-modules/s3"
  name_prefix = "myapp"

  tags = {
    Environment = "production"
    Project     = "myapp"
  }

  buckets = [
    {
      name      = "myapp-private-assets"
      is_public = false
      tags = {
        BucketType = "private"
      }
      advanced = {
        block_public_access     = true
        versioning_enabled      = true
        force_destroy           = false
      }
    },
    {
      name_suffix = "public-assets"
      is_public   = true
      tags = {
        BucketType = "public"
      }
      advanced = {
        acl                   = "public-read"
        block_public_access   = false
      }
    }
  ]
}
```

## Inputs

- `name_prefix` - Required prefix used when generating bucket names.
- `tags` - Global tags applied to every bucket.
- `buckets` - Required list of bucket definitions.
  - `name` - Optional explicit bucket name.
  - `name_suffix` - Suffix used when auto-generating bucket names.
  - `is_public` - Whether the bucket should be public. Defaults to `false`.
  - `tags` - Additional bucket-specific tags.
  - `advanced` - Optional nested advanced bucket configuration.
    - `acl` - Optional ACL override. Defaults to `public-read` for public buckets or `private` for private buckets.
    - `versioning_enabled` - Enable versioning. Defaults to `true`.
    - `force_destroy` - Remove all objects when destroying the bucket. Defaults to `false`.
    - `enable_default_encryption` - Enable default encryption. Defaults to `true`.
    - `kms_key_id` - Optional KMS key ARN for SSE-KMS encryption.
    - `block_public_access` - Optional override for public access blocking. Defaults to `false` for public buckets and `true` for private buckets.
    - `lifecycle_rules` - Optional lifecycle rules.
    - `replication` - Optional replication configuration.
      - `enable` - Whether replication is enabled.
      - `role_arn` - IAM role ARN for replication.
      - `rules` - Replication rules.

## Outputs

- `bucket_ids` - IDs of the created S3 buckets.
- `bucket_arns` - ARNs of the created S3 buckets.
- `bucket_domain_names` - Domain names of the created S3 buckets.
- `bucket_regional_domain_names` - Regional domain names of the created S3 buckets.
- `bucket_names` - Names of the created buckets.
- `public_access_blocked` - Whether public access blocking is enabled per bucket.
