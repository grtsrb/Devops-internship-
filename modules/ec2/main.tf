
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
      DATABASE_NAME     = "${var.db_name}"
      DATABASE_PORT     = "${var.db_port}"
      DATABASE_USERNAME = "${var.db_username}"
      DATABASE_PASSWORD = "nikola1234"
      SECRET_KEY        = "j9dWpR53dxAM33ewDh4J4wFCMi52jY5BzXUlrFa5W/4"
      ALGORITHM         = "HS256"
      DOCKER_USERNAME   = "${var.docker_username}"
      DOCKER_PASSWORD   = "${var.docker_password}"
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