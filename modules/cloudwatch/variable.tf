variable "log_group_name" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 14
}

variable "common_tags" {
  type = map(string)
}
