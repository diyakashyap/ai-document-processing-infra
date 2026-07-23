variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "document_bucket_arn" {
  type    = string
  default = null
}

variable "common_tags" {
  type = map(string)
}
