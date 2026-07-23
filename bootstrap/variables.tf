variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}
variable "project_name" {
  description = "The name of the project for resource naming"
  type        = string
  default     = "default"
}