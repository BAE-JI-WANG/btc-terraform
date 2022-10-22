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
  region  = "ap-northeast-2" # Asia Pacific (Seoul) region
  profile = "mfa"
}

# Instances
resource "aws_instance" "web" {
  ami                         = var.ami # Amazon Linux 2 (us-east-2)
  instance_type               = var.instance_type
  user_data_replace_on_change = true
  
  # user_data = data.template_file.userdata.rendered
  user_data              = templatefile("userdata.tftpl", { HTTP = var.server_port_http })
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
  default = "ami-07d16c043aa8e5153"
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
# data "template_file" "userdata" {
#   template = file("userdata.tpl")
#   vars = {
#     HTTP  = var.server_port_http
#   }
# }


