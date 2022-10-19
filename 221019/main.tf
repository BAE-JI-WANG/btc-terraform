# Provider
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

# Instances
resource "aws_instance" "web" {
  ami                         = var.ami # Amazon Linux 2 (us-east-2)
  instance_type               = var.instance_type
  user_data_replace_on_change = true

  user_data              = <<-EOF
        #!/bin/bash
        yum -y install httpd
        sed -i 's/Listen 80/Listen ${var.server_port_http}/' /etc/httpd/conf/httpd.conf
        systemctl enable httpd
        systemctl start httpd
        echo '<html><h1>Hello From Your Linux Web Server running on port ${var.server_port_http}</h1></html>' > /var/www/html/index.html
        EOF
  vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.ssh.id]
  tags = {
    "Name" = "tf-web"
  }
}

#Security groups
resource "aws_security_group" "http" {
  name        = var.security_group_name_http
  description = "Allow http inbound traffic"

  ingress {
    description = "http from VPC"
    from_port   = var.server_port_http
    to_port     = var.server_port_http
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

resource "aws_security_group" "ssh" {
  name        = var.security_group_name_ssh
  description = "Allow ssh inbound traffic"

  ingress {
    description = "http from VPC"
    from_port   = var.server_port_ssh
    to_port     = var.server_port_ssh
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

# Variables
variable "server_port_http" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "security_group_name_http" {
  description = "The name of the security group"
  type        = string
  default     = "allow_http"
}

variable "server_port_ssh" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 22
}

variable "security_group_name_ssh" {
  description = "The name of the security group"
  type        = string
  default     = "allow_ssh"
}

variable "ami" {
  type    = string
  default = "ami-0c76973fbe0ee100c"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Outputs
output "public_ip" {
  value       = "${aws_instance.web.public_ip}:${var.server_port_http}"
  description = "Webserver PIP"
}

output "private_ip" {
  value = aws_instance.web.private_ip
}

# Datas
data "template_file" "init" {
  template = file("userdata.sh")
  vars = {
    HTTP  = var.server_port_http
  }
}

