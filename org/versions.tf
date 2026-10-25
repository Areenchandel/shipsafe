terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "shipsafe-tfstate-190335339393"
    key          = "org/terraform.tfstate"
    region       = "ap-south-1"
    profile      = "shipsafe-mgmt"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "shipsafe-mgmt"

  default_tags {
    tags = {
      Project = "shipsafe"
      Env     = "mgmt"
      Owner   = "areen"
    }
  }
}
