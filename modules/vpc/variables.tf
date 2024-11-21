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

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "igw_rt" {
  default = "0.0.0.0/0"
}