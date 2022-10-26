resource "aws_eip" "awesome-ap2-bastion-eip" {
  vpc = true

  tags = {
    Name = "awesome-ap2-bastion-eip"
  }
}

resource "aws_eip" "awesome-ap2-nat-eip" {
  vpc = true

  tags = {
    Name = "awesome-ap2-nat-eip"
  }
}