provider "aws" {
  alias   = "dev"
  region  = "ap-south-1"
  profile = "shipsafe-dev"
  default_tags {
    tags = { Project = "shipsafe", Env = "dev", Owner = "areen" }
  }
}

provider "aws" {
  alias   = "staging"
  region  = "ap-south-1"
  profile = "shipsafe-staging"
  default_tags {
    tags = { Project = "shipsafe", Env = "staging", Owner = "areen" }
  }
}

provider "aws" {
  alias   = "prod"
  region  = "ap-south-1"
  profile = "shipsafe-prod"
  default_tags {
    tags = { Project = "shipsafe", Env = "prod", Owner = "areen" }
  }
}
