# ----------------------------------------------------------------
# AWS SNS TO LAMBDA - OUTPUTS
# ----------------------------------------------------------------


output "sns_topic_name" {
  description = "Name of SNS Topic logging to CloudWatch Log."
  value       = var.sns_topic_name
}

output "sns_topic_arn" {
  description = "ARN of SNS Topic logging to CloudWatch Log."
  value       = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
}

output "lambda_name" {
  description = "Name assigned to Lambda Function."
  value       = var.lambda_func_name
}

output "lambda_arn" {
  description = "ARN of created Lambda Function."
  value       = var.lambda_publish_func ? aws_lambda_function.sns_lambda.qualified_arn : aws_lambda_function.sns_lambda.arn
}

output "lambda_version" {
  description = "Latest published version of Lambda Function."
  value       = aws_lambda_function.sns_lambda.version
}

output "lambda_last_modified" {
  description = "The date Lambda Function was last modified."
  value       = aws_lambda_function.sns_lambda.last_modified
}

output "lambda_iam_role_id" {
  description = "Lambda IAM Role ID."
  value       = aws_iam_role.iam_for_lambda_with_sns.id
}

output "lambda_iam_role_arn" {
  description = "Lambda IAM Role ARN."
  value       = aws_iam_role.iam_for_lambda_with_sns.arn
}

output "cloudwatch_event_rule_arn_console-access" {
  description = "ARN of CloudWatch Trigger for console-access Event created."
  value       = aws_cloudwatch_event_rule.console-access.arn
}

output "cloudwatch_event_rule_arn_c2-running-status" {
  description = "ARN of CloudWatch Trigger for ec2-running-status Event created."
  value       = aws_cloudwatch_event_rule.ec2-running-status.arn
}
