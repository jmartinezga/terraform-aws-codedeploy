#https://www.terraform.io/language/values/outputs
output "application_id" {
  description = "CodeDeploy Application id."
  value       = aws_codedeploy_app.this.application_id
}

output "arn" {
  description = "CodeDeploy arn."
  value       = aws_codedeploy_app.this.arn
}
