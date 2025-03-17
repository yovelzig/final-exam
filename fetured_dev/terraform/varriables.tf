variable "aws_region" {
  description = "The AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "owner_name" {
  description = "Owner identifier for resource naming"
  type        = string
  default     = "Yovel1"
}

variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC identifier for resources"
  type        = string
  default     = "vpc-044604d0bfb707142"
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.medium"
}
