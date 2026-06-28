variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  validation {
    condition     = length(var.repository_names) > 0
    error_message = "At least one repository name is required."
  }
}

variable "image_tag_mutability" {
  description = "Tag mutability setting: MUTABLE allows overwriting tags, IMMUTABLE prevents it (recommended for production)"
  type        = string
  default     = "IMMUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable basic vulnerability scanning on every image push"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow deleting the repository even if it contains images — set false in production"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for repository encryption. Leave empty to use AES256 (AWS-managed)."
  type        = string
  default     = ""
}

variable "untagged_expiry_days" {
  description = "Number of days after which untagged images are expired"
  type        = number
  default     = 7
}

variable "tagged_image_count" {
  description = "Maximum number of tagged images to retain per repository (oldest are expired first)"
  type        = number
  default     = 20
}

variable "lifecycle_tag_prefixes" {
  description = "Image tag prefixes covered by the tagged-image retention rule"
  type        = list(string)
  default     = ["v"]
}

variable "allowed_account_ids" {
  description = "AWS account IDs allowed to pull images cross-account. Empty list disables cross-account access."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
