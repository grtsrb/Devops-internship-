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

variable "priv_subnet_id" {
  description = "List of private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "priv_sg_id" {

}

variable "engine" {
  description = "Specify db's engine"
  type = string
  default = "postgres"
}
variable "instance_class" {
  description = "Specify db's instance class. Default: db.t3.micro"
  type = string
  default = "db.t3.micro"
}