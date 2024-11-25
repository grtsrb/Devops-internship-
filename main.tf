module "vpc" {
  source = "./modules/vpc"

  region  = var.region
  env     = var.env
  project = var.project
}

module "subnet" {
  source = "./modules/subnets"

  vpc_id     = module.vpc.vpc_id
  igw_id     = module.vpc.igw_id
  priv_rt_id = module.vpc.priv_rt_id
  pub_rt_id  = module.vpc.pub_rt_id

  region  = var.region
  env     = var.env
  project = var.project
}

module "security_groups" {
  source = "./modules/sec_grp"

  vpc_id = module.vpc.vpc_id

  region  = var.region
  env     = var.env
  project = var.project
}

module "rds_instance" {
  source = "./modules/rds"

  priv_subnet_id = module.subnet.priv_subnet_id[*]
  priv_sg_id     = module.security_groups.priv_sg_id
  region         = var.region
  env            = var.env
  project        = var.project
}

module "ec2_instance" {
  source = "./modules/ec2"

  pub_subnet_id   = module.subnet.pub_subnet_id[0]
  pub_sg_id       = module.security_groups.pub_sg_id
  igw_id          = module.vpc.igw_id
  rds_instance    = module.rds_instance.rds_instance
  db_hostname     = module.rds_instance.db_hostname

  region  = var.region
  env     = var.env
  project = var.project

}