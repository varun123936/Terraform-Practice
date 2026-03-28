module "infrastructure" {
  source = "../../modules/infrastructure"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  igw_name = var.igw_name
}
