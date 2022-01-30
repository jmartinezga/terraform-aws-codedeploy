#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs
locals {
  account_id     = data.aws_caller_identity.current.account_id
  cd_name        = "${var.environment}-${var.cd_app_name}"
  module_version = trimspace(chomp(file("./version")))
  last_update    = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  tags = merge(var.tags, {
    environment    = "${var.environment}",
    application    = "${var.application}",
    module_name    = "terraform-aws-codedeploy",
    module_version = "${local.module_version}",
    last_update    = "${local.last_update}"
  })
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#tfsec:ignore:AWS002
resource "aws_s3_bucket" "this" {
  bucket = "codedeploy-${var.cd_app_name}-${local.account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = local.tags
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
#tfsec:ignore:AWS016
resource "aws_sns_topic" "this" {
  name = "codeDeploy_notification"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app
resource "aws_codedeploy_app" "this" {
  compute_platform = var.cd_compute_platform
  name             = local.cd_name

  tags = local.tags
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_config
resource "aws_codedeploy_deployment_config" "blue_green" {
  deployment_config_name = "${local.cd_name}-blue_green"
  compute_platform       = "Server"
  minimum_healthy_hosts {
    type  = "FLEET_PERCENT"
    value = 50
  }
}

resource "aws_codedeploy_deployment_config" "in_place" {
  deployment_config_name = "${local.cd_name}-in_place"
  compute_platform       = "Server"
  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group
resource "aws_codedeploy_deployment_group" "blue_green" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = "${local.cd_name}-blue_green"
  service_role_arn       = var.dg_service_role
  deployment_config_name = aws_codedeploy_deployment_config.blue_green.id
  autoscaling_groups     = var.dg_asg_name

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = var.dg_lb_tg_name
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 5
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure", "DeploymentStop"]
    trigger_name       = "event-trigger"
    trigger_target_arn = aws_sns_topic.this.arn
  }
}

resource "aws_codedeploy_deployment_group" "in_place" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = "${local.cd_name}-in_place"
  service_role_arn       = var.dg_service_role
  deployment_config_name = aws_codedeploy_deployment_config.in_place.id
  autoscaling_groups     = var.dg_asg_name

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = var.dg_lb_tg_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure", "DeploymentStop"]
    trigger_name       = "event-trigger"
    trigger_target_arn = aws_sns_topic.this.arn
  }
}
