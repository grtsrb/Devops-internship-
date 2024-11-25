
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

variable "pub_subnet_id" {
  
}

variable "pub_sg_id" {
  
}

variable "igw_id" {
  
}

variable "rds_instance" {
  
}

variable "db_hostname" {
  
}

variable "DATABASE_NAME" {
  description = "The name of the database"
  type        = string
}

variable "DATABASE_USERNAME" {
  description = "The username for the database"
  type        = string
}

variable "DATABASE_PASSWORD" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "DOCKER_USERNAME" {
  description = "Username for docker account"
  type = string
}

variable "DOCKER_PASSWORD" {
  description = "The password for docker account"
  type = string
  sensitive = true
}
