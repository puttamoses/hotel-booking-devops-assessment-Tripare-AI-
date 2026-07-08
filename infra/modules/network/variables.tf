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
  description = "Provision a NAT gateway for private-subnet internet access"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "App container port"
  type        = number
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "tags" {
  description = "Common tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}
