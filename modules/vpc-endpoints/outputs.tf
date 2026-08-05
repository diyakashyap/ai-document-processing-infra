output "vpc_endpoint_security_group_id" {
  value = aws_security_group.vpc_endpoint.id
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "ecs_endpoint_id" {
  value = aws_vpc_endpoint.ecs.id
}

output "ecr_api_endpoint_id" {
  value = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  value = aws_vpc_endpoint.ecr_dkr.id
}