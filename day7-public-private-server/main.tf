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

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "prod-public-subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
    tags = {
        Name = "prod-private-subnet"
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

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
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
    subnet_id = aws_subnet.public.id
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

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
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

resource "aws_instance" "public" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.prod.id]

  key_name = "asgexample"   # 👈 Add this line

  tags = {
    Name = "prod-public-instance"
  }
}

resource "aws_instance" "private" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.prod.id]

  key_name = "asgexample"   # 👈 Add this line

  tags = {
    Name = "prod-private-instance"
  }
}

