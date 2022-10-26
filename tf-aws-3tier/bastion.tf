resource "aws_instance" "awesome-ap2-bastion-2a" {
  ami                    = var.amazonlinux2_ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.awesome-ap-pub-sub-2a.id
  key_name               = var.bastion_key
  vpc_security_group_ids = [aws_security_group.awesome-ap2-bastion-sg.id]

  tags = {
    "Name" = "awesome-ap2-bastion-2a"
  }
}