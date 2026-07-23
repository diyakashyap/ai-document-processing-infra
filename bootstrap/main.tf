resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-tf-state-078287196644"

  tags = {
    Name        = "${var.project_name}-tf-state-078287196644"
    environment = "shared"
  }
}
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.project_name}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-tf-locks"
    Environment = "shared"
  }
}