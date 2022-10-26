# VPC
resource "aws_vpc" "awesome-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "awesome-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "awesome-ap2-igw" {
  vpc_id = aws_vpc.awesome-vpc.id

  tags = {
    Name = "awesome-ap2-igw"
  }
}

# NAT
resource "aws_nat_gateway" "awesome-ap2-nat" {
  allocation_id = aws_eip.awesome-ap2-nat-eip.id

  subnet_id = aws_subnet.awesome-ap-pub-sub-2a.id

  tags = {
    Name = "awesome-ap2-nat"
  }
}

# Route Table
resource "aws_route_table" "awesome-ap2-pub-rt" {
  vpc_id = aws_vpc.awesome-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.awesome-ap2-igw.id
  }

  tags = {
    Name = "awesome-ap2-pub-rt"
  }
}

resource "aws_route_table" "awesome-ap2-pri-rt-a" {
  vpc_id = aws_vpc.awesome-vpc.id

  tags = {
    Name = "awesome-ap2-pri-rt-a"
  }
}

resource "aws_route_table" "awesome-ap2-pri-rt-c" {
  vpc_id = aws_vpc.awesome-vpc.id

  tags = {
    Name = "awesome-ap2-pri-rt-c"
  }
}

# Route Table Association A
resource "aws_route_table_association" "awesome-ap2-pub-rt-ass-a" {
  subnet_id      = aws_subnet.awesome-ap-pub-sub-2a.id
  route_table_id = aws_route_table.awesome-ap2-pub-rt.id
}

resource "aws_route_table_association" "awesome-ap2-web-rt-ass-a" {
  subnet_id      = aws_subnet.awesome-ap-web-sub-2a.id
  route_table_id = aws_route_table.awesome-ap2-pri-rt-a.id
}

resource "aws_route_table_association" "awesome-ap2-was-rt-ass-a" {
  subnet_id      = aws_subnet.awesome-ap-was-sub-2a.id
  route_table_id = aws_route_table.awesome-ap2-pri-rt-a.id
}

resource "aws_route_table_association" "awesome-ap2-db-rt-ass-a" {
  subnet_id      = aws_subnet.awesome-ap-db-sub-2a.id
  route_table_id = aws_route_table.awesome-ap2-pri-rt-a.id
}

# Route Table Association C
resource "aws_route_table_association" "awesome-ap2-pub-rt-ass-c" {
  subnet_id      = aws_subnet.awesome-ap-pub-sub-2c.id
  route_table_id = aws_route_table.awesome-ap2-pub-rt.id
}

resource "aws_route_table_association" "awesome-ap2-web-rt-ass-c" {
  subnet_id      = aws_subnet.awesome-ap-web-sub-2c.id
  route_table_id = aws_route_table.awesome-ap2-pri-rt-c.id
}

resource "aws_route_table_association" "awesome-ap2-was-rt-ass-c" {
  subnet_id      = aws_subnet.awesome-ap-was-sub-2c.id
  route_table_id = aws_route_table.awesome-ap2-pri-rt-c.id
}

resource "aws_route_table_association" "awesome-ap2-db-rt-ass-c" {
  subnet_id      = aws_subnet.awesome-ap-db-sub-2c.id
  route_table_id = aws_route_table.awesome-ap2-pri-rt-c.id
}

resource "aws_route" "awesome-ap2-pri-route-a" {
  route_table_id         = aws_route_table.awesome-ap2-pri-rt-a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.awesome-ap2-nat.id
}

resource "aws_route" "awesome-ap2-pri-route-c" {
  route_table_id         = aws_route_table.awesome-ap2-pri-rt-c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.awesome-ap2-nat.id
}