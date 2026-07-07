locals {
  name           = "${var.project_name}-${var.environment}"
  db_port        = var.db_engine == "postgres" ? 5432 : 3306
  db_engine_name = var.db_engine == "postgres" ? "postgres" : "mysql"

  tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.tags, { Name = "${local.name}-db-subnet-group" })
}

resource "aws_db_instance" "main" {
  identifier     = "${local.name}-db"
  engine         = local.db_engine_name
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 5
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = local.db_port

  auto_minor_version_upgrade = true

  # Private only: no public IP, reachable only from the ECS security group.
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:30-mon:05:30"

  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = !var.db_deletion_protection
  final_snapshot_identifier = var.db_deletion_protection ? "${local.name}-db-final-snapshot" : null

  tags = merge(local.tags, { Name = "${local.name}-db" })
}
