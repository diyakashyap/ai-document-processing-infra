variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
  //default = "us-east-1"
}

variable "subnets" {
  type = map(object({
    cidr   = string
    az     = string
    public = bool
  }))
}

variable "repository_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "document_bucket_name" {
  type = string
}

variable "enable_document_bucket_versioning" {
  type    = bool
  default = false
}

variable "log_retention_in_days" {
  type    = number
  default = 14
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}
