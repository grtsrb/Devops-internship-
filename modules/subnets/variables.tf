variable "public_subnet_list" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))

  description = "List of public subnets with CIDR and AZ."
  default     = [{ cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a" }, { cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b" }]
}

variable "private_subnet_list" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))

  description = "List of private subnets with CIDR and AZ."
  default     = [{ cidr_block = "10.0.3.0/24", availability_zone = "us-east-1a" }, { cidr_block = "10.0.4.0/24", availability_zone = "us-east-1b" }]
}

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
variable "igw_id" {}
variable "priv_rt_id" {}
variable "pub_rt_id" {}