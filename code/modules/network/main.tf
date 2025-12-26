//Vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "scc-vpc"
  }
}

//Internet gateway
resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "scc-public-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gateway.id
  }
}

//Route table association with ALB subnets
resource "aws_route_table_association" "public_route_table_for_alb_subnet_1_alfa" {
  subnet_id      = aws_subnet.alb_subnet_az_1_alfa.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_for_alb_subnet_1_beta" {
  subnet_id      = aws_subnet.alb_subnet_az_1_beta.id
  route_table_id = aws_route_table.public_route_table.id
}

//Subnets
resource "aws_subnet" "front_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "scc-front-subnet"
  }
}

resource "aws_subnet" "back_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "scc-back-subnet"
  }
}

//There is two subnets for alb just because its required to create it
resource "aws_subnet" "alb_subnet_az_1_alfa" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "scc-alb-subnet_az_1a"
  }
}

resource "aws_subnet" "alb_subnet_az_1_beta" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "scc-alb-subnet-az-1b"
  }
}
