variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "hotel-booking"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "skip_aws_account_lookup" {
  description = "Set true in CI to plan without real AWS credentials"
  type        = bool
  default     = false
}

# --- Networking ---

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.10.0/24", "10.1.11.0/24"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

# --- ALB / ECS ---

variable "container_image" {
  type    = string
  default = "nginx:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "ecs_desired_count" {
  description = "prod: 2 tasks across AZs for availability"
  type        = number
  default     = 2
}

variable "ecs_task_cpu" {
  type    = number
  default = 512
}

variable "ecs_task_memory" {
  type    = number
  default = 1024
}

# --- RDS ---

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "16"
}

variable "db_instance_class" {
  description = "prod: larger instance class than dev"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  type    = number
  default = 100
}

variable "db_name" {
  type    = string
  default = "hotel_bookings"
}

variable "db_username" {
  type    = string
  default = "app_admin"
}

variable "db_password" {
  description = "Master DB password. Supply via TF_VAR_db_password -- never commit a real value."
  type        = string
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "prod: longer retention for real recovery scenarios"
  type        = number
  default     = 14
}

variable "db_deletion_protection" {
  description = "prod: on, guards against accidental terraform destroy"
  type        = bool
  default     = true
}

variable "db_multi_az" {
  description = "prod: multi-AZ for HA/failover"
  type        = bool
  default     = true
}
