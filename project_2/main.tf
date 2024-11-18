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

# 1. Create a VPC

resource "aws_vpc" "my-vpc-assignment" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "my-vpc-assignment"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.my-vpc-assignment.id

  tags = {
    "Name" = "igaw" 
  }
}

# 3. Create Custom Route Table

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.my-vpc-assignment.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    "Name" = "terraform-custom-table" 
  }
}

# 4. Create a subnet

resource "aws_subnet" "tf-subnet" {
  vpc_id = aws_vpc.my-vpc-assignment.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "tf-custom-subnet" 
  }
}

# 5. Associate a subnet with route table

resource "aws_route_table_association" "subnet-route-table" {
  subnet_id = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.route-table.id 
}

resource "aws_security_group" "security-group" {
  vpc_id =  aws_vpc.my-vpc-assignment.id

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22 
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80 
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "allow_traffic"
  }
}

# 7. Create a network interface with an IP in the subnet that was created in step 4

resource "aws_network_interface" "net-interface" {
  subnet_id = aws_subnet.tf-subnet.id
  private_ips = ["10.0.1.50"] 
  security_groups = [aws_security_group.security-group.id]
}

# 8. Assign an elastic IP to the network interface created in 7

resource "aws_eip" "elastic-ip" {
  depends_on = [ aws_internet_gateway.internet-gateway ]
  domain = "vpc"
  network_interface = aws_network_interface.net-interface.id
  associate_with_private_ip = "10.0.1.50"
}

output "server_public_ip" {
    value = aws_eip.elastic-ip.public_ip    
}
# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "ubuntu-apache" {
  ami = "ami-012967cc5a8c9f891"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.net-interface.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y 
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo "your very first web server" > /var/www/html/index.html'
              EOF
  tags = {
    "Name" = "ubuntu"
  }
}