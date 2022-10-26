# # DB SG
# resource "aws_security_group" "db_sg" {
#   name        = "large-ap2-db-sg"
#   vpc_id      = aws_vpc.large_vpc.id
#   description = "Allow Mysql(3306) from WEB SG"

#   egress {
#     description = "HTTP from VPC"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     "Name" = "large-ap2-db-sg"
#   }
# }

# resource "aws_security_group_rule" "db_sg_rule" {
#   type                     = "ingress"
#   from_port                = var.mysql
#   to_port                  = var.mysql
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.web_sg.id
#   # cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.db_sg.id
#   description       = "Allow mysql(3306) from web"
# }

# AMI SG
resource "aws_security_group" "all_sg" {
  name        = "all-sg"
  vpc_id      = aws_vpc.large_vpc.id
  description = "Allow ssh,http from anywhere"

  egress {
    description = "HTTP from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from VPC"
    from_port   = var.http
    to_port     = var.http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from VPC"
    from_port   = var.ssh
    to_port     = var.ssh
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "large-ap2-db-sg"
  }
}

# # Web SG
# resource "aws_security_group" "web_sg" {
#   name        = var.web_sg_name
#   vpc_id      = aws_vpc.large_vpc.id
#   description = "Allow http(80) from ALB SG Allow ssh(22) from Bastion SG"

#   egress {
#     description = "HTTP from VPC"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     "Name" = "large-ap2-web-sg"
#   }
# }

# resource "aws_security_group_rule" "web_sg_rule_http" {
#   type                     = "ingress"
#   from_port                = var.http
#   to_port                  = var.http
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.alb_sg.id
#   #   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.web_sg.id
#   description       = "Allow http(80) from ALB SG"
# }


# # ALB Security Gruop
# resource "aws_security_group" "alb_sg" {
#   name        = var.alb_sg_name
#   vpc_id      = aws_vpc.large_vpc.id
#   description = "Allow http(80) from anywhere"

#   egress {
#     description = "HTTP from VPC"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     "Name" = "large-ap2-web-alb-sg"
#   }
# }

# resource "aws_security_group_rule" "alb-sg-rule" {
#   type              = "ingress"
#   from_port         = var.http
#   to_port           = var.http
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.alb_sg.id
#   description       = "Allow http(80) from anywhere"
# }