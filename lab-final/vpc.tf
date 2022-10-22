resource "aws_vpc" "tf-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-igw"
  }
}

# Subnets
resource "aws_subnet" "tf-pub-sub-2a" {
  vpc_id                  = aws_vpc.tf-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet-pub1-ap-northeast-2a"
  }
}

resource "aws_subnet" "tf-pub-sub-2c" {
  vpc_id                  = aws_vpc.tf-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet-pub1-ap-northeast-2c"
  }
}

resource "aws_subnet" "tf-pri-sub-2a" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "tf-subnet-pri1-ap-northeast-2a"
  }
}

resource "aws_subnet" "tf-pri-sub-2c" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "tf-subnet-pri1-ap-northeast-2c"
  }
}

# Route Table
resource "aws_route_table" "tf-ap2-pub-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }

  tags = {
    Name = "tf-ap2-pub-rt"
  }
}

resource "aws_route_table" "tf-ap2-pri-rt-a" {
  vpc_id = aws_vpc.tf-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-ap2-nat.id
  }

  tags = {
    Name = "tf-ap2-pri-rt-a"
  }
}

resource "aws_route_table" "tf-ap2-pri-rt-c" {
  vpc_id = aws_vpc.tf-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-ap2-nat.id
  }

  tags = {
    Name = "tf-ap2-pri-rt-c"
  }
}

resource "aws_route_table_association" "tf-pub-rt-ass-a" {
  subnet_id      = aws_subnet.tf-pub-sub-2a.id
  route_table_id = aws_route_table.tf-ap2-pub-rt.id
}

resource "aws_route_table_association" "tf-pub-rt-ass-c" {
  subnet_id      = aws_subnet.tf-pub-sub-2c.id
  route_table_id = aws_route_table.tf-ap2-pub-rt.id
}

resource "aws_route_table_association" "tf-pri-rt-ass-a" {
  subnet_id      = aws_subnet.tf-pri-sub-2a.id
  route_table_id = aws_route_table.tf-ap2-pri-rt-a.id
}

resource "aws_route_table_association" "tf-pri-rt-ass-c" {
  subnet_id      = aws_subnet.tf-pri-sub-2c.id
  route_table_id = aws_route_table.tf-ap2-pri-rt-c.id
}

# NAT
resource "aws_nat_gateway" "tf-ap2-nat" {
  allocation_id = aws_eip.tf-ap2-nat-eip.id

  subnet_id = aws_subnet.tf-pub-sub-2a.id

  tags = {
    Name = "tf-ap2-nat"
  }
  
#   depends_on = aws_internet_gateway.igw
}

# EIP
resource "aws_eip" "tf-ap2-nat-eip" {
  vpc = true

  tags = {
    Name = "tf-ap2-nat-eip"
  }
}