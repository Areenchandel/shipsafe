terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
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
