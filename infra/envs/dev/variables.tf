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
  default = "dev"
}

variable "skip_aws_account_lookup" {
  description = "Set true in CI to plan without real AWS credentials"
  type        = bool
  default     = false
}

# --- Networking ---

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
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
  description = "Number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_task_cpu" {
  type    = number
  default = 256
}

variable "ecs_task_memory" {
  type    = number
  default = 512
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
  description = "dev: smallest burstable instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
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
  description = "Set via TF_VAR_db_password"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 3
}

variable "db_deletion_protection" {
  description = "dev: off, so the environment can be torn down freely"
  type        = bool
  default     = false
}

variable "db_multi_az" {
  description = "dev: single AZ, HA not needed"
  type        = bool
  default     = false
}
