terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
## Variables: 
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "docker_username" {}
variable "docker_password" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

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

resource "aws_vpc" "vpc_python" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "vpc-us-east-1-t-python-web"
  }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.vpc_python.id

  tags = {
    "Name" = "igw-us-east-1-t-python-web"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_python.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    "Name" = "public-route-table-us-east-1-t-python-web"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_list)
  vpc_id            = aws_vpc.vpc_python.id
  cidr_block        = var.public_subnet_list[count.index].cidr_block
  availability_zone = var.public_subnet_list[count.index].availability_zone

  tags = {
    "Name" = "public-subnet-${count.index + 1}-${var.public_subnet_list[count.index].availability_zone}-t-python-web"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  count          = length(var.public_subnet_list)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_python.id

  tags = {
    "Name" = "private-route-table-us-east-1-t-python-web"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_list)
  vpc_id            = aws_vpc.vpc_python.id
  cidr_block        = var.private_subnet_list[count.index].cidr_block
  availability_zone = var.private_subnet_list[count.index].availability_zone

  tags = {
    "Name" = "private-subnet-${count.index + 1}-${var.private_subnet_list[count.index].availability_zone}-t-python-web"
  }
}

resource "aws_route_table_association" "private-subnet-route-table-association" {
  count          = length(var.private_subnet_list)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    "Name" = "rds-subnet-group"
  }
}

resource "aws_security_group" "public_security_group" {
  vpc_id = aws_vpc.vpc_python.id
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "python-server"
    from_port   = 8080 
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "sec-grp-allow-traffic-us-east-1-t-python-web"
  }
}

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.vpc_python.id

  ingress {
    description = "PostgresSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [ aws_security_group.public_security_group.id ]
  }

  egress {
    description = "Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "sec-grp-allow-traffic-us-east-1-t-python-web"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [ aws_security_group.public_security_group.id ]
  key_name      = "main"

  user_data =  templatefile("${path.module}/user_data/script.sh", 
    {
      DATABASE_HOSTNAME = "${aws_db_instance.rds-database.address}"
      DATABASE_NAME = "${aws_db_instance.rds-database.db_name}"
      DATABASE_PORT = "${aws_db_instance.rds-database.port}"
      DATABASE_USERNAME = "${aws_db_instance.rds-database.username}" 
      DATABASE_PASSWORD = "nikola1234"
      SECRET_KEY = "j9dWpR53dxAM33ewDh4J4wFCMi52jY5BzXUlrFa5W/4"
      ALGORITHM = "HS256"
      DOCKER_USERNAME = "${var.docker_username}"
      DOCKER_PASSWORD = "${var.docker_password}"
  }) 

  depends_on = [ aws_db_instance.rds-database ]

  tags = {
    Name = "ec2-instance-us-east-1a-python-web"
  }
}

resource "aws_eip" "ec2-elastic-ip" {
  instance = aws_instance.web.id
  domain   = "vpc"
  depends_on = [ aws_internet_gateway.app_igw ]
}

resource "aws_db_instance" "rds-database" {
  allocated_storage    = 10
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  db_name              = "postgres"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = "nikola"
  password             = "nikola1234"
  vpc_security_group_ids = [ aws_security_group.private_security_group.id ]
  skip_final_snapshot = true
}