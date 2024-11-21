
variable "region" {
  description = "AWS region"
  type = string
}

variable "env" {
  description = "Environment"
  type = string
}

variable "project" {
  description = "Project name or identifier"
  type = string
}

variable "vpc_id" {}

variable "server_port" {
  description = "Port of web application"
  type = number
  default = 8080
}

variable "postgresql_port" {
  description = "Port of web PostgreSQL RDS db"
  type = number
  default = 5432 
}