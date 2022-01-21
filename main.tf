#https://registry.terraform.io/providers/hashicorp/aws/latest/docs
locals {
  cd_name        = "${var.environment}-${var.cd_app_name}"
  dc_name        = "${var.environment}-${var.cd_app_name}-dc"
  dg_name        = "${var.environment}-${var.cd_app_name}-dg"
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
resource "aws_codedeploy_deployment_config" "this" {
  deployment_config_name = local.dc_name

  minimum_healthy_hosts {
    type  = "FLEET_PERCENT"
    value = 50
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group
resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = local.dg_name
  service_role_arn       = var.dg_service_role
  deployment_config_name = aws_codedeploy_deployment_config.this.id
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
