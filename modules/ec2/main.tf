
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
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.pub_subnet_id 
  vpc_security_group_ids = [var.pub_sg_id]
  key_name               = "main"

  user_data = templatefile("${path.module}/user_data/script.sh",
    {
      DATABASE_HOSTNAME = "${var.db_hostname}"
      DATABASE_NAME     = "${var.DATABASE_NAME}"
      DATABASE_PORT     = "${var.DATABASE_PORT}"
      DATABASE_USERNAME = "${var.DATABASE_USERNAME}"
      DATABASE_PASSWORD = "${var.DATABASE_PASSWORD}" 
      SECRET_KEY        = "${var.DATABASE_SECRET_KEY}"
      ALGORITHM         = "HS256"
      DOCKER_USERNAME   = "${var.DOCKER_USERNAME}"
      DOCKER_PASSWORD   = "${var.DOCKER_PASSWORD}"
  })

  depends_on = [var.rds_instance]

  tags = {
    Name = "ec2-instance-${var.region}a-${var.env}-${var.project}"
  }
}

resource "aws_eip" "ec2-elastic-ip" {
  instance   = aws_instance.web.id
  domain     = "vpc"
  depends_on = [var.igw_id]
}