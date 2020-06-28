# -----------------------------------------------------------------
# CREATE AWS SNS TO LAMBDA
# -----------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = var.aws_region
  version = ">= 2.12"
}

# create if specified
resource "aws_sns_topic" "sns_log_topic" {
  count = var.create_sns_topic ? 1 : 0
  name  = var.sns_topic_name
  tags = local.common_tags
}

# retrieve topic if not created, arn referenced
data "aws_sns_topic" "sns_log_topic" {
  count = var.create_sns_topic ? 0 : 1
  name  = var.sns_topic_name
}

# -----------------------------------------------------------------
# CREATE LAMBDA FUNCTION USING ZIP FILE
# -----------------------------------------------------------------

# make zip
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/function/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

# create lambda using function

resource "aws_lambda_function" "sns_lambda" {

  function_name = "${var.lambda_func_name}"
  description = "lambda function triggered from sns"
  filename      = "${path.module}/lambda.zip"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  publish = var.lambda_publish_func ? true : false
  role    = aws_iam_role.iam_for_lambda_with_sns.arn
  runtime     = var.lambda_runtime
  handler     = "lambda_function.lambda_handler"
  timeout     = var.lambda_timeout
  memory_size = var.lambda_mem_size
  tags = local.common_tags

}

# -----------------------------------------------------------------
# SUBSCRIBE LAMBDA FUNCTION TO SNS TOPIC
# -----------------------------------------------------------------

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  protocol  = "lambda"
  endpoint  = var.lambda_publish_func ? aws_lambda_function.sns_lambda.qualified_arn : aws_lambda_function.sns_lambda.arn
}

# -----------------------------------------------------------------
# ENABLE SNS TOPIC AS LAMBDA FUNCTION TRIGGER
# -----------------------------------------------------------------

resource "aws_lambda_permission" "lambda_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  qualifier     = var.lambda_publish_func ? aws_lambda_function.sns_lambda.version : null
}


# -------------------------------------------------------------------------------------
# CREATE IAM ROLE AND POLICIES FOR LAMBDA FUNCTION
# -------------------------------------------------------------------------------------

# Create IAM role
resource "aws_iam_role" "iam_for_lambda_with_sns" {
  name               = "lambda-${lower(var.lambda_func_name)}-${var.sns_topic_name}"
  assume_role_policy = data.aws_iam_policy_document.iam_for_lambda_with_sns.json
  tags = local.common_tags
}

# Add base Lambda Execution policy
resource "aws_iam_role_policy" "lambda_cloudwatch_logs_polcy" {
  name   = "lambda-${lower(var.lambda_func_name)}-policy-${var.sns_topic_name}"
  role   = aws_iam_role.iam_for_lambda_with_sns.id
  policy = data.aws_iam_policy_document.lambda_cloudwatch_logs_policy.json
}

# JSON POLICY - assume role
data "aws_iam_policy_document" "iam_for_lambda_with_sns" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# JSON POLICY - base Lambda Execution policy
data "aws_iam_policy_document" "lambda_cloudwatch_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:DeleteLogStream",
      "logs:DeleteLogGroup"
    ]

    resources = ["*"]
  }
}

# Cloudwatch event rule to capture console sign in

resource "aws_cloudwatch_event_rule" "console-access" {
  name        = "capture-aws-sign-in"
  tags = local.common_tags
  description = "Capture each AWS Console Sign In"

  event_pattern = <<PATTERN
{
  "detail-type": [
    "AWS Console Sign In via CloudTrail"
  ]
}
PATTERN
}

# Cloudwatch target for console sign in

resource "aws_cloudwatch_event_target" "console-access" {
  rule      = "${aws_cloudwatch_event_rule.console-access.name}"
  target_id = "SendToSNS"
  arn       = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
}

# Cloudwatch event rule to capture ec2-running status

resource "aws_cloudwatch_event_rule" "ec2-running-status" {
  name        = "capture-ec2-running-status"
  tags = local.common_tags
  description = "Capture each ec2 running status in the region"

  event_pattern = <<PATTERN
{
  "source": [ "aws.ec2" ],
  "detail-type": [ "EC2 Instance State-change Notification" ],
  "detail": {
    "state": [ "running" ]
    }
}
PATTERN
}

# Cloudwatch target for ec2-running status

resource "aws_cloudwatch_event_target" "ec2-running-status" {
  rule      = "${aws_cloudwatch_event_rule.ec2-running-status.name}"
  target_id = "SendToSNS"
  arn       = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
}

# Cloudwatch event rule to capture ec2-terminated status

resource "aws_cloudwatch_event_rule" "ec2-terminated-status" {
  name        = "capture-ec2-terminated-status"
  tags = local.common_tags
  description = "Capture each ec2 terminated status in the region"

  event_pattern = <<PATTERN
{
  "source": [ "aws.ec2" ],
  "detail-type": [ "EC2 Instance State-change Notification" ],
  "detail": {
    "state": [ "terminated" ]
    }
}
PATTERN
}

# Cloudwatch target for ec2-terminated status

resource "aws_cloudwatch_event_target" "ec2-terminated-status" {
  rule      = "${aws_cloudwatch_event_rule.ec2-terminated-status.name}"
  target_id = "SendToSNS"
  arn       = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
}


resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn]
  }
}
