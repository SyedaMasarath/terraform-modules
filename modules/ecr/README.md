# AWS ECR Module

Create one or more Elastic Container Registry repositories with image scanning, immutable tags, lifecycle policies, and optional cross-account pull access.

## Features

- Multiple repositories from a single module call
- IMMUTABLE image tags by default (prevents overwriting released images)
- Vulnerability scanning on every push
- KMS encryption support
- Lifecycle policies: expire untagged images and cap tagged image count
- Optional cross-account pull access via repository policy

## Usage

```hcl
module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "myapp/api",
    "myapp/worker",
    "myapp/frontend",
  ]

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  kms_key_arn          = module.eks.kms_key_arn

  untagged_expiry_days   = 7
  tagged_image_count     = 20
  lifecycle_tag_prefixes = ["v"]

  tags = {
    Environment = "production"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

### Cross-account pull (e.g. staging pulling from production ECR)

```hcl
module "ecr" {
  source           = "../../modules/ecr"
  repository_names = ["myapp/api"]
  allowed_account_ids = ["111122223333"] # staging account
  tags = { Environment = "production" }
}
```

### Pushing an image

```bash
# Authenticate
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS \
    --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag myapp/api:v1.2.3 \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp/api:v1.2.3

docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp/api:v1.2.3
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `repository_names` | list(string) | required | Repository names to create |
| `image_tag_mutability` | string | `"IMMUTABLE"` | `IMMUTABLE` (recommended) or `MUTABLE` |
| `scan_on_push` | bool | `true` | Run basic CVE scan on every push |
| `force_delete` | bool | `false` | Allow deletion of non-empty repos |
| `kms_key_arn` | string | `""` | KMS key for encryption (empty = AES256) |
| `untagged_expiry_days` | number | `7` | Days before untagged images are expired |
| `tagged_image_count` | number | `20` | Max tagged images retained per repo |
| `lifecycle_tag_prefixes` | list(string) | `["v"]` | Tag prefixes covered by retention rule |
| `allowed_account_ids` | list(string) | `[]` | Account IDs allowed cross-account pull |
| `tags` | map(string) | `{}` | Tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `repository_urls` | Map of name → repository URL |
| `repository_arns` | Map of name → repository ARN |
| `registry_id` | AWS account ID of the registry |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
