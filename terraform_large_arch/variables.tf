variable "aws_region" {}
variable "availability_zones_a" {}
variable "availability_zones_c" {}

variable "web_ami" {}
variable "amazonlinux2_ami" {}

variable "web_key" {}
variable "bastion_key" {}

variable "db_name" {}
variable "db_username" {}
variable "db_password" {}

variable "instance_type" {}

# Security Gruop Names
variable "alb_sg_name" {}
variable "web_sg_name" {}
variable "db_sg_name" {}

# Resource Names
variable "alb_name" {}


# Ports
variable "ssh" {}
variable "http" {}
variable "mysql" {}