// Available Zone A
resource "aws_subnet" "awesome-ap-pub-sub-2a" {
  vpc_id                  = aws_vpc.awesome-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "awesome-ap-pub-sub-2a"
  }
}

// Priavte
resource "aws_subnet" "awesome-ap-web-sub-2a" {
  vpc_id            = aws_vpc.awesome-vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = var.availability_zones_a

  tags = {
    Name = "awesome-ap-web-sub-2a"
  }
}

resource "aws_subnet" "awesome-ap-was-sub-2a" {
  vpc_id            = aws_vpc.awesome-vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = var.availability_zones_a

  tags = {
    Name = "awesome-ap-was-sub-2a"
  }
}

resource "aws_subnet" "awesome-ap-db-sub-2a" {
  vpc_id            = aws_vpc.awesome-vpc.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = var.availability_zones_a

  tags = {
    Name = "awesome-ap-db-sub-2a"
  }
}

// Available Zone C
resource "aws_subnet" "awesome-ap-pub-sub-2c" {
  vpc_id                  = aws_vpc.awesome-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "awesome-ap-pub-sub-2c"
  }
}

// Priavte
resource "aws_subnet" "awesome-ap-web-sub-2c" {
  vpc_id            = aws_vpc.awesome-vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = var.availability_zones_c

  tags = {
    Name = "awesome-ap-web-sub-2c"
  }
}

resource "aws_subnet" "awesome-ap-was-sub-2c" {
  vpc_id            = aws_vpc.awesome-vpc.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = var.availability_zones_c

  tags = {
    Name = "awesome-ap-was-sub-2c"
  }
}

resource "aws_subnet" "awesome-ap-db-sub-2c" {
  vpc_id            = aws_vpc.awesome-vpc.id
  cidr_block        = "10.0.23.0/24"
  availability_zone = var.availability_zones_c

  tags = {
    Name = "awesome-ap-db-sub-2c"
  }
}