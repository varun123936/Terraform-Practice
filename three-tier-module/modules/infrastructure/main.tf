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
