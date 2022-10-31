resource "aws_instance" "bastion" {
  #   ami                         = coalesce(data.aws_ami.amazon_linux2.id, var.ami) # Amazon Linux 2 (us-east-2)
  ami           = "ami-08f869ae259b6bc98"
  disable_api_termination = true
  instance_type = var.instance_type
  tags = {
    "Name" = "sl-bastion"
  }
}