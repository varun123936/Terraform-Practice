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
