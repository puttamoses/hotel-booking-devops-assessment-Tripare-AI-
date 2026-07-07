locals {
  db_port = var.db_engine == "postgres" ? 5432 : 3306
}

module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway

  container_port = var.container_port
  db_port        = local.db_port
}

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id

  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  db_backup_retention_period = var.db_backup_retention_period
  db_deletion_protection     = var.db_deletion_protection
  db_multi_az                = var.db_multi_az
}

module "ecs" {
  source = "../../modules/ecs"

  depends_on = [module.network]

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  private_subnet_ids = module.network.private_subnet_ids
  ecs_sg_id          = module.network.ecs_sg_id
  target_group_arn   = module.network.alb_target_group_arn

  container_image   = var.container_image
  container_port    = var.container_port
  ecs_desired_count = var.ecs_desired_count
  ecs_task_cpu      = var.ecs_task_cpu
  ecs_task_memory   = var.ecs_task_memory

  db_host = module.rds.address
  db_port = local.db_port
  db_name = var.db_name
}
