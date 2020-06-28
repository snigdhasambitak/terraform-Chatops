# terraform-aws-cloudwatch-to-sns-to-lambda


`terraform-aws-cloudwatch-to-sns-to-lambda` is a internal Terraform module to provision a SNS topic with Subscription that triggers a Lambda Function based on the cloudwatch events using targets. It can also create custom CloudWatch events.

## Terraform Module Features

This Module allows simple and rapid deployment

- Creates Lambda function, Lambda Layer, IAM Policies, Triggers, and Subscriptions
- Creates (or use existing) SNS Topic, CloudWatch Log Group and Log Group Stream
- Options:
  - Create CloudWatch Event for trigerring SNS
- Python function editable in repository and in Lambda UI
  - Python dependencies packages in Lambda Layers zip

## CloudWatch Logs to SNS Features

Pushes the alerts from cloudwatch for all the services to SNS as a target which inturn triggers the lambda function.

- Enhances the value of CloudWatch Logs by enabling easy entry creation from any service, function and script that can send SNS notifications
- Enables cloud-init, bootstraps and functions to easily write log entries to a centralized CloudWatch Log
- Simplifies troubleshooting of solutions with decentralized logic
  - scripts and functions spread across instances, Lambda and services
- Easily add instrumentation to scripts: `aws sns publish --topic-arn $TOPIC_ARN --message $LOG_ENTRY`
  - Use with IAM instance policy requires `--region $AWS_REGION` parameter


## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | Region where AWS resources are located | string | - | yes |
| sns_topic_name | Name of SNS Topic to be logged by Gateway | string | - | yes |


## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create_sns_topic | Create new SNS topic | string | `true` | no |
| lambda_func_name | Name for Lambda Function | string | dynamically calculated | no |
| lambda_description | Lambda Function Description | string | `Gets Triggered based on SNS` | no |
| lambda_tags | Mapping of Tags to assign to Lambda function | map | `{}` | no |
| lambda_publish_func | Publish Lambda Function | string | `false` | no |
| lambda_runtime | Lambda runtime for Function | string | `python3.7` | no |
| lambda_timeout | Function time-out (seconds) | string | `3` | no |
| lambda_mem_size | Function RAM assigned (MB) | string | `128` | no |
| create_cloudwatch_events | CloudWatch Trigger for console-access Event created | string | `false` | no |


## How to Run this module

Step 1: Clone this repo : "git clone https://main.gitlab.in.here.com/poit/cedm/mumbai-techops/terraform-chatops.git"

Step 2: Initialize the Terraform state:

$ terraform init

Step 3: Plan the Deployment

$ terraform plan -out chatops-tf

This will prompt for the following :

var.aws_region
  Region where AWS resources will be created.

  Enter a value:

  Enter your region : ex: 'us-east-2'

var.sns_topic_name
  Name of SNS Topic logging to CloudWatch Log.  

  Enter a value:

  Enter your SNS topic name : ex: 'SNS-LAMBDA'

Step 4: We can apply the plan now

$ terraform apply "chatops-tf"


## The resources that will be created

 # data.aws_iam_policy_document.sns_topic_policy will be read during apply
 # (config refers to values not yet known)
<= data "aws_iam_policy_document" "sns_topic_policy"  {
    + id   = (known after apply)
    + json = (known after apply)

    + statement {
        + actions   = [
            + "SNS:Publish",
          ]
        + effect    = "Allow"
        + resources = [
            + (known after apply),
          ]

        + principals {
            + identifiers = [
                + "events.amazonaws.com",
              ]
            + type        = "Service"
          }
      }
  }

# aws_cloudwatch_event_rule.console-access will be created
+ resource "aws_cloudwatch_event_rule" "console-access" {
    + arn           = (known after apply)
    + description   = "Capture each AWS Console Sign In"
    + event_pattern = jsonencode(
          {
            + detail-type = [
                + "AWS Console Sign In via CloudTrail",
              ]
          }
      )
    + id            = (known after apply)
    + is_enabled    = true
    + name          = "capture-aws-sign-in"
  }

# aws_cloudwatch_event_rule.ec2-running-status will be created
+ resource "aws_cloudwatch_event_rule" "ec2-running-status" {
    + arn           = (known after apply)
    + description   = "Capture each ec2 running status in the region"
    + event_pattern = jsonencode(
          {
            + detail      = {
                + state = [
                    + "running",
                  ]
              }
            + detail-type = [
                + "EC2 Instance State-change Notification",
              ]
            + source      = [
                + "aws.ec2",
              ]
          }
      )
    + id            = (known after apply)
    + is_enabled    = true
    + name          = "capture-ec2-running-status"
  }

