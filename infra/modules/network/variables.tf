variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to provision a NAT gateway so ECS tasks in private subnets can reach the internet"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Port the application container listens on (used for the ALB target group + ecs-sg ingress rule)"
  type        = number
}

variable "db_port" {
  description = "Port the database listens on (used for the rds-sg ingress rule)"
  type        = number
}

variable "tags" {
  description = "Common tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}
