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

resource "aws_instance" "web2" {
  ami           = "ami-0c76973fbe0ee100c" # Amazon Linux 2 (us-east-2)
  instance_type = "t3.micro"

  user_data              = <<-EOF
        #!/bin/bash
        yum -y install httpd
        systemctl enable httpd
        systemctl start httpd
        echo '<html><h1>Hello From Your Linux Web Server!</h1></html>' > /var/www/html/index.html
        EOF
  vpc_security_group_ids = [aws_security_group.web.id]
  tags = {
    "Name" = "tf-web"
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