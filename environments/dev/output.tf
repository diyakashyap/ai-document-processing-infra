output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "document_bucket_name" {
  value = module.s3.bucket_name
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
