resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_internet_gateway" "prod" {
    vpc_id = aws_vpc.prod.id
    tags = {
        Name = "prod-igw"
    }
}

resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "prod-public-subnet1"
    }
}

resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "prod-public-subnet2"
    }
}

resource "aws_subnet" "private1" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
    tags = {
        Name = "prod-private-subnet1"
    }
}

resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false
    tags = {
        Name = "prod-private-subnet2"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.prod.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod.id
    }
    tags = {
        Name = "prod-public-route-table"
    }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "prod" {
    domain = "vpc"
    tags = {
        Name = "prod-eip"
    }
}

resource "aws_nat_gateway" "prod" {
    allocation_id = aws_eip.prod.allocation_id
    subnet_id = aws_subnet.public1.id
    tags = {
        Name = "prod-nat-gateway"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.prod.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.prod.id
    }
    tags = {
        Name = "prod-private-route-table"
    }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "prod" {
    name = "prod-sg"
    vpc_id = aws_vpc.prod.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "prod-sg"
    }

}


# --- Subnet Group for RDS ---
resource "aws_db_subnet_group" "prod" {
  name       = "prod-db-subnet-group"
  subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id]  # public subnets since you want public RDS

  tags = {
    Name = "prod-db-subnet-group"
  }
}

# --- Security Group for RDS ---
resource "aws_security_group" "rds_sg" {
  name   = "prod-rds-sg"
  vpc_id = aws_vpc.prod.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # ⚠️ Public access, restrict in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-rds-sg"
  }
}

# --- RDS Instance ---
resource "aws_db_instance" "prod" {
  identifier              = "prod-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20

  db_subnet_group_name    = aws_db_subnet_group.prod.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible     = true
  skip_final_snapshot     = true

  # Master credentials managed by AWS Secrets Manager automatically
  manage_master_user_password = true   # 👈 This is the key line
  username                = "admin"

  tags = {
    Name = "prod-mysql"
  }
}
