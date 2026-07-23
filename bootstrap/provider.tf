terraform {
  required_version = ">=1.6"
  required_providers { //it downloads the AWS provider plugin.
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"

    }
  }
}

provider "aws" {
  region = var.aws_region
}