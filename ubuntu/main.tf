provider "aws" {
  region = "ap-northeast-2" # Asia Pacific (Seoul) region
}

resource "aws_instance" "ubuntu" {
  ami                         = "ami-07d16c043aa8e5153" # Ubuntu
  instance_type               = "t2.micro"
  user_data_replace_on_change = true
  user_data                   = file("user_data.sh")
  vpc_security_group_ids      = [aws_security_group.web.id]

  tags = {
    "Name" = "tf-ubuntu-web"
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