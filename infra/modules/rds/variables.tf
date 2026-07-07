variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "db_engine" {
  description = "Database engine: postgres or mysql"
  type        = string

  validation {
    condition     = contains(["postgres", "mysql"], var.db_engine)
    error_message = "db_engine must be either \"postgres\" or \"mysql\"."
  }
}

variable "db_engine_version" {
  description = "Major version only (e.g. \"16\"). RDS retires specific minor versions over time; auto_minor_version_upgrade handles patching."
  type        = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_backup_retention_period" {
  type = number
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_multi_az" {
  type = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}
