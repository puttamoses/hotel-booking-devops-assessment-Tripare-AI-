variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "ecs_desired_count" {
  type = number
}

variable "ecs_task_cpu" {
  type = number
}

variable "ecs_task_memory" {
  type = number
}

variable "db_host" {
  description = "RDS address the app container should connect to"
  type        = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
