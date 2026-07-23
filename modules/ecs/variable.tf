variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecs_instance_profile_name" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "log_group_name" {
  type = string
}

variable "read_target_group_arn" {
  type = string
}

variable "write_target_group_arn" {
  type = string
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

variable "read_min_size" {
  type    = number
  default = 1
}

variable "read_max_size" {
  type    = number
  default = 1
}

variable "read_desired_capacity" {
  type    = number
  default = 1
}

variable "write_min_size" {
  type    = number
  default = 1
}

variable "write_max_size" {
  type    = number
  default = 1
}

variable "write_desired_capacity" {
  type    = number
  default = 1
}

variable "read_service_desired_count" {
  type    = number
  default = 1
}

variable "write_service_desired_count" {
  type    = number
  default = 1
}

variable "enable_container_insights" {
  type    = bool
  default = false
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "common_tags" {
  type = map(string)
}
