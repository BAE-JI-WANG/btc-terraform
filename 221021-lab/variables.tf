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


variable "alb_name" {
  type    = string
  default = "alb-"
}
