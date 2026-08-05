variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where Interface Endpoints will be created"
  type        = list(string)
}

variable "private_route_table_id" {
  description = "Private route table ID for Gateway Endpoint"
  type        = string
}

# variable "endpoint_security_group_id" {
#   description = "Security Group for Interface Endpoints"
#   type        = string
# }

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}