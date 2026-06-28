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

variable "nasa_api_key" {
  description = "NASA API key for NeoWs"
  type        = string
  sensitive   = true
}

variable "aws_wrangler_ami" {
  description = "AMI image for awswrangler package to be used as a layer in lambda functions"
  type        = string
  default     = "arn:aws:lambda:eu-west-2:336392948345:layer:AWSSDKPandas-Python313:14"
}