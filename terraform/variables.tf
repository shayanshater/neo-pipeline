variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "python_runtime" {
  description = "python runtime for lambda function"
  type        = string
  default     = "python3.13"
}