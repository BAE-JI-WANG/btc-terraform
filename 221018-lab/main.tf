terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2" # Asia Pacific (Seoul) region
}

resource "aws_instance" "ssh-server" {
  ami           = "ami-07d16c043aa8e5153" # ubuntu (ap-northeast-2)
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = "tfkey"
  tags = {
    "Name" = "tf-ssh"
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
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
    "Name" = "ssh"
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name_prefix = "asg-web-"
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "asg-web"
    propagate_at_launch = true
  }
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220912.1-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  owners = [ "137112412989" ]
}