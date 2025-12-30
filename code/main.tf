//You will see "scc" in many files in this project. This stands for:
//s-> Serverless
//c-> CI
//c-> CD

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "terraform"
      Project     = "Serverless ci/cd"
      Owner       = "David Iriondo"
      Version     = "1.0.0"
    }
  }
}


module "network" {
  source = "./modules/network"
}

module "compute" {
  source = "./modules/compute"
}

module "security" {
  source       = "./modules/security"
  github_owner = var.github_owner
  vpc          = module.network.vpc_id
}

module "cluster" {
  source                     = "./modules/cluster"
  ecs_task_execute_role      = module.security.ecs_task_execute_role_arn
  alb_subnets_ids            = [module.network.alb_subnet_az_alfa, module.network.alb_subnet_az_beta]
  alb_security_group_ids     = [module.security.alb_security_group]
  ecs_task_security_group_id = module.security.ecs_task_security_group
  front_subnet_id            = module.network.front_subnet_id
  back_subnet_id             = module.network.back_subnet_id
  vpc                        = module.network.vpc_id
  task_definition_back       = var.task_def_back
  task_definition_front      = var.task_def_front
}
