# Terraform CodeDeploy module

### Install dependencies

<!-- markdownlint-disable no-inline-html -->

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs)
* [`terragrunt`](https://terragrunt.gruntwork.io/docs/getting-started/install/)
* [`terrascan`](https://github.com/accurics/terrascan)
* [`TFLint`](https://github.com/terraform-linters/tflint)
* [`TFSec`](https://github.com/liamg/tfsec)
* [`infracost`](https://github.com/infracost/infracost)
* [`jq`](https://github.com/stedolan/jq)

### Install the pre-commit hook globally

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codedeploy_app.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_config) | resource |
| [aws_codedeploy_deployment_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.sns-topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | (Required) Application name | `string` | n/a | yes |
| <a name="input_cd_app_name"></a> [cd\_app\_name](#input\_cd\_app\_name) | (Required) Code Deploy application name. | `string` | n/a | yes |
| <a name="input_cd_compute_platform"></a> [cd\_compute\_platform](#input\_cd\_compute\_platform) | (Required) Code Deploy compute platform. | `string` | n/a | yes |
| <a name="input_dg_asg_name"></a> [dg\_asg\_name](#input\_dg\_asg\_name) | (Required) Code Deploy Autoscaling group. | `list(string)` | n/a | yes |
| <a name="input_dg_lb_tg_name"></a> [dg\_lb\_tg\_name](#input\_dg\_lb\_tg\_name) | (Required) Code Deploy Load Balancer target group name. | `string` | n/a | yes |
| <a name="input_dg_service_role"></a> [dg\_service\_role](#input\_dg\_service\_role) | (Required) Code Deploy service role arn. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Environment (dev, stg, prd) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS Region | `string` | n/a | yes |
| <a name="input_sns_email"></a> [sns\_email](#input\_sns\_email) | (Required) SNS Topic Subscription email. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) List of policies arn | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | CodeDeploy Application id. |
| <a name="output_arn"></a> [arn](#output\_arn) | CodeDeploy arn. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
