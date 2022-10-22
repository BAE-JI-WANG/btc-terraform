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
# resource "aws_instance" "web" {
#   ami                         = var.ami # Amazon Linux 2 (us-east-2)
#   instance_type               = var.instance_type
#   user_data_replace_on_change = true

#   # user_data = data.template_file.userdata.rendered
#   user_data              = templatefile("userdata.tftpl", { HTTP = var.server_port_http })
#   vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.ssh.id]
#   tags = {
#     "Name" = "tf-web"
#   }
# }

#Security groups
resource "aws_security_group" "http" {
  name        = var.security_group_name_http
  description = "Allow http inbound traffic"

  # ingress {
  #   description = "http from VPC"
  #   from_port   = var.server_port_http
  #   to_port     = var.server_port_http
  #   protocol    = "tcp"
  #   # cidr_blocks = ["0.0.0.0/0"]
  #   source_security_group_id = aws_security_group.alb.id
  # }

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


resource "aws_security_group_rule" "http-rule" {
  type                     = "ingress"
  from_port                = var.server_port_http
  to_port                  = var.server_port_http
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.http.id
  description              = "Allow http(80) from ALB SG"
}

resource "aws_security_group" "alb" {
  name        = var.security_group_name_alb
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
    "Name" = "alb"
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
  default     = 8080
}

variable "security_group_name_http" {
  description = "The name of the security group"
  type        = string
  default     = "allow_http"
}

variable "security_group_name_alb" {
  description = "The name of the security group"
  type        = string
  default     = "alb"
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
  type = string
  # default = "ami-0c76973fbe0ee100c"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Outputs
# output "public_ip" {
#   value       = "${aws_instance.web.public_ip}:${var.server_port_http}"
#   description = "Webserver PIP"
# }

# output "private_ip" {
#   value = aws_instance.web.private_ip
# }

# Datas
# data "template_file" "userdata" {
#   template = file("userdata.tpl")
#   vars = {
#     HTTP  = var.server_port_http
#   }
# }

resource "aws_launch_configuration" "web" {
  name_prefix = "lc-web-"
  # image_id        = data.aws_ami.amazon_linux2.id
  image_id = coalesce(data.aws_ami.amazon_linux2.id, var.ami)
  # image_id        = var.ami == "" ? data.aws_ami.amazon_linux2.id : var.ami # 3항 연산자
  instance_type   = var.instance_type
  security_groups = [aws_security_group.http.id, aws_security_group.ssh.id]
  user_data       = templatefile("userdata.tftpl", { HTTP = var.server_port_http})
  key_name        = aws_key_pair.deployer.key_name

  lifecycle {
    create_before_destroy = true
  }
}

# data "aws_caller_identity" "current" {}

# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }

# output "caller_arn" {
#   value = data.aws_caller_identity.current.arn
# }

# output "caller_user" {
#   value = data.aws_caller_identity.current.user_id
# }

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name_prefix          = "asg-web-"
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  desired_capacity  = 4
  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "asg-web"
    propagate_at_launch = true
  }
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220912.1-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("terraform-key.pub")
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeM3vGaMHWgquJyC9AZWeJB5LEvvM9fNueqWRK1ros0DjSADKKFV59hqCekXxgjbSHpx+c3AkdXBvIj68dzoXvf+6Q16Lfqnk0bsm8yf5g/X0a0y+oB/E8u3qazZ95M4g/1bX7Lg9DpbA2xBpcK5+FCx9g+g42qBxrUe62jmdM3LEiA5J9PIbI9zLavJyK8yh9mwfsyswnJtBHfTwcGhl4bD3MgthVK1Z/2TJQlhCCoMvnNg0vTn4e+lrXvyvN23esKcimgR3DaymRtE9Q0lMoYzW1YrJBzRSH8Ea9Im6t0n/A8fXSFwOW+O8Z2dnBKpUM5mR4ewFmjjR3xdLOs3Y5 ec2-user@ip-172-31-11-193.ap-northeast-2.compute.internal"
}

variable "instance_security_group_name" {
  description = "The name of the security group for EC2 instance"
  type        = string
  default     = "allow_http_ssh_instance"
}

variable "alb_security_group_name" {
  description = "The name of the security group for ALB"
  type        = string
  default     = "allow_http_alb"
}

resource "aws_lb" "alb" {
  name_prefix        = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.http.id]
}

variable "alb_name" {
  type    = string
  default = "alb-"
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.server_port_http
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: 페이지가 안나온다!"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name_prefix = var.alb_name
  port        = var.server_port_http
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  
  lifecycle {
    create_before_destroy = true
  }
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}