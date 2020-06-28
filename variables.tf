# -----------------------------------------------------------------
# REQUIRED VARIABLES WITHOUT DEFAULT VALUES
# -----------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "Region where AWS resources will be created."
}

variable "sns_topic_name" {
  type        = string
  description = "Name of SNS Topic logging to CloudWatch Log."
}

# -----------------------------------------------------------------
# VARIABLES DEFINITIONS WITH DEFAULT VALUES
# -----------------------------------------------------------------

# SNS TOPIC, LOG GROUP, LOG STREAM

variable "create_sns_topic" {
  default     = true
  description = "Boolean flag that determines if SNS topic, 'sns_topic_name' is created. If 'false' it uses an existing topic of that name."
}


# LAMBDA FUNCTION

variable "lambda_func_name" {
  type        = string
  default     = "lambda_function"
  description = "Name to assign to Lambda Function."
}

variable "lambda_description" {
  type        = string
  default     = "SNS triggers Lambda Fucntion"
  description = "Description to assign to Lambda Function."
}

variable "lambda_publish_func" {
  default     = false
  description = "Boolean flag that determines if Lambda function is published as a version."
}

variable "create_warmer_event" {
  default     = false
  description = "Boolean flag that determines if a CloudWatch Trigger event is created to prevent Lambda function from suspending."
}

variable "lambda_timeout" {
  default     = 3
  description = "Number of seconds that the function can run before timing out. The AWS default is 3s and the maximum runtime is 5m"
}

variable "lambda_mem_size" {
  default     = 512
  description = "Amount of RAM (in MB) assigned to the function. The default (and minimum) is 128MB, and the maximum is 3008MB."
}

variable "lambda_runtime" {
  type        = string
  default     = "python3.7"
  description = "Lambda runtime to use for the function."
}

variable "lambda_tags" {
  description = "A mapping of tags to assign to Lambda Function."
  default     = {}
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = "DEV"
    Name    = "ChatOps Test"
    Owner   = "techopstest@here.com"
    Project = "Core Map Optimization"
    Team    = "CHATOPS_OPTIMIZATION"
    odin_app_id  = "XXXX"
  }
}
