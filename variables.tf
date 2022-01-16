#https://www.terraform.io/language/values/variables
###############################################################################
# Required variables
###############################################################################
variable "cd_app_name" {
  description = "(Required) Code Deploy application name."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.cd_app_name) > 0
    error_message = "Code Deploy application name."
  }
}

variable "cd_compute_platform" {
  description = "(Required) Code Deploy compute platform."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("Server|Lambda|ECS", var.cd_compute_platform))
    error_message = "You must put a valid Code Deploy compute platform (Server, Lambda or ECS)."
  }
}

variable "dg_service_role" {
  description = "(Required) Code Deploy service role arn."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("arn:aws:iam::[0-9]{12}:role[/][a-zA-Z0-9-_]*", var.dg_service_role))
    error_message = "You must put a valid Code Deploy service role (ex: arn:aws:iam::365101756910:role/dev-CodeDeloyServiceRole)."
  }
}

variable "dg_asg_name" {
  description = "(Required) Code Deploy Autoscaling group."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.dg_asg_name) > 0
    error_message = "Code Deploy Autoscaling group name is required."
  }
}

variable "dg_lb_tg_name" {
  description = "(Required) Code Deploy Load Balancer target group name."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.dg_lb_tg_name) > 0
    error_message = "Code Deploy Load Balancer target group name is required."
  }
}

variable "sns_email" {
  description = "(Required) SNS Topic Subscription email."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("[a-zA-Z0-9-_.+]*@[a-zA-Z0-9.]*[.]{1}[a-z]{3}", var.sns_email))
    error_message = "You must put a valid email address (ex: codedeploy_notifications@company.com)."
  }
}

###############################################################################
# Optional variables
###############################################################################
variable "tags" {
  description = "(Optional) List of policies arn"
  type        = any
  default     = {}
}
