output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "read_service_name" {
  value = aws_ecs_service.read.name
}

output "write_service_name" {
  value = aws_ecs_service.write.name
}
