resource "aws_vpc" "large_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "large-vpc"
  }
}

# Public Subnets 
resource "aws_subnet" "large_pub_a" {
  vpc_id                  = aws_vpc.large_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "large-ap-pub-sub-2a"
  }
}

resource "aws_subnet" "large_pub_c" {
  vpc_id                  = aws_vpc.large_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "large-ap-pub-sub-2c"
  }
}

# Private Subnets
resource "aws_subnet" "large_pri_a" {
  vpc_id            = aws_vpc.large_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "large-ap-pri-sub-2a"
  }
}

resource "aws_subnet" "large_pri_c" {
  vpc_id            = aws_vpc.large_vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "large-ap-pri-sub-2c"
  }
}

# IGW 
resource "aws_internet_gateway" "large_igw" {
  vpc_id = aws_vpc.large_vpc.id

  tags = {
    Name = "large-ap2-igw"
  }
}

# Route Tables
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.large_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.large_igw.id
  }

  tags = {
    Name = "tf-ap2-pub-rt"
  }
}

resource "aws_route_table" "pri_a" {
  vpc_id = aws_vpc.large_vpc.id


  tags = {
    Name = "large-rtb-private1-ap-northeast-2a"
  }
}

resource "aws_route_table" "pri_c" {
  vpc_id = aws_vpc.large_vpc.id


  tags = {
    Name = "large-rtb-private2-ap-northeast-2c"
  }
}

# Route Associations
resource "aws_route_table_association" "pub_ass_a" {
  subnet_id      = aws_subnet.large_pub_a.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_ass_c" {
  subnet_id      = aws_subnet.large_pub_c.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pri_a" {
  subnet_id      = aws_subnet.large_pri_a.id
  route_table_id = aws_route_table.pri_a.id
}

resource "aws_route_table_association" "pri_c" {
  subnet_id      = aws_subnet.large_pri_c.id
  route_table_id = aws_route_table.pri_c.id
}