# aws_cloudwatch_event_target.console-access will be created
+ resource "aws_cloudwatch_event_target" "console-access" {
    + arn       = (known after apply)
    + id        = (known after apply)
    + rule      = "capture-aws-sign-in"
    + target_id = "SendToSNS"
  }

# aws_cloudwatch_event_target.ec2-running-status will be created
+ resource "aws_cloudwatch_event_target" "ec2-running-status" {
    + arn       = (known after apply)
    + id        = (known after apply)
    + rule      = "capture-ec2-running-status"
    + target_id = "SendToSNS"
  }

# aws_iam_role.iam_for_lambda_with_sns will be created
+ resource "aws_iam_role" "iam_for_lambda_with_sns" {
    + arn                   = (known after apply)
    + assume_role_policy    = jsonencode(
          {
            + Statement = [
                + {
                    + Action    = "sts:AssumeRole"
                    + Effect    = "Allow"
                    + Principal = {
                        + Service = "lambda.amazonaws.com"
                      }
                    + Sid       = ""
                  },
              ]
            + Version   = "2012-10-17"
          }
      )
    + create_date           = (known after apply)
    + force_detach_policies = false
    + id                    = (known after apply)
    + max_session_duration  = 3600
    + name                  = "lambda-lambda_function-sns-lambda-tests"
    + path                  = "/"
    + unique_id             = (known after apply)
  }

# aws_iam_role_policy.lambda_cloudwatch_logs_polcy will be created
+ resource "aws_iam_role_policy" "lambda_cloudwatch_logs_polcy" {
    + id     = (known after apply)
    + name   = "lambda-lambda_function-policy-sns-lambda-tests"
    + policy = jsonencode(
          {
            + Statement = [
                + {
                    + Action   = [
                        + "logs:PutLogEvents",
                        + "logs:CreateLogStream",
                        + "logs:CreateLogGroup",
                      ]
                    + Effect   = "Allow"
                    + Resource = "*"
                    + Sid      = ""
                  },
              ]
            + Version   = "2012-10-17"
          }
      )
    + role   = (known after apply)
  }

# aws_lambda_function.sns_lambda will be created
+ resource "aws_lambda_function" "sns_lambda" {
    + arn                            = (known after apply)
    + description                    = "lambda function triggered from sns"
    + filename                       = "./lambda.zip"
    + function_name                  = "lambda_function"
    + handler                        = "lambda_function.lambda_handler"
    + id                             = (known after apply)
    + invoke_arn                     = (known after apply)
    + last_modified                  = (known after apply)
    + memory_size                    = 512
    + publish                        = false
    + qualified_arn                  = (known after apply)
    + reserved_concurrent_executions = -1
    + role                           = (known after apply)
    + runtime                        = "python3.7"
    + source_code_hash               = "MwznP/dsrRQYbK25UwBdTVdvJvkTShbWhMxRJ/OcI+Q="
    + source_code_size               = (known after apply)
    + timeout                        = 3
    + version                        = (known after apply)

    + tracing_config {
        + mode = (known after apply)
      }
  }

# aws_lambda_permission.lambda_with_sns will be created
+ resource "aws_lambda_permission" "lambda_with_sns" {
    + action        = "lambda:InvokeFunction"
    + function_name = "lambda_function"
    + id            = (known after apply)
    + principal     = "sns.amazonaws.com"
    + source_arn    = (known after apply)
    + statement_id  = "AllowExecutionFromSNS"
  }

# aws_sns_topic.sns_log_topic[0] will be created
+ resource "aws_sns_topic" "sns_log_topic" {
    + arn    = (known after apply)
    + id     = (known after apply)
    + name   = "sns-lambda-tests"
    + policy = (known after apply)
  }

# aws_sns_topic_policy.sns_topic_policy will be created
+ resource "aws_sns_topic_policy" "sns_topic_policy" {
    + arn    = (known after apply)
    + id     = (known after apply)
    + policy = (known after apply)
  }

# aws_sns_topic_subscription.lambda will be created
+ resource "aws_sns_topic_subscription" "lambda" {
    + arn                             = (known after apply)
    + confirmation_timeout_in_minutes = 1
    + endpoint                        = (known after apply)
    + endpoint_auto_confirms          = false
    + id                              = (known after apply)
    + protocol                        = "lambda"
    + raw_message_delivery            = false
    + topic_arn                       = (known after apply)
  }

Plan: 11 to add, 0 to change, 0 to destroy.
