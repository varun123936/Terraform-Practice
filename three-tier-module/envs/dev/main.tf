module "infrastructure" {
  source = "../../modules/infrastructure"

  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  igw_name              = var.igw_name
  availability_zone_1a  = var.availability_zone_1a
  availability_zone_1b  = var.availability_zone_1b
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  private_subnet_3_cidr = var.private_subnet_3_cidr
  private_subnet_4_cidr = var.private_subnet_4_cidr
  private_subnet_5_cidr = var.private_subnet_5_cidr
  private_subnet_6_cidr = var.private_subnet_6_cidr
}

module "bastion" {
  source = "../../modules/bastion"

  aws_region        = var.aws_region
  instance_type     = var.bastion_instance_type
  key_name          = var.bastion_key_name
  subnet_id         = module.infrastructure.public_subnet_ids[0]
  security_group_id = module.infrastructure.bastion_sg_id
  instance_name     = var.bastion_name
}
