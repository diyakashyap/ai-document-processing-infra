variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "subnets" {
  type = map(object({
    cidr   = string
    az     = string
    public = bool
  }))
}
 