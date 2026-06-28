output "bucket_ids" {
  description = "List of IDs for the created S3 buckets."
  value       = aws_s3_bucket.this[*].id
}

output "bucket_arns" {
  description = "List of ARNs for the created S3 buckets."
  value       = aws_s3_bucket.this[*].arn
}

output "bucket_domain_names" {
  description = "List of S3 bucket domain names."
  value       = aws_s3_bucket.this[*].bucket_domain_name
}

output "bucket_regional_domain_names" {
  description = "List of regional S3 bucket domain names."
  value       = aws_s3_bucket.this[*].bucket_regional_domain_name
}

output "bucket_names" {
  description = "List of S3 bucket names created by the module."
  value       = local.bucket_names
}

output "public_access_blocked" {
  description = "Whether public access blocking is enabled for each bucket."
  value       = [for config in local.bucket_configs : config.block_public_access]
}
