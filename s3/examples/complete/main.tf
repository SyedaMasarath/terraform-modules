terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region                      = "us-west-2"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

module "app_buckets" {
  source      = "../../"
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
        versioning_enabled  = true
        force_destroy       = false
        block_public_access = true
      }
    },
    {
      name_suffix = "public-assets"
      is_public   = true
      tags = {
        BucketType = "public"
      }
      advanced = {
        acl                 = "public-read"
        block_public_access = false
      }
    }
  ]
}
