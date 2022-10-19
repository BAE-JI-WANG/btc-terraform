provider "aws" {
  region = "ap-northeast-2" # Asia Pacific (Seoul) region
}

resource "aws_instance" "windows" {
  ami                         = "ami-07a78805f204e6760" # windows server
  instance_type               = "t2.micro"
  user_data_replace_on_change = true
  user_data                   = file("webserver.ps1")
  vpc_security_group_ids      = [aws_security_group.web.id]

  tags = {
    "Name" = "tf-windows-web"
  }
}


resource "aws_security_group" "web" {
  name        = "allow_http"
  description = "Allow http inbound traffic"

  ingress {
    description = "http from VPC"
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
    "Name" = "web"
  }
}