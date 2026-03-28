locals {
  public_subnet_1_name   = "${var.name_prefix}-public-subnet-1"
  public_subnet_2_name   = "${var.name_prefix}-public-subnet-2"
  private_subnet_1_name  = "${var.name_prefix}-private-subnet-1"
  private_subnet_2_name  = "${var.name_prefix}-private-subnet-2"
  private_subnet_3_name  = "${var.name_prefix}-private-subnet-3"
  private_subnet_4_name  = "${var.name_prefix}-private-subnet-4"
  private_subnet_5_name  = "${var.name_prefix}-private-subnet-5"
  private_subnet_6_name  = "${var.name_prefix}-private-subnet-6"
  nat_eip_1_name         = "${var.name_prefix}-nat-eip-1"
  nat_eip_2_name         = "${var.name_prefix}-nat-eip-2"
  nat_gateway_1_name     = "${var.name_prefix}-nat-gateway-1"
  nat_gateway_2_name     = "${var.name_prefix}-nat-gateway-2"
  public_route_table     = "${var.name_prefix}-public-route-table"
  private_route_table_1a = "${var.name_prefix}-private-route-table-1a"
  private_route_table_1b = "${var.name_prefix}-private-route-table-1b"
  bastion_sg_name        = "${var.name_prefix}-bastion-host-sg"
  alb_frontend_sg_name   = "${var.name_prefix}-alb-frontend-sg"
  alb_backend_sg_name    = "${var.name_prefix}-alb-backend-sg"
  frontend_server_sg     = "${var.name_prefix}-frontend-server-sg"
  backend_server_sg      = "${var.name_prefix}-backend-server-sg"
  database_sg_name       = "${var.name_prefix}-database-sg"
}

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
    Name = local.public_subnet_1_name
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = true

  tags = {
    Name = local.public_subnet_2_name
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_1_name
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_2_name
  }
}

resource "aws_subnet" "private_3" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_3_cidr
  availability_zone       = var.availability_zone_1a
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_3_name
  }
}

resource "aws_subnet" "private_4" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_4_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_4_name
  }
}

resource "aws_subnet" "private_5" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_5_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_5_name
  }
}

resource "aws_subnet" "private_6" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.private_subnet_6_cidr
  availability_zone       = var.availability_zone_1b
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_6_name
  }
}

resource "aws_eip" "nat_1" {
  domain = "vpc"

  tags = {
    Name = local.nat_eip_1_name
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"

  tags = {
    Name = local.nat_eip_2_name
  }
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = local.nat_gateway_1_name
  }

  depends_on = [aws_internet_gateway.dev]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = local.nat_gateway_2_name
  }

  depends_on = [aws_internet_gateway.dev]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = local.public_route_table
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
    Name = local.private_route_table_1a
  }
}

resource "aws_route_table" "private_1b" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = local.private_route_table_1b
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

resource "aws_security_group" "bastion_host" {
  name        = local.bastion_sg_name
  description = "Allow SSH access to the bastion host"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.bastion_sg_name
  }
}

resource "aws_security_group" "alb_frontend" {
  name        = local.alb_frontend_sg_name
  description = "Allow public web traffic to the frontend ALB"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.alb_frontend_sg_name
  }
}

resource "aws_security_group" "alb_backend" {
  name        = local.alb_backend_sg_name
  description = "Allow application traffic to the backend ALB"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description     = "HTTP from frontend servers"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_server.id]
  }

  ingress {
    description     = "HTTPS from frontend servers"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_server.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.alb_backend_sg_name
  }
}

resource "aws_security_group" "frontend_server" {
  name        = local.frontend_server_sg
  description = "Allow bastion SSH and frontend ALB traffic to frontend servers"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host.id]
  }

  ingress {
    description     = "HTTP from frontend ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.frontend_server_sg
  }
}

resource "aws_security_group" "backend_server" {
  name        = local.backend_server_sg
  description = "Allow bastion SSH and backend ALB traffic to backend servers"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host.id]
  }

  ingress {
    description     = "HTTP from backend ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.backend_server_sg
  }
}

resource "aws_security_group" "database" {
  name        = local.database_sg_name
  description = "Allow MySQL access from backend servers"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description     = "MySQL from backend servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_server.id]
  }

  ingress {
    description     = "MySQL from bastion host"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.database_sg_name
  }
}
