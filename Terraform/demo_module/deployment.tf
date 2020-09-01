module "demo-vpc" {
  source        = "./modules/vpc"
  ENV           = var.ENV
  AWS_REGION    = var.AWS_REGION
  PROJECT_TAGS  = var.PROJECT_TAGS
}

module "demo-ec2" {
  source              = "./modules/ec2"
  ENV                 = "dev"
  KEY_NAME            = var.KEY_NAME
  PATH_TO_PUBLIC_KEY  = "${path.root}/../${var.KEY_NAME}.pub"
  INSTANCE_TYPE       = "t2.micro"
  VPC_ID              = module.demo-vpc.vpc_id
  PUBLIC_SUBNETS      = module.demo-vpc.public_subnets
  PROJECT_TAGS        = var.PROJECT_TAGS
}
