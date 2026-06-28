variable "name_prefix" {
  description = "Name prefix used for generated bucket names and resource tags."
  type        = string
}

variable "buckets" {
  description = <<-EOT
    List of S3 bucket definitions to create.
    Each item may define whether the bucket is public or private.
    Advanced bucket settings are optional and grouped under `advanced`.
  EOT
  type = list(object({
    name        = optional(string, "")
    name_suffix = optional(string, "bucket")
    is_public   = optional(bool, false)
    tags        = optional(map(string), {})
    advanced = optional(object({
      acl                       = optional(string, "")
      versioning_enabled        = optional(bool, true)
      force_destroy             = optional(bool, false)
      enable_default_encryption = optional(bool, true)
      kms_key_id                = optional(string, "")
      block_public_access       = optional(bool, null)
      lifecycle_rules = optional(list(object({
        id      = string
        enabled = bool
        prefix  = optional(string, "")
        transitions = optional(list(object({
          days          = optional(number)
          storage_class = string
        })), [])
        expiration = optional(object({
          days = optional(number)
        }), null)
      })), [])
      replication = optional(object({
        enable   = optional(bool, false)
        role_arn = optional(string, "")
        rules = optional(list(object({
          id                        = string
          prefix                    = string
          status                    = string
          destination_bucket_arn    = string
          storage_class             = optional(string, "STANDARD")
          delete_marker_replication = optional(string, "Enabled")
        })), [])
        }), {
        enable   = false
        role_arn = ""
        rules    = []
      })
    }), {})
  }))
  default = []

  validation {
    condition     = length(var.buckets) > 0
    error_message = "At least one bucket definition is required."
  }

  validation {
    condition     = alltrue([for b in var.buckets : !b.advanced.replication.enable || length(trim(b.advanced.replication.role_arn)) > 0])
    error_message = "advanced.replication.role_arn must be set when advanced.replication.enable = true."
  }
}

variable "tags" {
  description = "Additional tags to apply to all S3 buckets."
  type        = map(string)
  default     = {}
}
