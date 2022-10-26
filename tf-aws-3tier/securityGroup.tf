# ALB Security Gruop
resource "aws_security_group" "awesome-ap2-web-alb-sg" {
  name        = "awesome-ap2-web-alb-sg"
  vpc_id      = aws_vpc.awesome-vpc.id
  description = "Allow http(80) from anywhere"

  egress {
    description = "HTTP from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "awesome-ap2-web-alb-sg"
  }
}

resource "aws_security_group_rule" "awesome-ap2-web-alb-sg-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awesome-ap2-web-alb-sg.id
  description       = "Allow http(80) from anywhere"
}

resource "aws_security_group_rule" "awesome-ap2-web-alb-sg-rule-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awesome-ap2-web-alb-sg.id
  description       = "Allow https(443) from anywhere"
}

# Bastion Security Gruop
resource "aws_security_group" "awesome-ap2-bastion-sg" {
  name        = "awesome-ap2-bastion-sg"
  vpc_id      = aws_vpc.awesome-vpc.id
  description = "Allow ssh(22) from MyIP"

  egress {
    description = "HTTP from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "awesome-ap2-bastion-sg"
  }
}

resource "aws_security_group_rule" "awesome-ap2-bastion-sg-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awesome-ap2-bastion-sg.id
  description       = "Allow ssh(22) from MyIP"
}

# Web Security Gruop
resource "aws_security_group" "awesome-ap2-web-sg" {
  name        = "awesome-ap2-web-sg"
  vpc_id      = aws_vpc.awesome-vpc.id
  description = "Allow http(80) from ALB SG Allow ssh(22) from Bastion SG"

  egress {
    description = "HTTP from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "awesome-ap2-web-sg"
  }
}

resource "aws_security_group_rule" "awesome-ap2-web-sg-rule-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.awesome-ap2-bastion-sg.id
  security_group_id        = aws_security_group.awesome-ap2-web-sg.id
  description              = "Allow ssh(22) from Bastion SG"
}

resource "aws_security_group_rule" "awesome-ap2-web-sg-rule-http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.awesome-ap2-web-alb-sg.id
  security_group_id        = aws_security_group.awesome-ap2-web-sg.id
  description              = "Allow http(80) from ALB SG"
}

# WAS Security Gruop
resource "aws_security_group" "awesome-ap2-was-sg" {
  name        = "awesome-ap2-was-sg"
  vpc_id      = aws_vpc.awesome-vpc.id
  description = "Allow AJP(8009) from Web SG Allow ssh(22) from Bastion SG"

  egress {
    description = "HTTP from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "awesome-ap2-was-sg"
  }
}

resource "aws_security_group_rule" "awesome-ap2-was-sg-rule-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.awesome-ap2-bastion-sg.id
  security_group_id        = aws_security_group.awesome-ap2-was-sg.id
  description              = "Allow ssh(22) from Bastion SG"
}

resource "aws_security_group_rule" "awesome-ap2-was-sg-rule-ajp" {
  type      = "ingress"
  from_port = 8009
  to_port   = 8009
  protocol  = "tcp"
  # source_security_group_id = aws_security_group.awesome-ap2-web-sg.id
  # cidr_blocks = ["10.0.11.0/24", "10.0.21.0/24"]
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awesome-ap2-was-sg.id
  description       = "Allow AJP(8009) from Web SG"
}

# DB Security Gruop
resource "aws_security_group" "awesome-ap2-db-sg" {
  name        = "awesome-ap2-db-sg"
  vpc_id      = aws_vpc.awesome-vpc.id
  description = "Allow Mysql(3306) from WAS SG"

  egress {
    description = "HTTP from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "awesome-ap2-db-sg"
  }
}

resource "aws_security_group_rule" "awesome-ap2-was-db-rule" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.awesome-ap2-was-sg.id
  security_group_id        = aws_security_group.awesome-ap2-db-sg.id
  description              = "Allow Mysql(3306) from WAS SG"
}