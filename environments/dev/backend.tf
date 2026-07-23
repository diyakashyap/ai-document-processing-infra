terraform {
  backend "s3" {
    bucket         = "ai-document-processing-tf-state-078287196644"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ai-document-processing-tf-lock"
    encrypt        = true
  }
}