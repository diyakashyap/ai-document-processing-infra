module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  subnets      = var.subnets
  common_tags  = var.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.repository_name
  common_tags     = var.common_tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name       = var.document_bucket_name
  enable_versioning = var.enable_document_bucket_versioning
  common_tags       = var.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  document_bucket_arn = module.s3.bucket_arn
  common_tags         = var.common_tags
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  log_group_name    = "/ecs/${var.project_name}/${var.environment}/backend"
  retention_in_days = var.log_retention_in_days
  common_tags       = var.common_tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
  common_tags    = var.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  container_port        = var.container_port
  health_check_path     = var.health_check_path
  common_tags           = var.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  rds_security_group_id = module.security_groups.rds_security_group_id
  database_name         = var.database_name
  database_username     = var.database_username
  database_password     = var.database_password
  db_instance_class     = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  common_tags           = var.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  ecs_security_group_id     = module.security_groups.ecs_security_group_id
  ecs_instance_profile_name = module.iam.ecs_instance_profile_name
  task_execution_role_arn   = module.iam.ecs_task_execution_role_arn
  task_role_arn             = module.iam.ecs_task_role_arn
  container_image           = "${module.ecr.repository_url}:${var.image_tag}"
  container_port            = var.container_port
  log_group_name            = module.cloudwatch.log_group_name
  read_target_group_arn     = module.alb.read_target_group_arn
  write_target_group_arn    = module.alb.write_target_group_arn
  ec2_instance_type         = var.ec2_instance_type
  task_cpu                  = var.task_cpu
  task_memory               = var.task_memory
  common_tags               = var.common_tags

  environment_variables = [
    {
      name  = "AWS_REGION"
      value = var.aws_region
    },
    {
      name  = "DOCUMENT_BUCKET_NAME"
      value = module.s3.bucket_name
    },
    {
      name  = "DATABASE_HOST"
      value = module.rds.db_endpoint
    },
    {
      name  = "DATABASE_NAME"
      value = module.rds.db_name
    },
    {
      name  = "DATABASE_USERNAME"
      value = var.database_username
    }
  ]
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"
  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr                 = var.vpc_cidr

  private_subnet_ids       = module.vpc.private_app_subnet_ids
  private_route_table_id   = module.vpc.private_route_table_id

  common_tags = var.common_tags
}