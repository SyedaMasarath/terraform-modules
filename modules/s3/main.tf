resource "random_string" "suffix" {
  count   = length(var.buckets)
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  bucket_advanced_defaults = {
    acl                       = ""
    versioning_enabled        = true
    force_destroy             = false
    enable_default_encryption = true
    kms_key_id                = ""
    block_public_access       = null
    lifecycle_rules           = []
    replication = {
      enable   = false
      role_arn = ""
      rules    = []
    }
  }

  bucket_configs = [for bucket in var.buckets : {
    name                      = bucket.name
    name_suffix               = bucket.name_suffix
    is_public                 = bucket.is_public
    acl                       = length(trimspace(merge(local.bucket_advanced_defaults, bucket.advanced).acl)) > 0 ? merge(local.bucket_advanced_defaults, bucket.advanced).acl : (bucket.is_public ? "public-read" : "private")
    versioning_enabled        = merge(local.bucket_advanced_defaults, bucket.advanced).versioning_enabled
    force_destroy             = merge(local.bucket_advanced_defaults, bucket.advanced).force_destroy
    enable_default_encryption = merge(local.bucket_advanced_defaults, bucket.advanced).enable_default_encryption
    kms_key_id                = merge(local.bucket_advanced_defaults, bucket.advanced).kms_key_id
    encryption_algorithm      = merge(local.bucket_advanced_defaults, bucket.advanced).kms_key_id != "" ? "aws:kms" : "AES256"
    block_public_access       = merge(local.bucket_advanced_defaults, bucket.advanced).block_public_access != null ? merge(local.bucket_advanced_defaults, bucket.advanced).block_public_access : !bucket.is_public
    lifecycle_rules           = merge(local.bucket_advanced_defaults, bucket.advanced).lifecycle_rules
    enable_replication        = merge(local.bucket_advanced_defaults, bucket.advanced).replication.enable
    replication_role_arn      = merge(local.bucket_advanced_defaults, bucket.advanced).replication.role_arn
    replication_rules         = merge(local.bucket_advanced_defaults, bucket.advanced).replication.rules
    tags = merge(
      var.tags,
      bucket.tags,
      {
        Name = length(trimspace(bucket.name)) > 0 ? bucket.name : "${var.name_prefix}-${bucket.name_suffix}"
      }
    )
  }]

  bucket_names = [for idx, bucket in var.buckets : length(trimspace(bucket.name)) > 0 ? bucket.name : "${var.name_prefix}-${bucket.name_suffix}-${random_string.suffix[idx].result}"]
}

resource "aws_s3_bucket" "this" {
  count = length(var.buckets)

  bucket        = local.bucket_names[count.index]
  force_destroy = local.bucket_configs[count.index].force_destroy

  tags = local.bucket_configs[count.index].tags
}

resource "aws_s3_bucket_acl" "this" {
  count = length(var.buckets)

  bucket = aws_s3_bucket.this[count.index].id
  acl    = local.bucket_configs[count.index].acl

  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = length(var.buckets)
  bucket = aws_s3_bucket.this[count.index].id

  rule {
    object_ownership = local.bucket_configs[count.index].is_public ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = length(var.buckets)
  bucket = aws_s3_bucket.this[count.index].id

  versioning_configuration {
    status = local.bucket_configs[count.index].versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = { for idx, config in local.bucket_configs : idx => config if config.enable_default_encryption }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.encryption_algorithm
      kms_master_key_id = each.value.kms_key_id != "" ? each.value.kms_key_id : null
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for idx, config in local.bucket_configs : idx => config if length(config.lifecycle_rules) > 0 }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = { for rule in each.value.lifecycle_rules : rule.id => rule }
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = { for idx, config in local.bucket_configs : idx => config if config.block_public_access }

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_replication_configuration" "this" {
  for_each = { for idx, config in local.bucket_configs : idx => config if config.enable_replication }

  bucket = aws_s3_bucket.this[each.key].id
  role   = each.value.replication_role_arn

  dynamic "rule" {
    for_each = each.value.replication_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      destination {
        bucket        = rule.value.destination_bucket_arn
        storage_class = rule.value.storage_class
      }

      delete_marker_replication {
        status = rule.value.delete_marker_replication
      }
    }
  }
}
