variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "af-south-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must look like us-east-1 or af-south-1."
  }
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = null
  sensitive   = true
}

variable "aws_project_name" {
  description = "Name of project"
  type        = string
  default     = "aws-labs"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,35}[a-z0-9]$", var.aws_project_name))
    error_message = "Must be 3-37 chars, lowercase letters/digits/hyphens, starting and ending alphanumeric (S3 bucket_prefix limit)."
  }
}

variable "cors_rules" {
  description = "CORS rules for the lab bucket"

  type = list(object({
    id              = optional(string)
    allowed_methods = list(string)
    allowed_headers = optional(list(string), ["*"])
    allowed_origins = list(string)
    expose_headers  = optional(list(string), ["ETag"] )
    max_age_seconds = optional(number, 3000)
  }))

  default = [
    {
      id              = "browser_access",
      allowed_methods = ["GET", "HEAD", "POST"]
      allowed_origins = ["http://localhost:3000"]
    }
  ]

  validation {
    condition = alltrue([
      for rule in var.cors_rules : alltrue([
        for method in rule.allowed_methods :
        contains(["GET", "PUT", "POST", "DELETE", "HEAD"], method)
      ])
    ])
    error_message = "allowed_methods must be a subset of GET, PUT, POST, DELETE, HEAD."
  }

  validation {
    condition     = alltrue([for rule in var.cors_rules : length(rule.allowed_origins) > 0])
    error_message = "Each CORS rule needs at least one allowed origin."
  }

  validation {
    condition     = alltrue([for rule in var.cors_rules : rule.max_age_seconds >= 0])
    error_message = "max_age_seconds must be zero or positive."
  }

  validation {
    condition     = length(var.cors_rules) <= 100
    error_message = "AWS allows at most 100 CORS rules per bucket."
  }

  validation {
    condition = (
      length(distinct([for rule in var.cors_rules : rule.id if rule.id != null])) ==
      length([for rule in var.cors_rules : rule.id if rule.id != null])
    )
    error_message = "CORS rule ids must be unique."
  }
}
