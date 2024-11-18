terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key 
}

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "my-vpc" 
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "public-subnet-1"
  }
}
resource "aws_instance" "my-first-server" {
  ami = "ami-012967cc5a8c9f891"
  instance_type = "t2.micro"
  tags = {
    "Name" = "ubuntu"
  }
}