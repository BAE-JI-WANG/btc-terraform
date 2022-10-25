resource "aws_instance" "web-ami" {
  ami                         = var.amazonlinux2_ami # Amazon Linux 2
  instance_type               = var.instance_type
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.large_pub_a.id
  key_name                    = var.bastion_key
  # user_data = data.template_file.userdata.rendered
  user_data              = file("usrdata.sh")
  vpc_security_group_ids = [aws_security_group.all_sg.id]
  tags = {
    "Name" = "large-web-ami"
  }
}

resource "aws_ami_from_instance" "ami" {
  name               = "large-web"
  source_instance_id = aws_instance.web-ami.id
}