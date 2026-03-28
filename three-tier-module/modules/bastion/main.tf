data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  bastion_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
}

resource "aws_instance" "bastion" {
  ami                         = local.bastion_ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}
