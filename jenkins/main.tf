###############################################################################
# Create the Jenkins subnet and the Jenkins server                            #
###############################################################################

provider "aws" {
  version = "~> 2.7"
  region = var.region_name
}

terraform {
  backend "s3" { }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = join("-", [var.account_id, var.project_name, "vpc-terraform-state"])
    key    = "terraform.tfstate"
    region = var.region_name
  }
}
