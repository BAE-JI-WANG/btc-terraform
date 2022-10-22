# Key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("terraform-key.pub")
}

# Variables
variable "instance_name" {
  type    = string
  default = "bastion-web"
}

variable "security_group_name_http" {
  type    = string
  default = "http sg"
}

variable "security_group_name_ssh" {
  type    = string
  default = "ssh sg"
}

variable "server_port_ssh" {
  type    = number
  default = "22"
}

variable "server_port_http" {
  type    = number
  default = "80"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami" {
  type = string
}

# Security Groups
resource "aws_security_group" "http" {
  name        = var.security_group_name_http
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

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
    "Name" = "http"
  }
}

resource "aws_security_group" "ssh" {
  name        = var.security_group_name_ssh
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description = "ssh from VPC"
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

# Instances
resource "aws_instance" "bastion" {
  ami                         = coalesce(data.aws_ami.amazon_linux2.id, var.ami) # Amazon Linux 2 (us-east-2)
  instance_type               = var.instance_type
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.tf-pub-sub-2c.id
  key_name                    = aws_key_pair.deployer.key_name
  # user_data = data.template_file.userdata.rendered
  user_data              = templatefile("userdata.tftpl", { HTTP = var.server_port_http })
  vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.ssh.id]
  tags = {
    "Name" = "tf-bastion"
  }
}

resource "aws_instance" "web_pri" {
  ami           = coalesce(data.aws_ami.amazon_linux2.id, var.ami) # Amazon Linux 2 (us-east-2)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.tf-pri-sub-2c.id
  key_name      = aws_key_pair.deployer.key_name
  # user_data = data.template_file.userdata.rendered
  vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.ssh.id]
  tags = {
    "Name" = "tf-pri-web"
  }
}

# Datas
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

# Outputs
output "public_ip" {
  value       = "${aws_instance.bastion.public_ip}:${var.server_port_http}"
  description = "Webserver PIP"
}

output "private_ip" {
  value       = aws_instance.bastion.private_ip
  description = "pri-Webserver private_ip"
}