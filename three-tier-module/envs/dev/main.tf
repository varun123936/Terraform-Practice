module "infrastructure" {
  source = "../../modules/infrastructure"

  name_prefix           = var.name_prefix
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

module "database" {
  source = "../../modules/database"

  db_subnet_ids     = [module.infrastructure.private_subnet_ids[2], module.infrastructure.private_subnet_ids[5]]
  database_sg_id    = module.infrastructure.database_sg_id
  db_identifier     = var.db_identifier
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  engine_version    = var.db_engine_version
  subnet_group_name = var.db_subnet_group_name
}

module "backend" {
  source = "../../modules/backend/ec2"

  aws_region        = var.aws_region
  ami_id            = var.backend_ami_id
  instance_type     = var.backend_instance_type
  key_name          = var.backend_key_name
  subnet_id         = module.infrastructure.private_subnet_ids[1]
  security_group_id = module.infrastructure.backend_server_sg_id
  instance_name     = var.backend_name
}
