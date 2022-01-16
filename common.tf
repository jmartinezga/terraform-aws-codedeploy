###############################################################################
# Common variables
###############################################################################
variable "region" {
  description = "(Required) AWS Region"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("eu-west-1|us-east-1", var.region))
    error_message = "Region must be (eu-west-1, us-east-1)."
  }
}

variable "environment" {
  description = "(Required) Environment (dev, stg, prd)"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("dev|stg|prd", var.environment))
    error_message = "Environment must be (dev, stg, prd)."
  }
}

variable "application" {
  description = "(Required) Application name"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.application) > 0
    error_message = "Application name is required."
  }
}
