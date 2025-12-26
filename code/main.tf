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