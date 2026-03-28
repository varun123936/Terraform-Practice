resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet-2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-private-subnet-2"
  }
}

resource "aws_subnet" "private_3" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_3_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-private-subnet-3"
  }
}

resource "aws_subnet" "private_4" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_4_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-private-subnet-4"
  }
}

resource "aws_subnet" "private_5" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_5_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-private-subnet-5"
  }
}

resource "aws_subnet" "private_6" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_6_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-private-subnet-6"
  }
}

resource "aws_eip" "nat_1" {
  domain = "vpc"

  tags = {
    Name = "dev-nat-eip-1"
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"

  tags = {
    Name = "dev-nat-eip-2"
  }
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "dev-nat-gateway-1"
  }

  depends_on = [aws_internet_gateway.dev]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "dev-nat-gateway-2"
  }

  depends_on = [aws_internet_gateway.dev]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-public-route-table"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-private-route-table-1a"
  }
}

resource "aws_route_table" "private_1b" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-private-route-table-1b"
  }
}

resource "aws_route" "private_1a_nat" {
  route_table_id         = aws_route_table.private_1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route" "private_1b_nat" {
  route_table_id         = aws_route_table.private_1b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_4" {
  subnet_id      = aws_subnet.private_4.id
  route_table_id = aws_route_table.private_1b.id
}

resource "aws_route_table_association" "private_5" {
  subnet_id      = aws_subnet.private_5.id
  route_table_id = aws_route_table.private_1b.id
}

resource "aws_route_table_association" "private_6" {
  subnet_id      = aws_subnet.private_6.id
  route_table_id = aws_route_table.private_1b.id
}
